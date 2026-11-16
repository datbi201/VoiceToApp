#Requires AutoHotkey v2.0
#SingleInstance Force
; ============================================================
; VoiceToApp - @@APP@@ - Rev@@REV@@
; Ban o cua so A. F8 bat/tat mic cua @@APP@@, chu duoc dan ve A.
; Chi dung toa do (khong nhan dien hinh anh) de chay nhanh.
;
; CAI DAT MOT LAN: F9 (nut Mic), F10 (o nhap chu), F11 (nut Dung).
; Toa do + vi tri + kich thuoc cua so duoc luu vao
;   %LOCALAPPDATA%\VoiceToApp\@@APP@@.ini
; nen khong mat khi tat may. Moi lan bam F8 (hoac F12), script tu dua
; cua so @@APP@@ ve dung vi tri/kich thuoc da luu.
; Chi can cai lai khi ban chu dong doi vi tri/kich thuoc cua so.
; ============================================================
CoordMode "Mouse", "Screen"
CoordMode "ToolTip", "Screen"
SetTitleMatchMode 2
SetWinDelay 0
SetMouseDelay 0
SetKeyDelay 0

; ===== CAU HINH =====
APP_NAME := "@@APP@@"
; Cac mau cua so can tim, thu lan luot. Xem ten tien trinh/tieu de that bang Ctrl+Shift+F12.
B_CANDIDATES := @@CANDIDATES@@
RETURN_TO_A := true            ; true: bat mic xong quay ve A ngay
BEEP := false                  ; true: phat tieng bip (cao = bat dau ghi, thap = da dan xong)
AUTO_LAYOUT := true            ; true: tu dua cua so ve vi tri/kich thuoc da luu
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
targetA := 0
bProc := ""

; --- PHIM TAT ---
; F8 : bat dau noi / dung va chuyen chu sang A
; F9 : (cai dat) re chuot len nut MIC cua @@APP@@, bam F9
; F10: (cai dat) re chuot len O NHAP CHU cua @@APP@@, bam F10
; F11: (cai dat, neu co) dang ghi am, re chuot len nut DUNG/XAC NHAN, bam F11
; F12: dua cua so @@APP@@ ve dung vi tri/kich thuoc da luu (khong can bat mic)
; Ctrl+Shift+F12: xem ten tien trinh va tieu de cua cua so duoi con tro chuot
F8:: ToggleVoice()
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
    MouseGetPos(, , &h)
    Tip("Tien trinh: " WinGetProcessName(h) " | Tieu de: " WinGetTitle(h), 7000)
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

ToggleVoice() {
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
