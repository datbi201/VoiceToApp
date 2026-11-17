#Requires AutoHotkey v2.0
#SingleInstance Force
; ============================================================
; VoiceToApp - GPT - Rev5.4
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
MIC_ICON := true               ; true: bam vao o nhap chu o cua so A thi hien nut mic nho; bam nut = F8
MIC_SIZE := 30                 ; kich thuoc nut mic (px, o ti le 100%)
MIC_BLINK_MS := 400            ; chu ky nhap nhay cua nut mic khi dang ghi am (ms)
MIC_USE_UIA := true            ; true: dung UI Automation de nhan biet o nhap chu (chinh xac hon)
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
if MIC_ICON
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
    micSize := Round(MIC_SIZE * A_ScreenDPI / 96)
    ; E0x08000000 = WS_EX_NOACTIVATE: bam vao nut khong lam cua so A mat focus
    micGui := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
    micGui.MarginX := 0
    micGui.MarginY := 0
    micGui.BackColor := "2B6CB0"
    micGui.SetFont("s" Max(8, Round(MIC_SIZE * 0.45)) " cFFFFFF", "Segoe MDL2 Assets")
    ; 0x200 = can giua doc, 0x100 = nhan su kien bam
    micBtn := micGui.Add("Text", "x0 y0 w" micSize " h" micSize " Center 0x200 0x100 BackgroundTrans", Chr(0xE720))
    micBtn.OnEvent("Click", MicClicked)
    micGui.Show("Hide w" micSize " h" micSize)
    rgn := DllCall("CreateEllipticRgn", "int", 0, "int", 0, "int", micSize + 1, "int", micSize + 1, "ptr")
    DllCall("SetWindowRgn", "ptr", micGui.Hwnd, "ptr", rgn, "int", 1)
    SetTimer(MicTick, MIC_BLINK_MS)
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
    if !MIC_ICON
        return
    MouseGetPos(&clickX, &clickY, &clickWin)
    if (micGui && clickWin = micGui.Hwnd)
        return                           ; bam vao chinh nut mic: de MicClicked xu ly
    SetTimer(CheckClickedInput, -140)    ; cho focus on dinh roi moi kiem tra
}

CheckClickedInput() {
    if (recording || toggling)
        return                           ; dang ghi am: giu nguyen nut de con bam dung
    ok := LooksLikeInput(clickX, clickY, &why)
    WriteLog("Bam chuot " clickX "," clickY " -> " (ok ? "O NHAP" : "khong phai o nhap") " [" why "]")
    if ok
        MicShowAt(clickX, clickY)
    else
        MicHide()
}

; Nhan biet focus hien tai co phai o nhap chu khong. why = ly do (de xem trong nhat ky).
LooksLikeInput(x, y, &why) {
    why := ""
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
    bw := FindB()
    if (bw && pn = WinGetProcessName(bw)) {
        why := "dang o cua so " APP_NAME
        return false
    }
    shape := A_Cursor
    caret := HasCaret(hwndA)
    info := MIC_USE_UIA ? UiaProbe() : 0
    why := pn " | uia=" (info ? info.ctype : "-") " caret=" caret " con tro=" shape
    if info {
        if (info.ctype = 50004) {        ; UIA_EditControlTypeId
            if info.pwd {
                why .= " | o mat khau"
                return false
            }
            if !info.en {
                why .= " | o bi khoa"
                return false
            }
            if (info.r > info.l && (x < info.l - 24 || x > info.r + 24 || y < info.t - 24 || y > info.b + 24)) {
                why .= " | bam ngoai o nhap (" info.l "," info.t "," info.r "," info.b ")"
                return false
            }
            return true
        }
    }
    ; Phan mem cu (Word, Notepad, ...) hoac UIA khong thay: co dau nhay (caret) va con tro hinh chu I
    if (caret && shape = "IBeam")
        return true
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

; Hoi UI Automation phan tu dang co focus. Tra ve 0 neu khong doc duoc.
; Chi so ham (vtable): IUIAutomation 8 = GetFocusedElement;
; IUIAutomationElement 21 = ControlType, 28 = IsEnabled, 35 = IsPassword, 43 = BoundingRectangle
UiaProbe() {
    global uiaObj
    el := 0
    try {
        if !IsObject(uiaObj)
            uiaObj := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}", "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
        ComCall(8, uiaObj, "ptr*", &el)
        if !el
            return 0
        ct := 0
        pw := 0
        en := 0
        rc := Buffer(16, 0)
        ComCall(21, el, "int*", &ct)
        ComCall(35, el, "int*", &pw)
        ComCall(28, el, "int*", &en)
        ComCall(43, el, "ptr", rc)
        ObjRelease(el)
        return {ctype: ct, pwd: (pw != 0), en: (en != 0), l: NumGet(rc, 0, "int"), t: NumGet(rc, 4, "int"), r: NumGet(rc, 8, "int"), b: NumGet(rc, 12, "int")}
    } catch {
        if el
            ObjRelease(el)
        return 0
    }
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
