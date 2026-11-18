# Quy tắc dự án VoiceToApp

Claude Code tự nạp file này khi mở phiên ở thư mục `01_REPO_GITHUB`. Đây là nguồn quy tắc duy nhất của dự án.

## Mục đích
Script AutoHotkey v2 cho Windows. Người dùng ở lại phần mềm A (Zalo, Telegram, Messenger, Word...). Script bật mic ở phần mềm B (Claude hoặc Antigravity), chờ B chuyển giọng nói thành văn bản đã sửa câu, rồi dán chữ về A. Có bốn bản song song: `Claude`, `Agy`, `Gemini`, `GPT`.

## Cấu trúc thư mục
- `01_REPO_GITHUB` (git, kho riêng tư): chỉ giữ **Rev mới nhất** của cả bốn bản, cùng `CLAUDE.md`, `BAN-GIAO.md`, `LICHSU-REV.md`.
- `03_ONEDRIVE_BACKUP\revisions`: các Rev cũ. Không đưa lên git.
- Toạ độ nút và nhật ký của từng máy nằm ở `%LOCALAPPDATA%\VoiceToApp\` (file `.ini`, `.log`). Không đưa lên git.

## Quy tắc đánh số Rev
- Hiện tại là **Rev5.9**. Mỗi lần sửa tăng một bậc: 5.2, 5.3, 5.4...
- Chỉ lên **6.0** khi người dùng nói rõ "lên 6.0".
- Bốn bản luôn cùng số Rev, luôn sửa cùng lúc. Chỉ khác hai dòng cấu hình: `APP_NAME` và danh sách cửa sổ cần tìm `B_CANDIDATES`.
- Tên file: `VoiceToApp_<Claude|Agy|Gemini|GPT>_Rev<số>.ahk`. Dòng đầu phần chú thích trong file ghi đúng số Rev.
- Cách làm: chỉ sửa mẫu `template\VoiceToApp_template.ahk`, đổi `REV` trong `template\generate.py`, rồi chạy `python template\generate.py` để sinh cả bốn bản. Không sửa tay từng bản.

## Quy trình khi có Rev mới
1. Đầu phiên: `git pull --rebase origin master`, rồi đọc `BAN-GIAO.md` và `LICHSU-REV.md`.
2. Copy Rev cũ sang `03_ONEDRIVE_BACKUP\revisions`.
3. Đối chiếu đủ file ở bản sao lưu, rồi mới xoá Rev cũ khỏi `01_REPO_GITHUB`.
4. Thêm Rev mới vào `01_REPO_GITHUB`. Cập nhật `LICHSU-REV.md` và `BAN-GIAO.md`.
5. Commit và push theo kiểu fast-forward. Không dùng `force push`. Lịch sử git vẫn giữ mọi Rev cũ.
6. Rev nào chưa chạy thử trên máy thật thì ghi rõ "chưa thử" trong `BAN-GIAO.md`.

## Quyết định kỹ thuật đã chốt (đừng đổi nếu chưa hỏi)
- Chỉ dùng toạ độ tương đối trong cửa sổ B. Không nhận diện hình ảnh vì quá chậm (Rev4.0: 4 giây để bắt đầu, 7-8 giây để dừng).
- Đặt con trỏ bằng `SetCursorPos` (toạ độ vật lý). Cách này đúng trên máy có hai màn hình với tỷ lệ phóng to khác nhau.
- Trước khi bấm, kiểm tra cửa sổ dưới con trỏ có cùng tiến trình với B. Trước khi gửi phím, kiểm tra B đang active. Không bao giờ gửi Ctrl+A, Ctrl+C vào cửa sổ khác.
- Rev5.2: lưu vị trí, kích thước và trạng thái phóng to của cửa sổ B lúc cài đặt (file ini ở `%LOCALAPPDATA%\VoiceToApp\<App>.ini`, không mất khi tắt máy). Mỗi lần bật hoặc dừng ghi âm, script tự đưa cửa sổ về đúng chỗ (WinMove hai lần để ổn định giữa các màn hình khác tỷ lệ). Chỉ dừng và nhắc cài lại khi kích thước vẫn không khớp hoặc vị trí lưu nằm ngoài màn hình. Cài lại một nút với kích thước cửa sổ khác thì các nút cũ bị xoá.
- Gemini và GPT chạy trong trình duyệt (hoặc ứng dụng ChatGPT): tìm cửa sổ theo tiêu đề kèm tên tiến trình, thử lần lượt các mẫu trong `B_CANDIDATES`. Nên dùng cửa sổ trình duyệt riêng (Install as app / Open as window) để bố cục ổn định.
- Chờ chữ bằng cách copy lặp đến khi hai lần liên tiếp giống nhau, không chờ cố định.
- Xoá ô nhập của B bằng Ctrl+A rồi BackSpace (phím Delete không xoá được).
- Tiếng bip tắt mặc định (`BEEP := false`). Hàm phát bip tên `PlayBeep`, hàm ghi nhật ký tên `WriteLog`. AutoHotkey v2 không cho tên biến trùng tên hàm (không phân biệt hoa thường, kể cả hàm dựng sẵn như `Log`). Lỗi này chỉ lộ khi chạy trên Windows (Rev5.2 hỏng vì hàm `Beep` trùng biến `BEEP`). Vì vậy `template\generate.py` tự kiểm tra trùng tên trước khi ghi file. Không bỏ bước này, và khi thêm hàm hoặc biến mới thì đặt tên không trùng nhau.
- Rev5.4: nút mic nổi (`MicInit`, `MicShowAt`, `MicTick`, `LooksLikeInput`, `UiaProbe`). Nút là cửa sổ AutoHotkey `WS_EX_NOACTIVATE` nên không cướp focus của A; bấm nút gọi lại `ToggleVoice()` như phím bật/tắt ghi âm. Hook chuột `~LButton` chỉ kiểm tra rồi hiện hoặc ẩn nút, không chặn chuột. Chỉ số hàm UIA (vtable) ghi chú ngay trên `UiaProbe`; đừng đổi nếu chưa thử. Rev5.5: `ClassifyInput` theo quy tắc của AI_Voice_Typer_Rev2_9 (Edit/ComboBox, ARIA textbox, Document ghi được, Group/Custom/Pane ghi được) để nhận ô chat Chromium/Electron như Zalo; cài đặt nút mic và danh sách ứng dụng loại trừ lưu ở `Settings.ini` (chung cho 4 bản), sửa qua cửa sổ mở từ menu khay. `ToggleVoice` giờ là lớp bọc có cờ `toggling` quanh `ToggleCore` để F8 và nút mic không chạy chồng.
- Rev5.6: bỏ phím cố định F9 đến F12 (xung đột Word). Cài nút Mic, ô nhập, nút Dừng qua cửa sổ Cài đặt (`ShowSettings`, `StartCalib`: tạm đăng ký Enter, NumpadEnter, Escape bằng `Hotkey()` để lấy vị trí con trỏ, xong thì tắt). Phím bật/tắt ghi âm đăng ký động bằng `ApplyToggleKey` (mặc định F8, đổi hoặc tắt trong Cài đặt, lưu ở `Settings.ini` mục `[Keys]`). Mở cửa sổ Cài đặt thì tạm tắt phím này để ô chọn phím bắt được phím. Không thêm lại phím cố định nếu chưa hỏi.
- Rev5.9: không bao giờ hỏi UI Automation về cửa sổ của chính script (`IsOwnWindow`), vì truy vấn UIA vào cửa sổ vừa bị huỷ gây "Invalid memory read/write". Hộp lỗi hiện dòng `Exit` ở cuối file là dòng thoát ngầm của luồng khởi động, không phải hàm gây lỗi; xem `<App>.log` để biết thao tác ngay trước.
- Rev5.8: tạm dừng/tiếp tục bằng bấm trái biểu tượng khay. Đừng dùng `Suspend` hoặc `A_TrayMenu.ClickCount` (Rev5.7 làm vậy và bị báo không ổn định). Dùng `paused`, `OnMessage(0x404, TrayNotify)`, `ApplyPausedState`, `SetTrayState`. Biểu tượng khay vẽ bằng `BuildTrayIcon`.

## Môi trường thử
- Máy công ty: hai màn hình, màn 1 là 3440×1440 ở 100%, màn 2 là 2160×1440 ở 125%. Phải thử cả khi B nằm ở màn 2.
- Máy nhà: một màn hình 4K.
- Thử thêm tình huống có cửa sổ C nằm giữa A và B.

## Cách làm việc với người dùng
- Trả lời bằng tiếng Việt, ngắn, rõ, ít bảng. Người dùng nghe bằng đọc văn bản thành tiếng.
- Mỗi lần giao bản mới: nêu Rev, thay đổi chính, và việc người dùng cần thử.
- Chỉ code dự án này đưa lên GitHub, kho riêng tư.

## Thực tế trong thư mục dự án của bạn
- Dự án gốc: `D:\Google Drive\Other computers\NEC\My Projects\Voice to app`. Kho git nằm ở `01_REPO_GITHUB`, nhánh `master`, remote `origin`.
- `02_LOCAL_RUNTIME`: thư mục runtime cũ (ảnh mẫu, ini, log). Rev5.1 không dùng nữa, ini và log nằm ở `%LOCALAPPDATA%\VoiceToApp`.
- Bốn launcher ở thư mục gốc: `run_voicetoapp.bat` (Antigravity), `run_voicetoapp_claude.bat`, `run_voicetoapp_gemini.bat`, `run_voicetoapp_gpt.bat`. Khi có Rev mới, phải sửa đường dẫn trong cả bốn. Các bản dùng chung phím bật/tắt ghi âm (mặc định F8), chỉ chạy một bản mỗi lúc.
- Đừng để file shortcut `.lnk` trong repo (đã thêm `*.lnk` vào `.gitignore`). Shortcut khởi động cùng Windows phải trỏ tới Rev mới nhất.
- Lưu ý: file `VoiceToApp (claude)_v5.ahk` và `(agy)_v5.ahk` có nội dung giống hệt Rev4.0 (nhận diện hình ảnh). Đừng coi đó là Rev5.

## Commit tự động khi có Rev mới
- Mỗi lần tạo Rev mới, Claude tự lo phần commit, không chờ người dùng nhắc.
- Có shell trong kho (ví dụ Claude Code): làm đủ quy trình ở trên, rồi `git add -A`, commit và `git push origin master`. Danh tính chỉ đặt trong repo (không dùng `--global`): tên `datbi201`, email `343996192+datbi201@users.noreply.github.com` (địa chỉ noreply có mã số của tài khoản GitHub, giống commit đầu tiên của kho). Cuối commit ghi `Co-Authored-By` của Claude và dòng `Claude-Session`.
- Không có shell (chat Claude, chỉ ghi được file): ghi `commit_message.txt` vào thư mục gốc dự án (cạnh `commit_rev.bat`, ngoài repo). Dòng đầu là `Rev<số>: <tóm tắt>`, cuối file có hai dòng trailer. Rồi nhắc người dùng bấm đúp `commit_rev.bat`. Script này tự đặt danh tính, tự xoá các Rev cũ trong repo nếu đã có bản sao lưu giống hệt ở `03_ONEDRIVE_BACKUP\revisions` (nên phải ghi bản sao lưu trước), `git add -A`, commit bằng `commit_message.txt`, rồi push.
- Không dùng `--force`. Nếu commit hoặc push lỗi thì báo người dùng, không tự xử lý bằng cách ép.

