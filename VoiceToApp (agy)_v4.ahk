#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SetTitleMatchMode 2

; ===== CAU HINH =====
B_TITLE := "ahk_exe Antigravity.exe"   ; cua so phan mem B. Doi thanh "ahk_exe Antigravity.exe" hoac mot phan tieu de cua so
RETURN_TO_A := true               ; true: quay ve A ngay sau khi bat mic
WAIT_AFTER_STOP := 1500           ; ms cho B dich xong chu sau khi dung mic
IMG := 40                         ; kich thuoc anh nut (pixel)
TOL := 50                         ; do sai khac mau cho phep khi tim anh (0-255)
; ====================

ini := A_ScriptDir "\VoiceToApp.ini"
psFile := A_Temp "\vta_capture.ps1"
recording := false
targetA := 0
bProc := ""

; --- CAI DAT (moi nut lam 1 lan, dung dung trang thai cua B) ---
; F9 : B dang binh thuong, re chuot len nut MIC, bam F9
; F10: re chuot len O NHAP CHU cua B, bam F10 (lam SAU F9)
; F11: dang ghi am, re chuot len nut DUNG/XAC NHAN, bam F11 (neu B co nut dung rieng)
F9:: Calib("Mic")
F10:: CalibInput()
F11:: Calib("Stop")

Tip(text) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -2500)
}

Log(msg) {
    try FileAppend(FormatTime(, "HH:mm:ss") "  " msg "`n", A_ScriptDir "\VoiceToApp.log", "UTF-8")
}

Capture(x, y, w, h, file) {
    try FileDelete(file)
    try FileDelete(psFile)
    lines := [
        'param($x,$y,$w,$h,$f)',
        'Add-Type -AssemblyName System.Drawing',
        'Add-Type -MemberDefinition `'[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();`' -Name D -Namespace W',
        '[void][W.D]::SetProcessDPIAware()',
        '$bmp = New-Object System.Drawing.Bitmap([int]$w,[int]$h)',
        '$g = [System.Drawing.Graphics]::FromImage($bmp)',
        '$g.CopyFromScreen(([int]$x-100000),([int]$y-100000),0,0,$bmp.Size)',
        '$bmp.Save($f,[System.Drawing.Imaging.ImageFormat]::Png)',
        '$g.Dispose(); $bmp.Dispose()'
    ]
    txt := ""
    for l in lines
        txt .= l "`n"
    FileAppend(txt, psFile, "UTF-8")
    cmd := 'powershell -NoProfile -ExecutionPolicy Bypass -File "' psFile '" ' (x + 100000) ' ' (y + 100000) ' ' w ' ' h ' "' file '"'
    RunWait(cmd, , "Hide")
    return FileExist(file) != ""
}

Calib(name) {
    MouseGetPos &mx, &my, &hwnd
    WinGetPos &wx, &wy, , , hwnd
    IniWrite(mx - wx, ini, "B", name "X")
    IniWrite(my - wy, ini, "B", name "Y")
    MouseMove(wx + 5, wy + 5)          ; tranh de chuot che / lam sang nut khi chup
    Sleep 400
    half := IMG // 2
    ok := Capture(mx - half, my - half, IMG, IMG, A_ScriptDir "\" name ".png")
    MouseMove(mx, my)
    Tip(ok ? "Da luu " name " (anh + vi tri)" : "Da luu vi tri " name " (chup anh bi loi)")
}

CalibInput() {
    MouseGetPos &mx, &my, &hwnd
    WinGetPos &wx, &wy, , , hwnd
    IniWrite(mx - wx, ini, "B", "InputX")
    IniWrite(my - wy, ini, "B", "InputY")
    if FindImg(hwnd, "Mic", &cx, &cy) {
        IniWrite(mx - cx, ini, "B", "InputDX")
        IniWrite(my - cy, ini, "B", "InputDY")
        Tip("Da luu o nhap chu (tinh theo nut Mic)")
    } else {
        Tip("Chua thay nut Mic tren man hinh. Bam F9 truoc, roi F10 lai.")
    }
}

FindImg(hwnd, name, &cx, &cy) {
    file := A_ScriptDir "\" name ".png"
    if !FileExist(file)
        return false
    WinGetPos &wx, &wy, &ww, &wh, hwnd
    Loop 3 {
        try {
            if ImageSearch(&fx, &fy, wx, wy, wx + ww, wy + wh, "*" TOL " " file) {
                cx := fx + IMG // 2
                cy := fy + IMG // 2
                return true
            }
        }
        Sleep 200
    }
    return false
}

; Dua cua so len tren cung va xac nhan that su dang active. Tra ve true/false.
ActivateWin(hwnd) {
    Loop 4 {
        if (WinGetMinMax(hwnd) = -1)
            WinRestore(hwnd)
        if (A_Index = 2) {
            WinSetAlwaysOnTop(1, hwnd)
            WinSetAlwaysOnTop(0, hwnd)
        }
        if (A_Index >= 3)
            Send "{Alt down}{Alt up}"   ; mo khoa chuyen cua so cua Windows
        WinActivate(hwnd)
        if WinWaitActive(hwnd, , 1) {
            Sleep 250
            if WinActive(hwnd)
                return true
        }
    }
    return false
}

; B phai dang la cua so active (cung phan mem voi B)
BIsActive() {
    try return WinGetProcessName("A") = bProc
    return false
}

; Chi bam khi duoi con tro dung la cua so cua B (khong bi cua so khac che)
ClickAt(x, y) {
    MouseMove(x, y)
    Sleep 150
    MouseGetPos(, , &under)
    pn := ""
    try pn := WinGetProcessName(under)
    Log("ClickAt " x "," y " | duoi con tro: " pn " | can: " bProc)
    if (pn != bProc)
        return false
    Click(x, y)
    return true
}

ClickBtn(hwnd, name) {
    if FindImg(hwnd, name, &cx, &cy)
        return ClickAt(cx, cy)
    ; khong thay anh -> dung vi tri tuong doi trong cua so (du phong)
    x := IniRead(ini, "B", name "X", "")
    y := IniRead(ini, "B", name "Y", "")
    if (x = "" || y = "") {
        MsgBox("Chua cai dat nut " name ". Xem huong dan F9/F10/F11.")
        return false
    }
    WinGetPos &wx, &wy, , , hwnd
    return ClickAt(wx + x, wy + y)
}

ClickInput(hwnd) {
    if FindImg(hwnd, "Mic", &cx, &cy) {
        dx := IniRead(ini, "B", "InputDX", "")
        dy := IniRead(ini, "B", "InputDY", "")
        if (dx != "" && dy != "")
            return ClickAt(cx + dx, cy + dy)
    }
    return ClickBtn(hwnd, "Input")
}

; F8: bam lan 1 = bat dau noi, bam lan 2 = dung va chuyen chu sang A
F8:: {
    global recording, targetA, bProc
    bHwnd := WinExist(B_TITLE)
    if !bHwnd {
        MsgBox("Khong tim thay cua so B (" B_TITLE "). Hay mo B truoc.")
        return
    }
    bProc := WinGetProcessName(bHwnd)
    MouseGetPos &ox, &oy
    if !recording {
        targetA := WinExist("A")
        if !ActivateWin(bHwnd) {
            Tip("Khong dua duoc B len tren cung. Chua bat mic.")
            WinActivate(targetA)
            return
        }
        if !ClickBtn(bHwnd, "Mic") {
            Tip("Khong bam duoc nut Mic (B bi che hoac khong thay nut).")
            WinActivate(targetA)
            return
        }
        recording := true
        ToolTip("Dang ghi am... bam F8 de dung")
        if RETURN_TO_A {
            Sleep 300
            WinActivate(targetA)
        }
        MouseMove(ox, oy)
    } else {
        ToolTip()                    ; xoa thong bao "Dang ghi am" de khong che nut
        Log("--- DUNG ---")
        if !ActivateWin(bHwnd) {
            Tip("Khong dua duoc B len tren cung. Mic van dang bat, bam F8 lai.")
            WinActivate(targetA)
            return
        }
        stopName := FileExist(A_ScriptDir "\Stop.png") ? "Stop" : "Mic"
        if !ClickBtn(bHwnd, stopName) {
            Tip("Khong bam duoc nut dung. Mic co the van dang bat, bam F8 lai.")
            WinActivate(targetA)
            return
        }
        recording := false
        Sleep WAIT_AFTER_STOP
        if !BIsActive() || !ClickInput(bHwnd) {
            ToolTip()
            Tip("Khong bam duoc vao o nhap chu cua B. Khong copy gi ca.")
            WinActivate(targetA)
            return
        }
        A_Clipboard := ""
        if !BIsActive() {            ; chot an toan: khong gui phim neu khong phai B
            Tip("Cua so dang active khong phai B. Huy.")
            WinActivate(targetA)
            return
        }
        Sleep 200
        Send "^a"
        Sleep 150
        Send "^c"
        ok := ClipWait(2)
        Log("Copy tu B: " (ok ? "OK, " StrLen(A_Clipboard) " ky tu" : "KHONG co chu"))
        if !ok {
            Tip("Khong lay duoc chu tu B (o nhap trong hoac chua dich xong)")
            WinActivate(targetA)
            return
        }
        ; Xoa o nhap cua B: Ctrl+A + BackSpace, lam 2 lan cho chac (clipboard van giu nguyen chu da copy)
        Loop 2 {
            Send "^a"
            Sleep 120
            Send "{BackSpace}"
            Sleep 250
        }
        Log("Da xoa o nhap cua B")
        ToolTip()
        if !ActivateWin(targetA) {
            Tip("Chu da nam trong clipboard, hay tu bam Ctrl+V")
            return
        }
        Send "^v"
        MouseMove(ox, oy)
    }
}
