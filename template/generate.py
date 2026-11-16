"""Sinh cac ban VoiceToApp_<App>_Rev<so>.ahk tu mot mau chung.

Cach dung (tu thu muc 01_REPO_GITHUB):
    python template/generate.py

Sua mau VoiceToApp_template.ahk roi chay lai de 4 ban luon dong bo.
Khi len Rev moi: doi REV ben duoi, chay script, roi lam theo quy trinh trong CLAUDE.md.
"""
import pathlib

REV = "5.2"

# Ten ban -> danh sach mau cua so can tim (AutoHotkey WinTitle, khop theo thu tu)
APPS = {
    "Claude": ['"ahk_exe claude.exe"'],
    "Agy": ['"ahk_exe Antigravity.exe"'],
    "Gemini": [
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

here = pathlib.Path(__file__).resolve().parent
out_dir = here.parent
template = (here / "VoiceToApp_template.ahk").read_text(encoding="utf-8-sig")

for app, candidates in APPS.items():
    text = (
        template.replace("@@APP@@", app)
        .replace("@@REV@@", REV)
        .replace("@@CANDIDATES@@", "[" + ", ".join(candidates) + "]")
    )
    assert "@@" not in text, "con placeholder chua thay"
    target = out_dir / f"VoiceToApp_{app}_Rev{REV}.ahk"
    target.write_text(text, encoding="utf-8-sig", newline="\n")
    print("Da tao", target.name)
