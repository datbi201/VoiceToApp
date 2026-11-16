# Bàn giao: VoiceToApp

Cập nhật: 16/11/2026

## Trạng thái hiện tại
- **Rev mới nhất: 5.3**, bốn file: `VoiceToApp_Claude_Rev5.3.ahk`, `VoiceToApp_Agy_Rev5.3.ahk`, `VoiceToApp_Gemini_Rev5.3.ahk`, `VoiceToApp_GPT_Rev5.3.ahk`.
- Rev5.3 sửa lỗi của Rev5.2 (Rev5.2 không khởi động được vì hàm `Beep` trùng tên biến `BEEP`). **Chưa thử trên máy thật.**
- Điểm mới của dòng Rev5.2 trở đi: lưu vị trí, kích thước cửa sổ B, tự đưa về đúng chỗ khi F8 hoặc F12.
- Rev cũ nằm ở `03_ONEDRIVE_BACKUP\revisions` (gồm Rev5.1 và Rev5.2).
- Mẫu chung và script sinh file nằm ở `template\`. Sửa mẫu, rồi chạy `python template\generate.py`. Script này tự kiểm tra trùng tên hàm và biến.
- Commit: bấm đúp `commit_rev.bat` ở thư mục gốc dự án (ngoài repo). Danh tính: `datbi201`, email noreply có mã số.

## Việc đang chờ
1. Người dùng thử Rev5.3 bản Agy: khởi động không lỗi, bấm F9, F10, F11 một lần, tắt cửa sổ, mở lại ở chỗ khác, bấm F8. Cửa sổ phải tự về đúng chỗ.
2. Thử trên màn 2 máy công ty (màn 1: 3440×1440 ở 100%, màn 2: 2160×1440 ở 125%) để xem WinMove có đưa về đúng kích thước không. Nhật ký: `%LOCALAPPDATA%\VoiceToApp\<App>.log`.
3. Bản Gemini và GPT chưa xác nhận tiêu đề cửa sổ thật. Nếu script báo không tìm thấy, rê chuột lên cửa sổ, bấm Ctrl+Shift+F12 để xem tên tiến trình và tiêu đề, rồi sửa `B_CANDIDATES` trong `generate.py`.
4. Thử khi có cửa sổ C nằm giữa A và B, và thử ở máy nhà.
5. Shortcut khởi động cùng Windows phải trỏ tới Rev mới nhất (shortcut cũ trỏ tới Rev5.1 và sẽ hỏng).

## Lưu ý đã biết
- Toạ độ nút là toạ độ tương đối so với góc cửa sổ. Bố cục bên trong cửa sổ đổi (thu gọn thanh bên, thanh dấu trang của trình duyệt, đổi mức thu phóng trang) thì nút dịch chỗ dù cửa sổ vẫn đúng. Lúc đó cài lại F9, F10, F11.
- Gemini và GPT trong trình duyệt: tab phải đang hiển thị (tiêu đề cửa sổ chứa chữ Gemini hoặc ChatGPT). Nên dùng cửa sổ riêng.
- Toạ độ lưu riêng cho từng máy và từng bản (`Claude.ini`, `Agy.ini`, `Gemini.ini`, `GPT.ini`).
- Chưa có cách tự phát hiện người dùng ngừng nói. Bấm F8 lần 2 để dừng.
- Môi trường soạn thảo không có AutoHotkey, nên lỗi chỉ lộ khi người dùng chạy trên Windows. Bộ kiểm tra trùng tên trong `generate.py` chỉ bắt được lỗi trùng tên, không thay cho việc chạy thử.

## Chưa làm / có thể làm sau
- Bản tự tìm nút bằng cây giao diện (UI Automation). Chưa làm vì Electron chỉ lộ cây này khi bật hỗ trợ trợ năng.
- Gom bốn bản thành một script chọn ứng dụng B bằng menu.
