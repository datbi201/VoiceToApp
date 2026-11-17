# Bàn giao: VoiceToApp

Cập nhật: 17/11/2026

## Trạng thái hiện tại
- **Rev mới nhất: 5.4**, bốn file: `VoiceToApp_Claude_Rev5.6.ahk`, `VoiceToApp_Agy_Rev5.6.ahk`, `VoiceToApp_Gemini_Rev5.6.ahk`, `VoiceToApp_GPT_Rev5.6.ahk`.
- Rev5.6 thêm **nút mic nổi** trên ô nhập chữ (bấm nút = bật/tắt ghi âm, nhấp nháy đỏ khi ghi âm). Rev5.6 bỏ F9-F12 cố định, cài vị trí nút qua cửa sổ Cài đặt, phím bật/tắt ghi âm đổi/tắt được. Rev5.3 (sửa lỗi trùng tên hàm Beep) cũng **chưa thử trên máy thật**, nên cả hai cần thử.
- Điểm mới của dòng Rev5.2 trở đi: lưu vị trí, kích thước cửa sổ B, tự đưa về đúng chỗ mỗi lần bật/dừng ghi âm.
- Rev cũ nằm ở `03_ONEDRIVE_BACKUP\revisions` (gồm Rev5.1 đến 5.5).
- Mẫu chung và script sinh file nằm ở `template\`. Sửa mẫu, rồi chạy `python template\generate.py`. Script này tự kiểm tra trùng tên hàm và biến.
- Commit: bấm đúp `commit_rev.bat` ở thư mục gốc dự án (ngoài repo). Danh tính: `datbi201`, email noreply có mã số.

## Việc đang chờ
0. Thử nút mic nổi của Rev5.6: đã thử thật ở Notepad và Chrome. **Zalo đã chạy tốt theo người dùng** (đã xác nhận Zalo hiện mic), rồi Telegram, Messenger, Word. Bấm nút phải bật ghi âm ở B rồi quay về A, nút nhấp nháy đỏ. Bấm lần nữa phải dừng và dán chữ. Nếu nút hiện sai chỗ hoặc không hiện, vào Cài đặt > Phím tắt > "Xem thông tin cửa sổ dưới con trỏ" (xem `uia=` và `caret=`), hoặc mở `%LOCALAPPDATA%\VoiceToApp\<App>.log` (mỗi lần bấm chuột có một dòng `Bam chuot ... [lý do]`). Chỉnh trong mẫu: `LooksLikeInput`.
1. Người dùng thử Rev5.6 bản Agy: khởi động không lỗi, mở Cài đặt > Vị trí nút, cài nút Mic, ô nhập, nút Dừng (rê chuột lên nút rồi bấm Enter), tắt cửa sổ, mở lại ở chỗ khác, bấm nút mic. Cửa sổ phải tự về đúng chỗ. **Luồng bấm Enter chưa thử bằng phím thật.**
2. Thử trên màn 2 máy công ty (màn 1: 3440×1440 ở 100%, màn 2: 2160×1440 ở 125%) để xem WinMove có đưa về đúng kích thước không. Nhật ký: `%LOCALAPPDATA%\VoiceToApp\<App>.log`.
3. Bản Gemini và GPT chưa xác nhận tiêu đề cửa sổ thật. Nếu script báo không tìm thấy, rê chuột lên cửa sổ, mở Cài đặt > Phím tắt > "Xem thông tin cửa sổ dưới con trỏ" để xem tên tiến trình và tiêu đề, rồi sửa `B_CANDIDATES` trong `generate.py`.
4. Thử khi có cửa sổ C nằm giữa A và B, và thử ở máy nhà.
5. Shortcut khởi động cùng Windows phải trỏ tới Rev mới nhất (shortcut cũ trỏ tới Rev5.1 và sẽ hỏng).

## Lưu ý đã biết
- Word dùng F8 (mở rộng vùng chọn) và Ctrl+Shift+F8 đến F12 cho nhiều lệnh nên đổi sang Ctrl+Shift chỉ giảm xung đột. Cách chắc chắn: bỏ tick phím tắt, chỉ dùng nút mic nổi.
- Bản Rev5.1 cũ đang chạy (nếu còn) vẫn giữ F8 đến F12 và tranh phím. Tắt nó trước khi chạy bản mới.
- Ứng dụng loại trừ (không hiện nút mic) mặc định: claude.exe, chatgpt.exe, antigravity.exe, gemini.exe. Sửa trong cửa sổ Cài đặt nút mic.
- Nút mic nổi dùng UI Automation để hỏi phần tử đang có focus. Với ứng dụng Chromium/Electron (Zalo, Messenger bản web, Claude...) lần hỏi đầu có thể làm ứng dụng bật chế độ trợ năng, hơi chậm một chút. Nếu phiền, bỏ tick "Dùng UI Automation" hoặc bỏ tick "Hiện nút mic nổi" trong cửa sổ **Cài đặt nút mic** (menu khay hệ thống, bấm chuột phải biểu tượng script). Các hằng `MIC_*` trong script chỉ là giá trị mặc định cho lần chạy đầu.
- Nút mic hiện ở trên bên phải điểm vừa bấm, ẩn khi bạn chuyển sang cửa sổ khác hoặc bấm ra ngoài ô nhập (trừ lúc đang ghi âm thì giữ nguyên để còn bấm dừng).
- Toạ độ nút là toạ độ tương đối so với góc cửa sổ. Bố cục bên trong cửa sổ đổi (thu gọn thanh bên, thanh dấu trang của trình duyệt, đổi mức thu phóng trang) thì nút dịch chỗ dù cửa sổ vẫn đúng. Lúc đó cài lại ba vị trí ở Cài đặt > Vị trí nút.
- Gemini và GPT trong trình duyệt: tab phải đang hiển thị (tiêu đề cửa sổ chứa chữ Gemini hoặc ChatGPT). Nên dùng cửa sổ riêng.
- Toạ độ lưu riêng cho từng máy và từng bản (`Claude.ini`, `Agy.ini`, `Gemini.ini`, `GPT.ini`).
- Chưa có cách tự phát hiện người dùng ngừng nói. Bấm nút mic (hoặc phím tắt) lần 2 để dừng.
- Môi trường soạn thảo không có AutoHotkey, nên lỗi chỉ lộ khi người dùng chạy trên Windows. Bộ kiểm tra trùng tên trong `generate.py` chỉ bắt được lỗi trùng tên, không thay cho việc chạy thử.

## Chưa làm / có thể làm sau
- Bản tự tìm nút bằng cây giao diện (UI Automation). Chưa làm vì Electron chỉ lộ cây này khi bật hỗ trợ trợ năng.
- Gom bốn bản thành một script chọn ứng dụng B bằng menu.
