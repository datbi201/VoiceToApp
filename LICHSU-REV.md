# Lịch sử Rev: VoiceToApp

Tên file Rev1.0 đến Rev4.0 đặt theo các bản đã giao trong quá trình làm. Bản Rev3.0 đầu tiên (tìm nút bằng hình ảnh) đã bị ghi đè nên không còn lưu riêng; bản gần nhất của nhánh này là Rev4.0.

| Rev | Ngày | Nội dung | Kết quả |
|---|---|---|---|
| 1.0 | 11/11 | F8: copy chữ trong ô nhập của B, Alt+Tab về A, dán | Chạy tốt |
| 2.0 | 11/11 | F8 bật/tắt mic của B từ A theo toạ độ. F9, F10 cài vị trí. Thêm F11 cho nút dừng, rê chuột trước khi bấm | Chạy tốt |
| 3.0 | 11/11 | Tìm nút bằng hình ảnh để không phụ thuộc vị trí và kích thước cửa sổ | Không ổn định |
| 4.0 | 12/11 | Sửa Rev3.0: ép đưa B lên trên và kiểm tra trước khi gửi phím (tránh gõ nhầm vào cửa sổ C), ghi nhật ký, xoá ô nhập của B bằng Ctrl+A và BackSpace, hỗ trợ hai màn hình (SetCursorPos, tỷ lệ phóng to riêng) | Chạy được ở màn 2 nhưng chậm: 4 giây để bắt đầu, 7-8 giây để dừng |
| 5.1 | 12/11 | Bỏ nhận diện hình ảnh, chỉ dùng toạ độ. Tách hai bản Claude và Agy. Bỏ các chỗ chờ cố định, chờ chữ ổn định bằng copy lặp, đặt `SetWinDelay 0`. Lưu toạ độ ở `%LOCALAPPDATA%`. Dừng khi cửa sổ B đổi kích thước. Thêm tiếng bip | Đã chạy được. Dòng `BEEP := true` gây lỗi trùng tên với hàm `Beep` nên người dùng đã comment dòng này |
| 5.2 | 16/11 | Lưu vị trí, kích thước, trạng thái phóng to của cửa sổ B lúc cài đặt; F8 và F12 tự đưa cửa sổ về đúng chỗ nên không phải cài lại sau khi tắt mở máy hay mở lại ứng dụng. Cài lại nút với kích thước khác thì xoá nút cũ. Thêm bản Gemini và GPT (tìm cửa sổ trình duyệt theo tiêu đề). `BEEP := false` mặc định. Thêm thư mục `template` để sinh 4 bản từ một mẫu | Không chạy được: hàm `Beep` trùng tên biến `BEEP` (lỗi AutoHotkey v2 khi khởi động). Sửa ở Rev5.3 |
| 5.3 | 16/11 | Sửa lỗi Rev5.2: đổi hàm `Beep` thành `PlayBeep`, `Log` thành `WriteLog`. `generate.py` kiểm tra trùng tên trước khi sinh file. `commit_rev.bat` tự xoá Rev cũ đã có bản sao lưu và dùng email noreply có mã số | Chưa thử |

## Quy ước từ Rev5.1
- Tăng 0,1 mỗi lần sửa (5.2, 5.3...). Chỉ lên 6.0 khi người dùng yêu cầu.
- Mỗi Rev mới ghi thêm một dòng vào bảng trên.
