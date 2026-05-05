# Naming Scanner — Hướng dẫn Quét và Sửa Tên Layer Tự Động

> Agent đọc file này ở P0 (trước khi vào P1). Thực hiện theo 4 bước dưới đây để chuẩn hóa dữ liệu trước khi chấm điểm.

## Mục đích
Giúp các tiêu chí chấm điểm (đặc biệt là H4, H5, H6 - Empty/Error/Loading) đạt độ chính xác 100% bằng cách phát hiện các layer đặt tên lộn xộn, cảnh báo cho user, và tự động sửa tên trên Figma trước khi chấm.

## Bước 1 — Quét và Nhận diện (Semantic Semantic)
Sau khi có kết quả `get_metadata`, Agent quét toàn bộ cây thư mục để tìm các node mang ý nghĩa State (Trạng thái) hoặc CTA nhưng đặt tên sai chuẩn.

Sử dụng AI Semantic matching để nhận diện dựa trên các từ khóa (Kể cả tiếng Việt không dấu/có dấu):

| Ý nghĩa Node | Từ khóa thường gặp (Sai chuẩn) | Tên Chuẩn Bắt Buộc (Standard Naming) | Phục vụ cho Gate |
| :--- | :--- | :--- | :--- |
| **Empty State** | `rong`, `trong`, `ko-co-data`, `no-data`, `blank`, `chua-cap-nhat`, `Group 12` (có text "không có") | Kết thúc bằng `_empty` (VD: `State_empty`, `List_empty`) | H4 |
| **Error State** | `loi`, `canh-bao`, `fail`, `alert`, `Group 45` (màu đỏ, icon alert) | Kết thúc bằng `_error` (VD: `State_error`, `Input_error`) | H5 |
| **Loading State** | `xoay-xoay`, `dang-tai`, `skeleton`, `shimmer`, `load` | Kết thúc bằng `_loading` (VD: `State_loading`) | H6 |
| **Disabled State** | `nut-mo`, `xam`, `disable`, `khong-bam-duoc` | Kết thúc bằng `_disabled` (VD: `Button_disabled`) | UX-05 |
| **Primary CTA** | `nut-chinh`, `luu`, `xac-nhan`, `Rectangle 1` (button to nhất) | Bắt đầu bằng `CTA_Primary` | H3 |

## Bước 2 — Tạm Dừng và Cảnh Báo (Alert)
Nếu phát hiện ≥1 layer sai chuẩn, Agent **TUYỆT ĐỐI KHÔNG đi tiếp vào P1**. 
Agent phải in ra một bảng Cảnh báo cho user và **TẠM DỪNG (PAUSE)**.

**Format in ra màn hình:**
```markdown
⚠️ **PHÁT HIỆN LAYER ĐẶT TÊN CHƯA CHUẨN**
Trước khi tiến hành Audit, tôi phát hiện [N] layer có tên không đúng chuẩn Naming Convention, điều này sẽ làm giảm độ chính xác của báo cáo. 

Dưới đây là danh sách đề xuất chuẩn hóa:

| Node ID | Tên hiện tại trên Figma | Đề xuất đổi thành (Chuẩn) | Lý do nhận diện |
|---------|-------------------------|---------------------------|-----------------|
| 123:45  | `ko-co-data`            | `State_empty`             | Phát hiện text "Không có dữ liệu" bên trong |
| 78:90   | `Rectangle 12`          | `CTA_Primary`             | Hình chữ nhật lớn nhất, chứa text "Lưu lại" |

👉 **Vui lòng phản hồi:** Bạn có đồng ý với đề xuất này không? (Gõ "Đồng ý" để tôi tự động sửa trực tiếp trên Figma và tiếp tục, hoặc cung cấp tên khác nếu bạn muốn).
```

## Bước 3 — Chờ Duyệt và Sửa Trực Tiếp (Apply Fix)
1. Agent chờ user phản hồi.
2. Nếu user gõ "Đồng ý" (hoặc các lệnh tương đương):
   - Agent gọi công cụ `use_figma` của Figma MCP để thao tác trực tiếp trên canvas. Agent sẽ gửi lệnh đổi tên (`rename`) các layer có Node ID tương ứng theo đúng cột "Đề xuất đổi thành".
3. Nếu user yêu cầu bỏ qua 1 layer nào đó: Cập nhật lại danh sách theo ý user và đổi tên các layer còn lại.

## Bước 4 — Resume Audit
Sau khi MCP báo sửa tên thành công:
1. Lấy lại `get_metadata` mới nhất (để cập nhật tên mới).
2. In ra thông báo: *"Đã sửa xong [N] layer trên Figma. Bắt đầu tiến trình Audit..."*
3. Tiếp tục bước Load KB (P1) và chấm điểm như bình thường.
