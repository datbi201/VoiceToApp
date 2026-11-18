"""Sinh cac ban VoiceToApp_<App>_Rev<so>.ahk tu mot mau chung, co kiem tra trung ten.

Cach dung (tu thu muc 01_REPO_GITHUB):
    python template/generate.py

Sua mau VoiceToApp_template.ahk roi chay lai de 4 ban luon dong bo.
Khi len Rev moi: doi REV ben duoi, chay script, roi lam theo quy trinh trong CLAUDE.md.

Kiem tra trung ten: AutoHotkey v2 khong cho ten bien trung ten ham (khong phan biet
hoa thuong), ke ca ham dung san. Loi nay chi lo ra khi chay (vi du Rev5.2: ham Beep
trung bien BEEP). Script se dung neu thay.
"""
import pathlib
import re
import sys

REV = "5.8"

# Ten ban -> danh sach mau cua so can tim (AutoHotkey WinTitle, khop theo thu tu)
APPS = {
    "Claude": ['"ahk_exe claude.exe"'],
    "Agy": ['"ahk_exe Antigravity.exe"'],
    "Gemini": [
        '"ahk_exe Gemini.exe"',          # nguoi dung tu them vao ban Rev5.3 (giu lai de khong mat khi sinh lai)
        '"Gemini ahk_exe chrome.exe"',
        '"Gemini ahk_exe msedge.exe"',
        '"Gemini ahk_exe firefox.exe"',
    ],
    "GPT": [
        '"ahk_exe ChatGPT.exe"',
        '"ChatGPT ahk_exe chrome.exe"',
        '"ChatGPT ahk_exe msedge.exe"',
        '"ChatGPT ahk_exe firefox.exe"',
    ],
}

# Ham/lop dung san cua AutoHotkey v2 hay gap (viet tay, khong day du nhung du cho script nay)
BUILTINS = set("""
abs acos asin atan blockinput callbackcreate callbackfree caretgetpos ceil chr click clipwait
comcall comobject comvalue controlclick controlfocus controlgettext controlsend controlsettext
coordmode cos critical dateadd datediff detecthiddentext detecthiddenwindows dircopy dircreate
dirdelete direxist dirmove dirselect dllcall download drivegetcapacity edit envget envset exit
exitapp exp filecopy filedelete fileexist fileappend filegetsize fileinstall filemove fileopen
fileread filerecycle fileselect float floor format formattime getkeyname getkeystate hasmethod
hasprop hotif hotifwinactive hotkey hotstring imagesearch inidelete iniread iniwrite inputbox
inputhook instr integer isobject isset keywait listhotkeys listlines listvars loadpicture log ln
map max menu min mod monitorget monitorgetcount monitorgetname monitorgetprimary
monitorgetworkarea mouseclick mouseclickdrag mousegetpos mousemove msgbox number numget numput
objaddref objbindmethod objrelease onclipboardchange onerror onexit onmessage ord outputdebug
pause persistent pixelgetcolor pixelsearch postmessage processclose processexist processgetname
processwait random regdelete regread regwrite reload round run runas runwait send sendevent
sendinput sendlevel sendmessage sendmode sendplay sendtext setcapslockstate setcontroldelay
setdefaultmousespeed setkeydelay setmousedelay setnumlockstate setscrolllockstate settimer
settitlematchmode setwindelay setworkingdir shutdown sin sleep sort soundbeep soundplay splitpath
sqrt strcompare strget string strlen strlower strptr strput strreplace strsplit strtitle strupper
substr suspend sysget tan thread tooltip traytip trim type winactivate winactive winclose winexist
wingetclass wingetclientpos wingetcount wingetid wingetlist wingetminmax wingetpid wingetpos
wingetprocessname wingetprocesspath wingettext wingettitle winhide winkill winmaximize
winminimize winmove winrestore winsetalwaysontop winsettitle winshow winwait winwaitactive
winwaitclose array buffer class error file func gui object oserror any
""".split())

KEYWORDS = {"if", "while", "for", "loop", "switch", "catch", "try", "else", "until", "finally"}


def strip_comment(line):
    return re.sub(r'(^|\s);.*$', '', line)


def lint(text, label):
    problems = []
    lines = text.splitlines()
    funcs = {}
    for i, raw in enumerate(lines, 1):
        m = re.match(r'^([A-Za-z_]\w*)\s*\(([^\n]*)\)\s*\{\s*$', strip_comment(raw))
        if m and m.group(1).lower() not in KEYWORDS:
            funcs[m.group(1).lower()] = i
    names = []  # (ten, so dong, mo ta)
    for i, raw in enumerate(lines, 1):
        code = strip_comment(raw)
        m = re.match(r'^([A-Za-z_]\w*)\s*\(([^\n]*)\)\s*\{\s*$', code)
        if m and m.group(1).lower() not in KEYWORDS:
            for prm in m.group(2).split(","):
                prm = prm.strip().lstrip("&").rstrip("*").split(":=")[0].strip()
                if re.fullmatch(r'[A-Za-z_]\w*', prm):
                    names.append((prm, i, "tham so"))
        for mm in re.finditer(r'(?<![\w.&])([A-Za-z_]\w*)\s*(?::=|\+=|-=|\.=)', code):
            names.append((mm.group(1), i, "bien gan gia tri"))
        # Dau & trong chuoi (vi du "&Pause Script") la phim tat cua menu.
        code_without_strings = re.sub(r""" "(?:`.|[^"`])*" | '(?:`.|[^'`])*' """, "", code, flags=re.VERBOSE)
        for mm in re.finditer(r'&([A-Za-z_]\w*)', code_without_strings):
            names.append((mm.group(1), i, "bien dau ra"))
        mm = re.match(r'^\s*(?:global|local|static)\s+(.*)$', code)
        if mm:
            for part in mm.group(1).split(","):
                nm = part.split(":=")[0].strip()
                if re.fullmatch(r'[A-Za-z_]\w*', nm):
                    names.append((nm, i, "khai bao bien"))
        mm = re.search(r'\bfor\s+([A-Za-z_]\w*)(?:\s*,\s*([A-Za-z_]\w*))?\s+in\b', code, re.I)
        if mm:
            for g in mm.groups():
                if g:
                    names.append((g, i, "bien vong for"))
    for nm, i, kind in names:
        low = nm.lower()
        if low in funcs:
            problems.append(f"{label}: dong {i}: {kind} '{nm}' trung ten ham '{nm}' (dong {funcs[low]})")
        elif low in BUILTINS:
            problems.append(f"{label}: dong {i}: {kind} '{nm}' trung ten ham/lop dung san cua AutoHotkey")
    for nm, i in funcs.items():
        if nm in BUILTINS:
            problems.append(f"{label}: dong {i}: ham tu viet '{nm}' trung ten ham dung san cua AutoHotkey")
    return problems


def main():
    here = pathlib.Path(__file__).resolve().parent
    out_dir = here.parent
    template = (here / "VoiceToApp_template.ahk").read_text(encoding="utf-8-sig")
    all_problems = []
    results = {}
    for app, candidates in APPS.items():
        text = (
            template.replace("@@APP@@", app)
            .replace("@@REV@@", REV)
            .replace("@@CANDIDATES@@", "[" + ", ".join(candidates) + "]")
        )
        assert "@@" not in text, "con placeholder chua thay"
        all_problems += lint(text, app)
        results[app] = text
    if all_problems:
        print("PHAT HIEN TRUNG TEN, khong ghi file:")
        for p in sorted(set(all_problems)):
            print("  -", p)
        sys.exit(1)
    for app, text in results.items():
        target = out_dir / f"VoiceToApp_{app}_Rev{REV}.ahk"
        target.write_text(text, encoding="utf-8-sig", newline="\n")
        print("Da tao", target.name)
    print("Kiem tra trung ten: dat")


if __name__ == "__main__":
    main()
