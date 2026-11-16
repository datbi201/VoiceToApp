# Bàn giao: VoiceToApp

Cập nhật: 16/11/2026

## Trạng thái hiện tại
- **Rev mới nhất: 5.2**, bốn file: `VoiceToApp_Claude_Rev5.2.ahk`, `VoiceToApp_Agy_Rev5.2.ahk`, `VoiceToApp_Gemini_Rev5.2.ahk`, `VoiceToApp_GPT_Rev5.2.ahk`.
- Rev5.2 mới viết xong, **chưa thử trên máy thật**. Máy công ty có hai màn hình (màn 1: 3440×1440 ở 100%, màn 2: 2160×1440 ở 125%). Máy nhà một màn 4K.
- Điểm mới: lưu vị trí và kích thước cửa sổ B, tự đưa về đúng chỗ khi F8 hoặc F12.
- Rev5.1 (người dùng đang dùng) nằm ở `03_ONEDRIVE_BACKUP\revisions`. Các Rev cũ hơn cũng ở đó, giữ tên gốc.
- Mẫu chung và script sinh file nằm ở `template\`. Sửa mẫu, rồi chạy `python template\generate.py`.

## Việc đang chờ
1. Người dùng thử Rev5.2 bản Agy và Claude: bấm F9, F10, F11 một lần, tắt cửa sổ, mở lại ở chỗ khác, bấm F8. Cửa sổ phải tự về đúng chỗ.
2. Thử trên màn 2 máy công ty (hai tỷ lệ phóng to khác nhau) để xem WinMove có đưa về đúng kích thước không. Nhật ký: `%LOCALAPPDATA%\VoiceToApp\<App>.log`.
3. Bản Gemini và GPT chưa xác nhận tiêu đề cửa sổ thật. Nếu script báo không tìm thấy, rê chuột lên cửa sổ, bấm Ctrl+Shift+F12 để xem tên tiến trình và tiêu đề, rồi sửa `B_CANDIDATES` trong mẫu.
4. Thử khi có cửa sổ C nằm giữa A và B, và thử ở máy nhà.
5. Shortcut khởi động cùng Windows phải trỏ tới Rev5.2 (shortcut cũ trỏ tới Rev5.1).

## Lưu ý đã biết
- Toạ độ nút là toạ độ tương đối so với góc cửa sổ. Nếu bố cục bên trong cửa sổ đổi (thu gọn thanh bên, thanh dấu trang của trình duyệt, đổi mức thu phóng trang) thì nút dịch chỗ dù cửa sổ vẫn đúng. Lúc đó cài lại F9, F10, F11.
- Gemini và GPT trong trình duyệt: tab phải đang hiển thị (tiêu đề cửa sổ chứa chữ Gemini hoặc ChatGPT). Nên dùng cửa sổ riêng, không lẫn với các tab khác.
- Toạ độ lưu riêng cho từng máy và từng bản (`Claude.ini`, `Agy.ini`, `Gemini.ini`, `GPT.ini`).
- Chưa có cách tự phát hiện người dùng ngừng nói. Bấm F8 lần 2 để dừng.

## Chưa làm / có thể làm sau
- Bản tự tìm nút bằng cây giao diện (UI Automation). Chưa làm vì Electron chỉ lộ cây này khi bật hỗ trợ trợ năng.
- Gom bốn bản thành một script chọn ứng dụng B bằng menu.
