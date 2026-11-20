# VoiceToApp

**Tiếng Việt** | [English](#english)

Script AutoHotkey v2 cho Windows. Bạn nói bằng giọng nói ở ứng dụng AI (Claude, Antigravity, Gemini hoặc ChatGPT), script lấy chữ đã được chỉnh sửa rồi dán vào cửa sổ đang làm việc (Zalo, Telegram, Messenger, Word...).

## Phím tắt
- **Nút mic nổi**: bấm vào ô nhập chữ ở cửa sổ của bạn (Zalo, Telegram, Word...) thì một nút mic tròn nhỏ hiện cạnh con trỏ. Bấm nút: lần 1 bật mic ở ứng dụng AI rồi quay về cửa sổ của bạn. Lần 2 dừng mic, lấy chữ, xoá ô nhập và dán vào cửa sổ của bạn. Khi đang ghi âm nút nhấp nháy đỏ. Nút không cướp focus của ô nhập.
- **Phím tắt bật/tắt ghi âm** (mặc định F8, làm việc như bấm nút mic): đổi sang tổ hợp khác hoặc tắt hẳn trong **Cài đặt > Phím tắt**. Từ Rev5.6 không còn phím F9, F10, F11, F12 cố định (hay xung đột với Microsoft Word).
- **Cài vị trí nút, đưa cửa sổ về chỗ cũ, xem thông tin cửa sổ**: làm trong cửa sổ Cài đặt hoặc menu khay hệ thống.

## Tạm dừng và tiếp tục

Bấm trái **một lần** vào biểu tượng VoiceToApp ở khay hệ thống (cạnh đồng hồ) để **tạm dừng**: biểu tượng chuyển **màu đỏ**, nút mic nổi ẩn đi, phím tắt ghi âm được nhả về cho ứng dụng đang dùng. Bấm trái lần nữa để **tiếp tục**: biểu tượng về màu xanh. Rê chuột lên biểu tượng để xem trạng thái. Bấm chuột phải để mở menu (Tạm dừng/Tiếp tục, Cài đặt...). Bấm đúp nhanh chỉ tính một lần.

Nếu đang ghi âm mà bạn bấm biểu tượng để tạm dừng, lượt ghi âm được kết thúc bình thường trước (dừng mic, dán chữ về cửa sổ của bạn) rồi mới tạm dừng. Khi đang cài vị trí nút, hãy bấm Enter hoặc Esc trước.

## Cửa sổ Cài đặt
Bấm chuột phải vào biểu tượng VoiceToApp ở khay hệ thống và chọn **Cai dat...**. Có ba thẻ:
- **Vị trí nút**: cài nút Mic, ô nhập và nút Dừng của ứng dụng AI. Bấm "Cài", cửa sổ ẩn đi, rê chuột lên đúng nút trong ứng dụng AI rồi bấm Enter (Esc để huỷ). Làm một lần, các lần sau dùng lại.
- **Phím tắt**: bật/tắt và đổi phím bật/tắt ghi âm.
- **Nút mic nổi**: ở thẻ này bạn:
- Bật/tắt nút mic nổi, đổi kích thước và tốc độ nhấp nháy.
- Quản lý danh sách **ứng dụng loại trừ**: bấm vào ô nhập của các ứng dụng này thì không hiện nút mic (mặc định: Claude, ChatGPT, Antigravity, Gemini vì chúng đã có sẵn nhận diện giọng nói). Thêm ứng dụng bằng cách chọn từ danh sách cửa sổ đang mở hoặc gõ tên tiến trình, ví dụ `zalo.exe`.
Cài đặt lưu ở `%LOCALAPPDATA%\VoiceToApp\Settings.ini`, dùng chung cho cả 4 bản.

## Cài đặt (làm một lần)
1. Cài [AutoHotkey v2](https://www.autohotkey.com/).
2. Mở ứng dụng AI, đặt cửa sổ ở vị trí và kích thước bạn muốn.
3. Bấm chuột phải biểu tượng script ở khay, chọn Cài đặt, thẻ Vị trí nút: cài nút Mic, ô nhập và nút Dừng (nếu có).
4. Chạy `run_voicetoapp_<tên>.bat` tương ứng.

Vị trí nút, vị trí và kích thước cửa sổ được lưu ở `%LOCALAPPDATA%\VoiceToApp\<App>.ini`, không mất khi tắt máy. Mỗi lần bật hoặc dừng ghi âm, script tự đưa cửa sổ về đúng chỗ đã lưu. Chỉ cần cài lại khi bạn chủ động đổi vị trí hoặc kích thước cửa sổ.

Chỉ chạy một bản mỗi lúc, vì các bản dùng chung phím tắt bật/tắt ghi âm.

## Các file
```
├── VoiceToApp_Claude_Rev5.9.ahk   # Claude Desktop
├── VoiceToApp_Agy_Rev5.9.ahk      # Antigravity
├── VoiceToApp_Gemini_Rev5.9.ahk   # Gemini (trong trình duyệt)
├── VoiceToApp_GPT_Rev5.9.ahk      # ChatGPT (ứng dụng hoặc trình duyệt)
├── template/                      # Mẫu chung và script sinh 4 bản
├── CLAUDE.md                      # Quy tắc dự án (cho Claude Code)
├── BAN-GIAO.md                    # Trạng thái và việc đang chờ
├── LICHSU-REV.md                  # Lịch sử các Rev
└── README.md
```

## Giấy phép
MIT License, xem tệp [LICENSE](LICENSE).


---

## English

**VoiceToApp** is an AutoHotkey v2 script for Windows. You dictate in an AI app (Claude, Antigravity, Gemini or ChatGPT); the script takes the edited text and pastes it into the window you are working in (Zalo, Telegram, Messenger, Word...). The interface is in Vietnamese.

### How it works

- **Floating mic button:** click a text field in your own window and a small round mic button appears next to the caret. Click once: the mic starts in the AI app and focus returns to your window. Click again: the mic stops, the text is taken, the input box is cleared and the text is pasted into your window. The button blinks red while recording and does not steal focus from the text field.
- **Hotkey** to toggle recording (default F8, works like the mic button). Change it or turn it off in Settings, Hotkeys tab.
- **Tray icon:** left-click to pause (icon turns red, floating button hidden, the hotkey is released to other apps) and left-click again to resume. Right-click for the menu. If you pause while recording, the recording is finished normally first.

### Settings window

Right-click the tray icon and choose Settings. Three tabs:

- **Button positions:** set the AI app's Mic button, input box and Stop button. Click "Set", the window hides, hover over the right button in the AI app and press Enter (Esc to cancel). Done once, reused afterwards.
- **Hotkeys:** enable or disable and change the recording hotkey.
- **Floating mic:** enable, size, blink speed, and a list of excluded apps (no mic button in those; default: Claude, ChatGPT, Antigravity, Gemini, since they have built-in voice input). Settings are stored in `%LOCALAPPDATA%\VoiceToApp\Settings.ini`, shared by all four versions.

### Setup (once)

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Open the AI app and place its window where you want it.
3. Right-click the script's tray icon, choose Settings, and on the button-positions tab set the Mic button, input box and Stop button (if any).
4. Run the script for your AI app (`VoiceToApp_Claude_Rev5.9.ahk`, `VoiceToApp_Agy_Rev5.9.ahk`, `VoiceToApp_Gemini_Rev5.9.ahk` or `VoiceToApp_GPT_Rev5.9.ahk`).

Button and window positions are saved in `%LOCALAPPDATA%\VoiceToApp\<App>.ini`. Run only one version at a time, because they share the recording hotkey.

### License

[MIT](LICENSE).
