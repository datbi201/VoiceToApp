# VoiceToApp

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
