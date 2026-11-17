# VoiceToApp

Script AutoHotkey v2 cho Windows. Bạn nói bằng giọng nói ở ứng dụng AI (Claude, Antigravity, Gemini hoặc ChatGPT), script lấy chữ đã được chỉnh sửa rồi dán vào cửa sổ đang làm việc (Zalo, Telegram, Messenger, Word...).

## Phím tắt
- **F8**: lần 1 bật mic ở ứng dụng AI rồi quay về cửa sổ của bạn. Lần 2 dừng mic, lấy chữ, xoá ô nhập và dán vào cửa sổ của bạn.
- **Nút mic nổi** (từ Rev5.5): bấm vào ô nhập chữ ở cửa sổ của bạn (Zalo, Telegram, Word...) thì một nút mic tròn nhỏ hiện cạnh con trỏ. Bấm nút = bấm F8. Khi đang ghi âm nút nhấp nháy đỏ. Bấm lần nữa để dừng và dán chữ về. Nút không cướp focus của ô nhập.
- **F9 / F10 / F11**: cài đặt vị trí nút Mic, ô nhập và nút Dừng (rê chuột lên đúng chỗ rồi bấm).
- **F12**: đưa cửa sổ ứng dụng AI về đúng vị trí và kích thước đã cài.
- **Ctrl+Shift+F12**: xem tên tiến trình, tiêu đề của cửa sổ dưới con trỏ và kết quả nhận biết ô nhập chữ.

## Cài đặt nút mic nổi
Bấm chuột phải biểu tượng script ở khay hệ thống (cạnh đồng hồ), chọn **Cài đặt nút mic...** (hoặc bấm đúp biểu tượng). Ở đó bạn:
- Bật/tắt nút mic nổi, đổi kích thước và tốc độ nhấp nháy.
- Quản lý danh sách **ứng dụng loại trừ**: bấm vào ô nhập của các ứng dụng này thì không hiện nút mic (mặc định: Claude, ChatGPT, Antigravity, Gemini vì chúng đã có sẵn nhận diện giọng nói). Thêm ứng dụng bằng cách chọn từ danh sách cửa sổ đang mở hoặc gõ tên tiến trình, ví dụ `zalo.exe`.
Cài đặt lưu ở `%LOCALAPPDATA%\VoiceToApp\Settings.ini`, dùng chung cho cả 4 bản.

## Cài đặt (làm một lần)
1. Cài [AutoHotkey v2](https://www.autohotkey.com/).
2. Mở ứng dụng AI, đặt cửa sổ ở vị trí và kích thước bạn muốn.
3. Rê chuột lên nút Mic, bấm F9. Rê lên ô nhập, bấm F10. Khi đang ghi âm, rê lên nút Dừng, bấm F11 (nếu có).
4. Chạy `run_voicetoapp_<tên>.bat` tương ứng.

Vị trí nút, vị trí và kích thước cửa sổ được lưu ở `%LOCALAPPDATA%\VoiceToApp\<App>.ini`, không mất khi tắt máy. Mỗi lần F8 hoặc F12, script tự đưa cửa sổ về đúng chỗ đã lưu. Chỉ cần cài lại khi bạn chủ động đổi vị trí hoặc kích thước cửa sổ.

Chỉ chạy một bản mỗi lúc, vì các bản dùng chung phím tắt.

## Các file
```
├── VoiceToApp_Claude_Rev5.5.ahk   # Claude Desktop
├── VoiceToApp_Agy_Rev5.5.ahk      # Antigravity
├── VoiceToApp_Gemini_Rev5.5.ahk   # Gemini (trong trình duyệt)
├── VoiceToApp_GPT_Rev5.5.ahk      # ChatGPT (ứng dụng hoặc trình duyệt)
├── template/                      # Mẫu chung và script sinh 4 bản
├── CLAUDE.md                      # Quy tắc dự án (cho Claude Code)
├── BAN-GIAO.md                    # Trạng thái và việc đang chờ
├── LICHSU-REV.md                  # Lịch sử các Rev
└── README.md
```

## Giấy phép
MIT License.
