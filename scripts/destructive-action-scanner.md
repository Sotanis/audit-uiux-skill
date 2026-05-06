# Destructive Action Scanner — Quét hành động nguy hiểm & đối chiếu Confirm/Undo

> Agent đọc file này ở P0/P2 để tăng chất lượng check **Hard Gate H7** và **UX-10** (confirmation destructive). Mục tiêu: giảm miss do agent chỉ nhìn một frame hoặc chỉ dựa naming.

## Mục đích

- Tự động lập danh sách các **destructive / irreversible actions** trong scope.
- Đối chiếu xem có **confirmation dialog** hoặc **undo affordance** tương ứng không.
- Xuất evidence nodeId để chụp screenshot và tạo finding rõ ràng.

## Khi nào chạy

- **P0**: sau khi `get_metadata` (và sau naming-scanner nếu có rename).
- **P2 (UX lens)**: trước khi kết luận pass/fail UX-10.

## Input cần có

- `get_metadata(fileKey, nodeId)` (cây layer + text)
- Nếu có prototype links hoặc frames dialog riêng, include trong scope quét (khuyến nghị quét toàn page/flow, không chỉ 1 frame).

## Bước 1 — Tạo “Action Lexicon” (từ khóa)

Match case-insensitive, hỗ trợ VN/EN:

- **Delete/Remove**: `xóa`, `xoá`, `delete`, `remove`, `gỡ`, `bỏ`, `loại bỏ`
- **Reset/Clear**: `đặt lại`, `reset`, `clear`, `xoá hết`
- **Cancel/Discard**: `hủy`, `huỷ`, `cancel`, `discard`, `bỏ thay đổi`
- **Submit/Send/Transfer** *(có thể irreversible tùy nghiệp vụ)*: `gửi`, `submit`, `send`, `chuyển`, `transfer`, `xác nhận`, `confirm`

## Bước 2 — Nhận diện action nodes

Từ metadata, thu thập candidate action nodes theo:

- Node name chứa từ khóa action (button/cta/menu-item)
- Hoặc node có text label match lexicon (text node bên trong button)
- Ưu tiên `INSTANCE` (button/menu item) và các group chứa text label rõ

Ghi record:
- `Action Node ID`
- `Action Label` (text)
- `Frame/Context` (parent frame id)
- `Action Type` (delete/reset/cancel/submit/transfer/unknown)

## Bước 3 — Tìm evidence confirm/undo

Với mỗi action, tìm trong scope các bằng chứng:

### 3.1 Confirmation dialog evidence

Tìm frame/group có:
- Title/text chứa: `Bạn có chắc`, `Xác nhận`, `Confirm`, `Are you sure`
- Và có 2 CTA: `Hủy/Cancel` + `Xóa/Delete` hoặc `Đồng ý/Confirm`

### 3.2 Undo evidence

Tìm toast/snackbar text chứa:
- `Hoàn tác`, `Undo`, `Khôi phục`, `Restore`

### 3.3 Mapping heuristic (không hoàn hảo)

Nếu có prototype links:
- Action node → dialog frame node là mapping mạnh (confidence high)

Nếu không có prototype:
- Mapping theo “cùng từ khóa” (label match) + “gần trong cùng frame/page” (confidence medium)

## Bước 4 — Output bảng kết quả (scratchpad)

```markdown
### Destructive Action Coverage Results (Scanner)

| # | Action (label) | Node ID | Type | Confirm evidence | Undo evidence | Status | Notes |
|---|----------------|--------|------|------------------|-------------|--------|------|
| 1 | "Xóa khách hàng" | 12:34 | delete | dialog:`56:78` | — | ✅ PASS | confidence high |
| 2 | "Đặt lại bộ lọc" | 90:12 | reset | — | toast:`33:44` | ✅ PASS | undo present |
| 3 | "Gửi yêu cầu" | 22:11 | submit | — | — | ⚠️ REVIEW | có thể irreversible tuỳ domain |
| 4 | "Xóa" | 77:66 | delete | — | — | ❌ FAIL | thiếu confirm/undo |
```

Rules:
- ✅ PASS: có confirm hoặc undo (confidence >= medium)
- ❌ FAIL: không thấy confirm/undo evidence
- ⚠️ REVIEW: action có thể irreversible nhưng thiếu context domain (đưa vào NV/UC questions hoặc đề xuất confirm)

## Bước 5 — Mapping sang gate/checklist

- **Hard Gate H7**: FAIL nếu có bất kỳ action type `delete/reset` rõ ràng mà Status = ❌ FAIL.
- **UX-10**: FAIL nếu destructive actions không có confirm/undo.

## Bước 6 — Finding templates

```text
🔴 [UX][<actionNodeId>][challenges H?][US-XX][img:F-XXX]: destructive action thiếu confirmation/undo — "<label>"
```

Chụp screenshot action node + (nếu có) dialog/undo evidence.

## Lưu ý

- Với “submit/send/transfer”: nếu domain không rõ, đánh ⚠️ REVIEW thay vì kết luận fail ngay; đề xuất “confirm summary” trong NV-10.
- Nếu action nằm trong menu/overflow, cần chụp thêm parent container để có ngữ cảnh.

