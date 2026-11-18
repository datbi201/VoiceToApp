# Bàn giao: VoiceToApp

Cập nhật: 18/11/2026

## Trạng thái hiện tại
- **Rev mới nhất: 5.9**, bốn file: `VoiceToApp_Claude_Rev5.9.ahk`, `VoiceToApp_Agy_Rev5.9.ahk`, `VoiceToApp_Gemini_Rev5.9.ahk`, `VoiceToApp_GPT_Rev5.9.ahk`. Bốn launcher ở thư mục gốc mở Rev5.9.
- Rev5.9 sửa lỗi "Critical Error: Invalid memory read/write" khi bấm "Cài" nút thứ 3 trong Cài đặt (báo ngày 18/11, bản Gemini Rev5.8): script không còn hỏi UI Automation về cửa sổ của chính nó (nút mic, Cài đặt) và không kiểm tra ô nhập khi đang mở Cài đặt hoặc đang cài vị trí. Nguyên nhân là suy luận từ nhật ký (chưa tái hiện được lỗi): bấm "Cài" huỷ ngay cửa sổ Cài đặt trong lúc truy vấn UIA vào chính nó. Nếu lỗi còn, gửi dòng cuối của `<App>.log`.
- Rev5.8 (làm lại tính năng tạm dừng của Rev5.7 từ nền Rev5.6): bấm trái một lần vào biểu tượng khay = tạm dừng, biểu tượng đỏ; bấm lần nữa = tiếp tục, biểu tượng xanh. Dùng biến `paused` riêng, **không** dùng `Suspend` hay `ClickCount` như Rev5.7. Bắt thẳng thông báo của biểu tượng khay (`OnMessage(0x404)`: bấm trái nhả = đổi trạng thái, bấm đúp nuốt, chống bấm trong 500 ms). Biểu tượng khay tự vẽ thành `%LOCALAPPDATA%\VoiceToApp\tray_<Rev>_run.ico` và `_paused.ico`. Đang ghi âm mà bấm khay thì kết thúc lượt ghi (dán chữ về A) rồi mới tạm dừng; nếu không dừng được thì không tạm dừng.
- Rev5.7 (do agy làm, dùng `Suspend`) bị người dùng báo hoạt động không ổn định (clip SnowShot 18/11), đã thay bằng Rev5.8. Rev5.7 nằm ở `03_ONEDRIVE_BACKUP\revisions`.
- Kiểm tra Rev5.8 trên AutoHotkey v2.0.31: cả bốn bản nạp không lỗi. Bản Claude chạy bài thử có mô phỏng thông báo bấm khay (bấm trái, bấm liền trong 500 ms, bấm đúp, đang ghi âm, đang xử lý, bật/tắt nút mic trong lúc tạm dừng): trạng thái, phím tắt, nút mic, tên menu, tooltip đổi đúng. Biểu tượng khay đã vẽ ra và xem được (xanh, đỏ). **Chưa thử bằng chuột thật vào biểu tượng khay** (máy thử bị khoá màn hình hoặc người dùng đang làm việc) và chưa xem được clip lỗi của Rev5.7.
- Rev5.6 bỏ F9-F12 cố định, cài vị trí nút qua cửa sổ Cài đặt và cho phép đổi hoặc tắt phím ghi âm. Nút mic nổi xuất hiện cạnh ô nhập chữ và nhấp nháy đỏ khi ghi âm.
- Điểm mới của dòng Rev5.2 trở đi: lưu vị trí, kích thước cửa sổ B, tự đưa về đúng chỗ mỗi lần bật/dừng ghi âm.
- Rev cũ nằm ở `03_ONEDRIVE_BACKUP\revisions` (gồm Rev5.1 đến 5.8).
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
- Bộ kiểm tra trùng tên trong `generate.py` chạy khi sinh bản mới. Trên Windows có AutoHotkey v2, dùng thêm chế độ kiểm tra cú pháp và chạy thử thao tác trên bản mới.

## Chưa làm / có thể làm sau
- Bản tự tìm nút bằng cây giao diện (UI Automation). Chưa làm vì Electron chỉ lộ cây này khi bật hỗ trợ trợ năng.
- Gom bốn bản thành một script chọn ứng dụng B bằng menu.
