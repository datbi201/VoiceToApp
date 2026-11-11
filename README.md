# VoiceToApp
Voice-to-Text bridge automation script written in AutoHotkey v2.

VoiceToApp allows you to dictate text using the built-in speech-to-text / voice recognition of an AI app (such as Google Antigravity or Claude Desktop) and automatically pastes the transcribed text into whatever target window you are working on (Word, Browser, VS Code, Chat, Terminal, etc.).

## 🚀 Key Features
- **Global Hotkey `F8`**: 
  - 1st press: Focuses speech app, clicks Mic, returns focus to your active window.
  - 2nd press: Stops dictation, grabs transcription from speech app, clears the app input, and pastes text directly into your active window.
- **Visual Image Search + Relative Coordinate Calibration**:
  - Automatically identifies Mic / Stop buttons on screen using template images (`Mic.png`, `Stop.png`).
  - Fallback to relative window coordinates calibrated via INI settings.
- **Multi-app Support**:
  - `VoiceToApp (agy)_v4.ahk`: Configured for **Google Antigravity**.
  - `VoiceToApp (claude)_v4.ahk`: Configured for **Claude Desktop**.
  - `VoiceToApp.ahk`: Master script (defaults to Antigravity, configurable).

## 🛠 Prerequisites
- Windows 10/11
- [AutoHotkey v2.0+](https://www.autohotkey.com/) installed (`C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`)

## 🎯 Quick Calibration (Run once for your monitor layout)
1. Open the speech app (Antigravity or Claude).
2. Hover mouse over the **Mic button** and press `F9`.
3. Hover mouse over the **Input prompt area** and press `F10`.
4. While dictating, hover mouse over the **Stop button** and press `F11`.

Coordinates and screenshot templates will be stored in `VoiceToApp.ini` and `.png` files.

## 📁 Repository Structure
```
├── VoiceToApp.ahk               # Master AutoHotkey v2 script
├── VoiceToApp (agy)_v4.ahk      # Dedicated script for Antigravity
├── VoiceToApp (claude)_v4.ahk   # Dedicated script for Claude Desktop
├── Mic.png                      # Calibration image template for Mic button
├── Stop.png                     # Calibration image template for Stop button
├── VoiceToApp.example.ini       # Template calibration configuration
└── README.md                    # Project documentation
```

## ⚖️ License
MIT License.
