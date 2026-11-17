#Requires AutoHotkey v2.0
#SingleInstance Force
; ============================================================
; VoiceToApp - GPT - Rev5.5
; Ban o cua so A. F8 bat/tat mic cua GPT, chu duoc dan ve A.
; Chi dung toa do (khong nhan dien hinh anh) de chay nhanh.
;
; CAI DAT MOT LAN: F9 (nut Mic), F10 (o nhap chu), F11 (nut Dung).
; Toa do + vi tri + kich thuoc cua so duoc luu vao
;   %LOCALAPPDATA%\VoiceToApp\GPT.ini
; nen khong mat khi tat may. Moi lan bam F8 (hoac F12), script tu dua
; cua so GPT ve dung vi tri/kich thuoc da luu.
; Chi can cai lai khi ban chu dong doi vi tri/kich thuoc cua so.
; ============================================================
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"
SetTitleMatchMode 2
SetWinDelay 0
SetMouseDelay 0
SetKeyDelay 0

; ===== CAU HINH =====
APP_NAME := "GPT"
; Cac mau cua so can tim, thu lan luot. Xem ten tien trinh/tieu de that bang Ctrl+Shift+F12.
B_CANDIDATES := ["ahk_exe ChatGPT.exe", "ChatGPT ahk_exe chrome.exe", "ChatGPT ahk_exe msedge.exe", "ChatGPT ahk_exe firefox.exe"]
RETURN_TO_A := true            ; true: bat mic xong quay ve A ngay
BEEP := false                  ; true: phat tieng bip (cao = bat dau ghi, thap = da dan xong)
AUTO_LAYOUT := true            ; true: tu dua cua so ve vi tri/kich thuoc da luu
; Nut mic noi: day chi la GIA TRI MAC DINH. Doi bang cua so "Cai dat nut mic"
; (bam chuot phai bieu tuong script o khay he thong, hoac bam doi vao no). Cai dat luu o
; %LOCALAPPDATA%\VoiceToApp\Settings.ini, dung chung cho ca 4 ban.
MIC_ICON := true               ; true: bam vao o nhap chu o cua so A thi hien nut mic nho; bam nut = F8
MIC_SIZE := 30                 ; kich thuoc nut mic (px, o ti le 100%)
MIC_BLINK_MS := 400            ; chu ky nhap nhay cua nut mic khi dang ghi am (ms)
MIC_USE_UIA := true            ; true: dung UI Automation de nhan biet o nhap chu (chinh xac hon)
; Ung dung da co san nhan dien giong noi: bam vao o nhap cua chung thi khong hien nut mic
MIC_EXCLUDE := "claude.exe|chatgpt.exe|antigravity.exe|gemini.exe"
FOCUS_DELAY := 80              ; ms cho cua so on dinh truoc khi bam
BACK_DELAY := 150              ; ms sau khi bam mic, truoc khi quay ve A
STOP_WAIT := 250               ; ms sau khi bam dung, truoc khi copy chu
POLL_MS := 150                 ; ms giua cac lan copy kiem tra chu da dich xong
MAX_POLL := 10                 ; so lan kiem tra toi da
; ====================

dataDir := EnvGet("LOCALAPPDATA") "\VoiceToApp"
try DirCreate(dataDir)
ini := dataDir "\" APP_NAME ".ini"
logFile := dataDir "\" APP_NAME ".log"
try {
    if (FileExist(logFile) && FileGetSize(logFile) > 200000)
        FileDelete(logFile)
}
recording := false
toggling := false
targetA := 0
bProc := ""
uiaObj := 0
micGui := 0
micBtn := 0
micSize := 0
micShown := false
micPhase := false
micColor := ""
micHost := 0
clickX := 0
clickY := 0
clickWin := 0
recheck := 0
lastFw := ""
settingsGui := 0
settingsIni := dataDir "\Settings.ini"
cfgOn := MIC_ICON
cfgUia := MIC_USE_UIA
cfgSize := MIC_SIZE
cfgBlink := MIC_BLINK_MS
exclList := []
LoadSettings()
SetupTray()
if cfgOn
    MicInit()

; --- PHIM TAT ---
; F8 : bat dau noi / dung va chuyen chu sang A
; F9 : (cai dat) re chuot len nut MIC cua GPT, bam F9
; F10: (cai dat) re chuot len O NHAP CHU cua GPT, bam F10
; F11: (cai dat, neu co) dang ghi am, re chuot len nut DUNG/XAC NHAN, bam F11
; F12: dua cua so GPT ve dung vi tri/kich thuoc da luu (khong can bat mic)
; Ctrl+Shift+F12: xem ten tien trinh, tieu de cua cua so duoi con tro chuot va ket qua nhan biet o nhap chu
; Chuot trai (khong chan chuot): kiem tra xem vua bam vao o nhap chu chua de hien nut mic
F8:: ToggleVoice()
~LButton:: OnAnyClick()
F9:: Calib("Mic")
F10:: Calib("Input")
F11:: Calib("Stop")
F12:: ArrangeNow()
^+F12:: ShowWinInfo()

Tip(text, ms := 2500) {
    ToolTip(text, 20, 20)
    SetTimer(() => ToolTip(), -ms)
}

PlayBeep(freq, dur := 70) {
    if BEEP {
        try SoundBeep(freq, dur)
    }
}

WriteLog(msg) {
    try FileAppend(FormatTime(, "HH:mm:ss") "  " msg "`n", logFile, "UTF-8")
}

; Dat con tro bang SetCursorPos (toa do vat ly) - chinh xac tren nhieu man hinh co ti le phong to khac nhau
SetPos(x, y) {
    DllCall("SetCursorPos", "int", x, "int", y)
}

ShowWinInfo() {
    MouseGetPos(&mx, &my, &h)
    ok := LooksLikeInput(mx, my, &why)
    Tip("Tien trinh: " WinGetProcessName(h) " | Tieu de: " WinGetTitle(h) " | O nhap chu (cua so dang active): " (ok ? "CO" : "khong") " [" why "]", 9000)
}

; Tim cua so B theo danh sach mau, tra ve 0 neu khong thay
FindB() {
    for c in B_CANDIDATES {
        h := WinExist(c)
        if h
            return h
    }
    return 0
}

; ---------- LUU / KHOI PHUC VI TRI CUA SO ----------

Calib(name) {
    bHwnd := FindB()
    if !bHwnd {
        Tip("Khong tim thay cua so " APP_NAME ". Hay mo truoc.", 4000)
        return
    }
    MouseGetPos &mx, &my, &hover
    pn := WinGetProcessName(hover)
    if (pn != WinGetProcessName(bHwnd)) {
        Tip("Con tro dang o cua so '" pn "', khong phai " APP_NAME ". Chua luu.", 4000)
        return
    }
    WinGetPos &wx, &wy, &ww, &wh, bHwnd
    st := WinGetMinMax(bHwnd)
    if (st = -1)
        st := 0

    ; Neu kich thuoc cua so khac lan cai truoc thi cac nut cu khong con dung -> xoa
    note := ""
    oldW := IniRead(ini, "B", "WinW", "")
    oldH := IniRead(ini, "B", "WinH", "")
    oldS := IniRead(ini, "B", "WinState", "")
    if (oldW != "" && oldH != "") {
        changed := (Abs(ww - Integer(oldW)) > 2 || Abs(wh - Integer(oldH)) > 2)
        if (oldS != "" && st != Integer(oldS))
            changed := true
        if changed {
            for k in ["Mic", "Input", "Stop"]
                for ax in ["X", "Y"]
                    try IniDelete(ini, "B", k ax)
            note := " | Kich thuoc cua so da doi: cac nut cu bi xoa, hay cai lai du F9, F10, F11."
        }
    }

    IniWrite(mx - wx, ini, "B", name "X")
    IniWrite(my - wy, ini, "B", name "Y")
    IniWrite(wx, ini, "B", "WinX")
    IniWrite(wy, ini, "B", "WinY")
    IniWrite(ww, ini, "B", "WinW")
    IniWrite(wh, ini, "B", "WinH")
    IniWrite(st, ini, "B", "WinState")
    PlayBeep(1000, 60)
    Tip("Da luu " name ": " (mx - wx) "," (my - wy) " | cua so " ww "x" wh " tai " wx "," wy note, 4500)
    WriteLog("Calib " name " | chuot " mx "," my " | cua so " wx "," wy " " ww "x" wh " state=" st)
}

RectMatch(hwnd, sx, sy, sw, sh, checkPos := true) {
    WinGetPos(&x, &y, &w, &h, hwnd)
    if (Abs(w - sw) > 3 || Abs(h - sh) > 3)
        return false
    if (checkPos && (Abs(x - sx) > 2 || Abs(y - sy) > 2))
        return false
    return true
}

; Tam cua so co nam trong mot man hinh dang noi khong
OnScreen(x, y, w, h) {
    cx := x + w // 2
    cy := y + h // 2
    Loop MonitorGetCount() {
        MonitorGet(A_Index, &l, &t, &r, &b)
        if (cx >= l && cx < r && cy >= t && cy < b)
            return true
    }
    return false
}

; Dua cua so B ve dung vi tri/kich thuoc luc cai dat. Tra ve true neu san sang de bam.
EnsureLayout(hwnd) {
    sw := IniRead(ini, "B", "WinW", "")
    sh := IniRead(ini, "B", "WinH", "")
    if (sw = "" || sh = "")
        return true                      ; chua cai dat gi -> de ClickBtn bao thieu nut
    sw := Integer(sw)
    sh := Integer(sh)
    sx := IniRead(ini, "B", "WinX", "")
    sy := IniRead(ini, "B", "WinY", "")
    if (sx = "" || sy = "") {            ; file ini cu cua Rev5.1: chi co kich thuoc
        if RectMatch(hwnd, 0, 0, sw, sh, false)
            return true
        Tip("Kich thuoc cua so " APP_NAME " da doi. Hay bam lai F9, F10, F11.", 5000)
        WriteLog("Ini cu: kich thuoc khong khop " sw "x" sh)
        return false
    }
    sx := Integer(sx)
    sy := Integer(sy)
    wantMax := (Integer(IniRead(ini, "B", "WinState", "0")) = 1)

    mm := WinGetMinMax(hwnd)
    if (mm = (wantMax ? 1 : 0) && RectMatch(hwnd, sx, sy, sw, sh))
        return true                      ; da dung cho, khong can lam gi

    if !AUTO_LAYOUT {
        if RectMatch(hwnd, sx, sy, sw, sh, false)
            return true                  ; chi khac vi tri, kich thuoc dung -> toa do tuong doi van dung
        Tip("Kich thuoc cua so " APP_NAME " da doi. Hay bam lai F9, F10, F11.", 5000)
        return false
    }

    if !OnScreen(sx, sy, sw, sh) {
        Tip("Vi tri da luu cua " APP_NAME " nam ngoai man hinh (da doi cach bo tri man hinh?). Hay bam lai F9, F10, F11.", 6000)
        WriteLog("Ngoai man hinh: " sx "," sy " " sw "x" sh)
        return false
    }

    WriteLog("Dua cua so ve " sx "," sy " " sw "x" sh " (max=" wantMax ")")
    Loop 2 {
        if (WinGetMinMax(hwnd) = 0)
            break
        WinRestore(hwnd)
        Sleep 60
    }
    WinMove(sx, sy, sw, sh, hwnd)
    Sleep 80
    WinMove(sx, sy, sw, sh, hwnd)        ; lan 2: on dinh khi chuyen giua cac man hinh khac ty le
    if wantMax {
        WinMaximize(hwnd)
        Sleep 150
    } else {
        Sleep 60
    }
    if RectMatch(hwnd, sx, sy, sw, sh, false)
        return true
    WinGetPos(, , &w, &h, hwnd)
    Tip("Khong dua duoc " APP_NAME " ve dung kich thuoc (" w "x" h " thay vi " sw "x" sh "). Hay bam lai F9, F10, F11.", 6000)
    WriteLog("Khong khop sau WinMove: " w "x" h " thay vi " sw "x" sh)
    return false
}

ArrangeNow() {
    global bProc
    bHwnd := FindB()
    if !bHwnd {
        Tip("Khong tim thay cua so " APP_NAME ". Hay mo truoc.", 4000)
        return
    }
    bProc := WinGetProcessName(bHwnd)
    if EnsureLayout(bHwnd)
        Tip("Cua so " APP_NAME " da o dung vi tri da cai dat.")
}

; ---------- CHUYEN CUA SO VA BAM ----------

; Dua cua so len tren cung va xac nhan that su dang active
ActivateWin(hwnd) {
    if WinActive(hwnd)
        return true
    Loop 4 {
        if (WinGetMinMax(hwnd) = -1)
            WinRestore(hwnd)
        if (A_Index = 2) {
            WinSetAlwaysOnTop(1, hwnd)
            WinSetAlwaysOnTop(0, hwnd)
        }
        if (A_Index >= 3)
            Send "{Alt down}{Alt up}"
        WinActivate(hwnd)
        if WinWaitActive(hwnd, , 0.6)
            return true
    }
    return false
}

; Cua so dang active co cung phan mem voi B khong
BIsActive() {
    try return WinGetProcessName("A") = bProc
    return false
}

; Chi bam khi duoi con tro dung la cua so cua B (khong bi cua so khac che)
ClickAt(x, y) {
    SetPos(x, y)
    Sleep 40
    MouseGetPos(, , &under)
    pn := ""
    try pn := WinGetProcessName(under)
    if (pn != bProc) {
        WriteLog("ClickAt " x "," y " BI CHE boi: " pn " (can: " bProc ")")
        return false
    }
    Click()
    return true
}

ClickBtn(hwnd, name) {
    x := IniRead(ini, "B", name "X", "")
    y := IniRead(ini, "B", name "Y", "")
    if (x = "" || y = "") {
        Tip("Chua cai dat " name ". Bam F9 (Mic), F10 (O nhap), F11 (Dung).", 5000)
        return false
    }
    WinGetPos &wx, &wy, , , hwnd
    return ClickAt(wx + Integer(x), wy + Integer(y))
}

BackToA() {
    if targetA
        ActivateWin(targetA)
}

; ---------- NUT MIC NHO TREN O NHAP CHU ----------
; Bam vao o nhap chu (o cua so A) -> hien nut mic tron nho canh con tro.
; Bam nut mic = bam F8. Khi dang ghi am nut nhap nhay do. Nut khong cuop focus cua A.

MicInit() {
    global micGui, micBtn, micSize
    micSize := Round(cfgSize * A_ScreenDPI / 96)
    ; E0x08000000 = WS_EX_NOACTIVATE: bam vao nut khong lam cua so A mat focus
    micGui := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
    micGui.MarginX := 0
    micGui.MarginY := 0
    micGui.BackColor := "2B6CB0"
    micGui.SetFont("s" Max(8, Round(cfgSize * 0.45)) " cFFFFFF", "Segoe MDL2 Assets")
    ; 0x200 = can giua doc, 0x100 = nhan su kien bam
    micBtn := micGui.Add("Text", "x0 y0 w" micSize " h" micSize " Center 0x200 0x100 BackgroundTrans", Chr(0xE720))
    micBtn.OnEvent("Click", MicClicked)
    micGui.Show("Hide w" micSize " h" micSize)
    rgn := DllCall("CreateEllipticRgn", "int", 0, "int", 0, "int", micSize + 1, "int", micSize + 1, "ptr")
    DllCall("SetWindowRgn", "ptr", micGui.Hwnd, "ptr", rgn, "int", 1)
    SetTimer(MicTick, cfgBlink)
}

; Huy nut mic (khi doi kich thuoc/chu ky hoac tat tinh nang)
MicDestroy() {
    global micGui, micBtn, micShown, micColor
    SetTimer(MicTick, 0)
    if micGui {
        micGui.Destroy()
        micGui := 0
        micBtn := 0
    }
    micShown := false
    micColor := ""
}

MicClicked(*) {
    WriteLog("Bam nut mic noi")
    ToggleVoice()
}

MicPaint(col) {
    global micColor
    if (col = micColor)
        return
    micColor := col
    micGui.BackColor := col
    DllCall("InvalidateRect", "ptr", micGui.Hwnd, "ptr", 0, "int", 1)
    micBtn.Redraw()
}

MicHide() {
    global micShown
    if micShown {
        micGui.Hide()
        micShown := false
    }
}

; Hien nut mic phia tren ben phai diem vua bam, giu trong vung lam viec cua man hinh
MicShowAt(x, y) {
    global micShown, micHost
    px := x + 16
    py := y - micSize - 16
    Loop MonitorGetCount() {
        MonitorGetWorkArea(A_Index, &l, &t, &r, &b)
        if (x >= l && x < r && y >= t && y < b) {
            if (py < t)
                py := y + 24
            px := Max(l + 4, Min(px, r - micSize - 4))
            py := Max(t + 4, Min(py, b - micSize - 4))
            break
        }
    }
    micHost := WinExist("A")
    MicPaint(recording ? "E53935" : "2B6CB0")
    micGui.Show("NA x" px " y" py)
    micShown := true
}

; Chay moi MIC_BLINK_MS: nhap nhay khi dang ghi am, an nut khi nguoi dung chuyen sang cua so khac
MicTick() {
    global micPhase
    if !micShown
        return
    if recording {
        micPhase := !micPhase
        MicPaint(micPhase ? "E53935" : "4A1014")
        return
    }
    micPhase := false
    MicPaint("2B6CB0")
    if toggling
        return
    cur := WinExist("A")
    if (cur && cur != micHost && cur != micGui.Hwnd)
        MicHide()
}

OnAnyClick() {
    global clickX, clickY, clickWin
    global recheck
    if (!cfgOn || !micGui)
        return
    MouseGetPos(&clickX, &clickY, &clickWin)
    if (clickWin = micGui.Hwnd)
        return                           ; bam vao chinh nut mic: de MicClicked xu ly
    recheck := 1
    SetTimer(CheckClickedInput, -140)    ; cho focus on dinh roi moi kiem tra
}

CheckClickedInput() {
    global recheck
    if (recording || toggling || !micGui)
        return                           ; dang ghi am: giu nguyen nut de con bam dung
    ok := LooksLikeInput(clickX, clickY, &why)
    ; Chromium/Electron (Zalo, Teams...) dung cay truy cap cham sau cu bam dau: hoi lai mot lan
    if (!ok && recheck > 0 && InStr(lastFw, "Chrome")) {
        recheck := 0
        WriteLog("Bam chuot " clickX "," clickY " -> chua thay o nhap, hoi lai [" why "]")
        SetTimer(CheckClickedInput, -350)
        return
    }
    WriteLog("Bam chuot " clickX "," clickY " -> " (ok ? "O NHAP" : "khong phai o nhap") " [" why "]")
    if ok
        MicShowAt(clickX, clickY)
    else
        MicHide()
}

; Nhan biet focus hien tai co phai o nhap chu khong. why = ly do (de xem trong nhat ky).
LooksLikeInput(x, y, &why) {
    global lastFw
    why := ""
    lastFw := ""
    hwndA := WinExist("A")
    if !hwndA {
        why := "khong co cua so active"
        return false
    }
    if (micGui && hwndA = micGui.Hwnd) {
        why := "cua so mic"
        return false
    }
    pn := ""
    try pn := WinGetProcessName(hwndA)
    if IsExcludedApp(pn) {
        why := pn " | ung dung nam trong danh sach loai tru"
        return false
    }
    bw := FindB()
    if (bw && pn = WinGetProcessName(bw)) {
        why := "dang o cua so " APP_NAME
        return false
    }
    shape := A_Cursor
    caret := HasCaret(hwndA)
    info := cfgUia ? UiaProbe() : 0
    why := pn " | caret=" caret " con tro=" shape
    if info {
        lastFw := info.fw
        why .= " | uia=" info.ctype " aria=" (info.aria != "" ? info.aria : "-") " value=" (info.hasVal ? 1 : 0)
        why .= " ghi_duoc=" ((info.hasVal && !info.ro) ? 1 : 0) " text=" (info.tp ? 1 : 0) " focus=" (info.kf ? 1 : 0)
        why .= " fw=" (info.fw != "" ? info.fw : "-")
        if info.pwd {
            why .= " | o mat khau"
            return false
        }
        if ClassifyInput(info) {
            ; Chi o Edit chuan moi kiem tra vi tri bam (o Chromium toa do khung co the khac)
            if (info.ctype = 50004 && info.r > info.l
                && (x < info.l - 24 || x > info.r + 24 || y < info.t - 24 || y > info.b + 24)) {
                why .= " | bam ngoai o nhap (" info.l "," info.t "," info.r "," info.b ")"
                return false
            }
            return true
        }
    } else if cfgUia {
        why .= " | uia=khong doc duoc"
    }
    ; Phan mem cu (Word, Notepad, ...) hoac UIA khong thay: co dau nhay (caret) va con tro hinh chu I
    if (caret && shape = "IBeam")
        return true
    return false
}

; Phan tu dang co focus (theo UI Automation) co phai o soan thao ghi duoc khong.
; Quy tac giong ban AI Voice Typer: o Edit/ComboBox; vung ARIA "textbox"; Document ghi duoc;
; Group/Custom/Pane (o soan thao tu che cua Chromium/Electron nhu Zalo) ghi duoc va co Value/Text.
ClassifyInput(info) {
    if (!info.en || !info.kf)
        return false
    role := StrLower(info.aria)
    ro := (info.hasVal && info.ro)
    if (role = "textbox" || role = "searchbox")
        return !ro
    if (info.ctype = 50004 || info.ctype = 50003)          ; Edit, ComboBox
        return !ro
    if (info.ctype = 50030)                                ; Document
        return (info.hasVal && !info.ro)
    if (info.ctype = 50026 || info.ctype = 50025 || info.ctype = 50033)   ; Group, Custom, Pane
        return (info.hasVal && !info.ro)                   ; ghi duoc (ValuePattern)
    return false
}

; Cua so dang active co caret he thong khong (Word, Notepad, o nhap Win32...)
HasCaret(hwnd) {
    tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr", 0, "uint")
    gti := Buffer(8 + 6 * A_PtrSize + 16, 0)
    NumPut("uint", gti.Size, gti, 0)
    if !DllCall("GetGUIThreadInfo", "uint", tid, "ptr", gti)
        return false
    return NumGet(gti, 8 + 5 * A_PtrSize, "ptr") != 0
}

; Doc mot thuoc tinh cua phan tu UI Automation (IUIAutomationElement::GetCurrentPropertyValue, chi so 10).
; Tra ve so (kieu int/bool) hoac chuoi (BSTR); chuoi rong neu thuoc tinh khong co.
UiaProp(el, propId) {
    v := Buffer(24, 0)
    ComCall(10, el, "int", propId, "ptr", v)
    vt := NumGet(v, 0, "ushort")
    r := ""
    if (vt = 8) {                                          ; VT_BSTR
        p := NumGet(v, 8, "ptr")
        if p
            r := StrGet(p, "UTF-16")
    } else if (vt = 11) {                                  ; VT_BOOL
        r := (NumGet(v, 8, "short") != 0) ? 1 : 0
    } else if (vt = 3 || vt = 2) {                         ; VT_I4, VT_I2
        r := NumGet(v, 8, "int")
    }
    DllCall("oleaut32\VariantClear", "ptr", v)
    return r
}

; Hoi UI Automation phan tu dang co focus. Tra ve 0 neu khong doc duoc.
; Chi so ham (vtable): IUIAutomation 8 = GetFocusedElement;
; IUIAutomationElement 10 = GetCurrentPropertyValue, 43 = BoundingRectangle
; Ma thuoc tinh: 30003 ControlType, 30009 IsKeyboardFocusable, 30010 IsEnabled, 30019 IsPassword,
; 30024 FrameworkId, 30040 IsTextPatternAvailable, 30043 IsValuePatternAvailable,
; 30046 ValueIsReadOnly, 30101 AriaRole
UiaProbe() {
    global uiaObj
    el := 0
    try {
        if !IsObject(uiaObj)
            uiaObj := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
        ComCall(8, uiaObj, "ptr*", &el)
        if !el
            return 0
        rc := Buffer(16, 0)
        ComCall(43, el, "ptr", rc)
        ct := UiaProp(el, 30003)
        ct := (ct = "") ? 0 : ct
        info := {ctype: ct, kf: (UiaProp(el, 30009) = 1), en: (UiaProp(el, 30010) = 1), pwd: (UiaProp(el, 30019) = 1), fw: UiaProp(el, 30024), tp: (UiaProp(el, 30040) = 1), hasVal: (UiaProp(el, 30043) = 1), ro: (UiaProp(el, 30046) = 1), aria: UiaProp(el, 30101), l: NumGet(rc, 0, "int"), t: NumGet(rc, 4, "int"), r: NumGet(rc, 8, "int"), b: NumGet(rc, 12, "int")}
        ObjRelease(el)
        return info
    } catch {
        if el
            ObjRelease(el)
        return 0
    }
}

; ---------- CAI DAT (cua so + menu khay he thong) ----------

NormApp(name) {
    n := StrLower(Trim(name))
    if (SubStr(n, -4) = ".exe")
        n := SubStr(n, 1, StrLen(n) - 4)
    return RegExReplace(n, "[\s_\-.]+")
}

IsExcludedApp(pn) {
    n := NormApp(pn)
    if (n = "")
        return false
    for item in exclList {
        if (NormApp(item) = n)
            return true
    }
    return false
}

LoadSettings() {
    global cfgOn, cfgUia, cfgSize, cfgBlink, exclList
    cfgOn := IniRead(settingsIni, "Mic", "Enabled", MIC_ICON ? 1 : 0) = 1
    cfgUia := IniRead(settingsIni, "Mic", "UseUIA", MIC_USE_UIA ? 1 : 0) = 1
    try {
        cfgSize := Max(16, Min(80, Integer(IniRead(settingsIni, "Mic", "Size", MIC_SIZE))))
    } catch {
        cfgSize := MIC_SIZE
    }
    try {
        cfgBlink := Max(150, Min(2000, Integer(IniRead(settingsIni, "Mic", "BlinkMs", MIC_BLINK_MS))))
    } catch {
        cfgBlink := MIC_BLINK_MS
    }
    raw := IniRead(settingsIni, "Mic", "Excluded", MIC_EXCLUDE)
    exclList := []
    for item in StrSplit(raw, "|") {
        item := Trim(item)
        if (item != "")
            exclList.Push(item)
    }
}

SaveSettings() {
    IniWrite(cfgOn ? 1 : 0, settingsIni, "Mic", "Enabled")
    IniWrite(cfgUia ? 1 : 0, settingsIni, "Mic", "UseUIA")
    IniWrite(cfgSize, settingsIni, "Mic", "Size")
    IniWrite(cfgBlink, settingsIni, "Mic", "BlinkMs")
    s := ""
    for item in exclList
        s .= (s = "" ? "" : "|") item
    IniWrite(s, settingsIni, "Mic", "Excluded")
}

SetupTray() {
    A_IconTip := "VoiceToApp - " APP_NAME
    A_TrayMenu.Add()
    A_TrayMenu.Add("Hien nut mic noi", TrayToggleMic)
    A_TrayMenu.Add("Cai dat nut mic...", (*) => ShowSettings())
    A_TrayMenu.Default := "Cai dat nut mic..."
    if cfgOn
        A_TrayMenu.Check("Hien nut mic noi")
}

TrayToggleMic(*) {
    global cfgOn
    cfgOn := !cfgOn
    SaveSettings()
    ApplyMicSettings()
}

; Ap dung cai dat vao nut mic dang chay
ApplyMicSettings() {
    MicDestroy()
    if cfgOn {
        MicInit()
        A_TrayMenu.Check("Hien nut mic noi")
    } else {
        A_TrayMenu.Uncheck("Hien nut mic noi")
    }
}

; Ten tien trinh cua cac cua so dang mo (de them vao danh sach loai tru)
RunningApps() {
    seen := Map()
    for h in WinGetList() {
        try {
            if (WinGetTitle(h) = "" || !(WinGetStyle(h) & 0x10000000))
                continue
            pn := WinGetProcessName(h)
            if (pn != "" && !seen.Has(StrLower(pn)))
                seen[StrLower(pn)] := pn
        }
    }
    arr := []
    for k, v in seen
        arr.Push(v)
    return arr
}

ShowSettings() {
    global settingsGui
    if settingsGui {
        settingsGui.Show()
        return
    }
    g := Gui("+AlwaysOnTop", "Cai dat nut mic - " APP_NAME)
    g.SetFont("s10")
    settingsGui := g
    cbOn := g.Add("Checkbox", "xm w420", "Hien nut mic noi khi bam vao o nhap chu")
    cbOn.Value := cfgOn ? 1 : 0
    cbUia := g.Add("Checkbox", "xm w420", "Dung UI Automation de nhan biet o nhap (chinh xac hon; tat neu ung dung bi cham)")
    cbUia.Value := cfgUia ? 1 : 0
    g.Add("Text", "xm y+12 w200", "Kich thuoc nut mic (16-80):")
    edSize := g.Add("Edit", "x+0 w70 Number", cfgSize)
    g.Add("Text", "xm y+8 w200", "Chu ky nhap nhay (150-2000 ms):")
    edBlink := g.Add("Edit", "x+0 w70 Number", cfgBlink)
    g.Add("Text", "xm y+14 w420", "Ung dung da co san nhan dien giong noi (khong hien nut mic khi bam vao o nhap cua chung):")
    lb := g.Add("ListBox", "xm w420 r7")
    for item in exclList
        lb.Add([item])
    btnDel := g.Add("Button", "xm w150", "Xoa muc dang chon")
    g.Add("Text", "xm y+12 w420", "Them ung dung (chon tu cac cua so dang mo, hoac go ten tien trinh, vi du zalo.exe):")
    cb := g.Add("ComboBox", "xm w300", RunningApps())
    btnAdd := g.Add("Button", "x+8 w110", "Them")
    btnSave := g.Add("Button", "xm y+16 w120 Default", "Luu")
    btnClose := g.Add("Button", "x+8 w120", "Dong")

    DelSel(*) {
        i := lb.Value
        if i
            lb.Delete(i)
    }
    AddApp(*) {
        t := Trim(cb.Text)
        if (t = "")
            return
        if (SubStr(StrLower(t), -4) != ".exe")
            t .= ".exe"
        n := NormApp(t)
        for old in ControlGetItems(lb) {
            if (NormApp(old) = n)
                return
        }
        lb.Add([t])
        cb.Text := ""
    }
    SaveAll(*) {
        global cfgOn, cfgUia, cfgSize, cfgBlink, exclList
        cfgOn := (cbOn.Value = 1)
        cfgUia := (cbUia.Value = 1)
        cfgSize := Max(16, Min(80, edSize.Value != "" ? Integer(edSize.Value) : MIC_SIZE))
        cfgBlink := Max(150, Min(2000, edBlink.Value != "" ? Integer(edBlink.Value) : MIC_BLINK_MS))
        exclList := ControlGetItems(lb)
        SaveSettings()
        ApplyMicSettings()
        CloseWin()
        Tip("Da luu cai dat nut mic.", 2000)
    }
    CloseWin(*) {
        global settingsGui
        g.Destroy()
        settingsGui := 0
    }
    btnDel.OnEvent("Click", DelSel)
    btnAdd.OnEvent("Click", AddApp)
    btnSave.OnEvent("Click", SaveAll)
    btnClose.OnEvent("Click", CloseWin)
    g.OnEvent("Close", CloseWin)
    g.OnEvent("Escape", CloseWin)
    g.Show()
}

; F8 hoac bam nut mic. Chong chay chong cheo khi bam lien tiep.
ToggleVoice() {
    global toggling
    if toggling
        return
    toggling := true
    try {
        ToggleCore()
    } finally {
        toggling := false
    }
}

ToggleCore() {
    global recording, targetA, bProc
    t0 := A_TickCount
    bHwnd := FindB()
    if !bHwnd {
        Tip("Khong tim thay cua so " APP_NAME ". Hay mo truoc (Ctrl+Shift+F12 de xem ten that).", 4000)
        return
    }
    bProc := WinGetProcessName(bHwnd)
    MouseGetPos &ox, &oy

    if !recording {
        ; ---------- BAT MIC ----------
        targetA := WinExist("A")
        if !ActivateWin(bHwnd) {
            Tip("Khong dua duoc " APP_NAME " len tren cung. Chua bat mic.", 4000)
            BackToA()
            return
        }
        if !EnsureLayout(bHwnd) {
            BackToA()
            return
        }
        Sleep FOCUS_DELAY
        if !ClickBtn(bHwnd, "Mic") {
            Tip("Khong bam duoc nut Mic (bi che hoac chua cai dat).", 4000)
            BackToA()
            return
        }
        recording := true
        PlayBeep(900)
        ToolTip("Dang ghi am... bam F8 de dung", 20, 20)
        if RETURN_TO_A {
            Sleep BACK_DELAY
            BackToA()
        }
        SetPos(ox, oy)
        WriteLog("BAT xong sau " (A_TickCount - t0) " ms")
        return
    }

    ; ---------- DUNG VA CHUYEN CHU ----------
    ToolTip()
    if !ActivateWin(bHwnd) {
        Tip("Khong dua duoc " APP_NAME " len tren cung. Mic van bat, bam F8 lai.", 4000)
        BackToA()
        return
    }
    if !EnsureLayout(bHwnd) {
        BackToA()
        return
    }
    Sleep FOCUS_DELAY
    stopName := (IniRead(ini, "B", "StopX", "") != "") ? "Stop" : "Mic"
    if !ClickBtn(bHwnd, stopName) {
        Tip("Khong bam duoc nut dung. Mic co the van bat, bam F8 lai.", 4000)
        BackToA()
        return
    }
    recording := false
    t1 := A_TickCount
    Sleep STOP_WAIT
    if !ClickBtn(bHwnd, "Input") {
        Tip("Khong bam duoc vao o nhap chu cua " APP_NAME ". Khong copy.", 4000)
        BackToA()
        return
    }
    Sleep 60

    ; Copy lap lai cho den khi chu on dinh 2 lan lien tiep (B dich xong)
    text := ""
    Loop MAX_POLL {
        if !BIsActive() {
            Tip("Cua so dang active khong phai " APP_NAME ". Huy.", 4000)
            BackToA()
            return
        }
        A_Clipboard := ""
        Send "^a"
        Sleep 40
        Send "^c"
        if ClipWait(0.4) {
            t := A_Clipboard
            if (t != "" && t == text)
                break
            text := t
        }
        Sleep POLL_MS
    }
    if (text = "") {
        Tip("Khong lay duoc chu tu " APP_NAME " (o nhap trong hoac chua dich xong).", 4000)
        BackToA()
        return
    }
    t2 := A_TickCount
    A_Clipboard := text

    ; Xoa o nhap cua B
    Loop 2 {
        Send "^a"
        Sleep 40
        Send "{BackSpace}"
        Sleep 80
    }

    if (targetA && !ActivateWin(targetA)) {
        Tip("Chu da nam trong clipboard, hay tu bam Ctrl+V.", 4000)
        return
    }
    Sleep 80
    Send "^v"
    SetPos(ox, oy)
    PlayBeep(700)
    WriteLog("DUNG xong sau " (A_TickCount - t0) " ms (cho+copy " (t2 - t1) " ms, " StrLen(text) " ky tu)")
}
