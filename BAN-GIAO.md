# Bàn giao: VoiceToApp

Cập nhật: 17/11/2026

## Trạng thái hiện tại
- **Rev mới nhất: 5.4**, bốn file: `VoiceToApp_Claude_Rev5.4.ahk`, `VoiceToApp_Agy_Rev5.4.ahk`, `VoiceToApp_Gemini_Rev5.4.ahk`, `VoiceToApp_GPT_Rev5.4.ahk`.
- Rev5.4 thêm **nút mic nổi** trên ô nhập chữ (bấm nút = F8, nhấp nháy đỏ khi ghi âm). Rev5.3 (sửa lỗi trùng tên hàm Beep) cũng **chưa thử trên máy thật**, nên cả hai cần thử.
- Điểm mới của dòng Rev5.2 trở đi: lưu vị trí, kích thước cửa sổ B, tự đưa về đúng chỗ khi F8 hoặc F12.
- Rev cũ nằm ở `03_ONEDRIVE_BACKUP\revisions` (gồm Rev5.1, 5.2 và 5.3).
- Mẫu chung và script sinh file nằm ở `template\`. Sửa mẫu, rồi chạy `python template\generate.py`. Script này tự kiểm tra trùng tên hàm và biến.
- Commit: bấm đúp `commit_rev.bat` ở thư mục gốc dự án (ngoài repo). Danh tính: `datbi201`, email noreply có mã số.

## Việc đang chờ
0. Thử nút mic nổi của Rev5.4 (chưa ai bấm thử thật): bấm vào ô nhập của Zalo, Telegram, Messenger, Word, Notepad xem nút mic có hiện không. Bấm nút phải bật ghi âm ở B rồi quay về A, nút nhấp nháy đỏ. Bấm lần nữa phải dừng và dán chữ. Nếu nút hiện sai chỗ hoặc không hiện, rê chuột lên ô nhập, bấm Ctrl+Shift+F12 (xem `uia=` và `caret=`), hoặc mở `%LOCALAPPDATA%\VoiceToApp\<App>.log` (mỗi lần bấm chuột có một dòng `Bam chuot ... [lý do]`). Chỉnh trong mẫu: `LooksLikeInput`.
1. Người dùng thử Rev5.3 bản Agy: khởi động không lỗi, bấm F9, F10, F11 một lần, tắt cửa sổ, mở lại ở chỗ khác, bấm F8. Cửa sổ phải tự về đúng chỗ.
2. Thử trên màn 2 máy công ty (màn 1: 3440×1440 ở 100%, màn 2: 2160×1440 ở 125%) để xem WinMove có đưa về đúng kích thước không. Nhật ký: `%LOCALAPPDATA%\VoiceToApp\<App>.log`.
3. Bản Gemini và GPT chưa xác nhận tiêu đề cửa sổ thật. Nếu script báo không tìm thấy, rê chuột lên cửa sổ, bấm Ctrl+Shift+F12 để xem tên tiến trình và tiêu đề, rồi sửa `B_CANDIDATES` trong `generate.py`.
4. Thử khi có cửa sổ C nằm giữa A và B, và thử ở máy nhà.
5. Shortcut khởi động cùng Windows phải trỏ tới Rev mới nhất (shortcut cũ trỏ tới Rev5.1 và sẽ hỏng).

## Lưu ý đã biết
- Nút mic nổi dùng UI Automation để hỏi phần tử đang có focus. Với ứng dụng Chromium/Electron (Zalo, Messenger bản web, Claude...) lần hỏi đầu có thể làm ứng dụng bật chế độ trợ năng, hơi chậm một chút. Nếu phiền, đặt `MIC_USE_UIA := false` (khi đó chỉ nhận ô nhập qua caret + con trỏ chữ I, ít chính xác hơn) hoặc `MIC_ICON := false` để tắt hẳn nút.
- Nút mic hiện ở trên bên phải điểm vừa bấm, ẩn khi bạn chuyển sang cửa sổ khác hoặc bấm ra ngoài ô nhập (trừ lúc đang ghi âm thì giữ nguyên để còn bấm dừng).
- Toạ độ nút là toạ độ tương đối so với góc cửa sổ. Bố cục bên trong cửa sổ đổi (thu gọn thanh bên, thanh dấu trang của trình duyệt, đổi mức thu phóng trang) thì nút dịch chỗ dù cửa sổ vẫn đúng. Lúc đó cài lại F9, F10, F11.
- Gemini và GPT trong trình duyệt: tab phải đang hiển thị (tiêu đề cửa sổ chứa chữ Gemini hoặc ChatGPT). Nên dùng cửa sổ riêng.
- Toạ độ lưu riêng cho từng máy và từng bản (`Claude.ini`, `Agy.ini`, `Gemini.ini`, `GPT.ini`).
- Chưa có cách tự phát hiện người dùng ngừng nói. Bấm F8 lần 2 để dừng.
- Môi trường soạn thảo không có AutoHotkey, nên lỗi chỉ lộ khi người dùng chạy trên Windows. Bộ kiểm tra trùng tên trong `generate.py` chỉ bắt được lỗi trùng tên, không thay cho việc chạy thử.

## Chưa làm / có thể làm sau
- Bản tự tìm nút bằng cây giao diện (UI Automation). Chưa làm vì Electron chỉ lộ cây này khi bật hỗ trợ trợ năng.
- Gom bốn bản thành một script chọn ứng dụng B bằng menu.
