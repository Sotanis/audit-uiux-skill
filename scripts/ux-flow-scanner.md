# UX Flow Scanner — Quét Dead-end / Escape Hatch / Continuity

> Agent đọc file này ở P0/P2 để tăng chất lượng đánh giá UX-08 (dead-end), UX-09 (escape hatch), và hỗ trợ audit flow nhiều màn. Script này cố gắng dựa evidence; nếu thiếu prototype links, phải ghi rõ mức tin cậy.

## Mục đích

- Dựng “flow map” tối thiểu từ scope hiện có.
- Tìm **dead-end candidates** và thiếu **escape hatch** theo evidence.
- Xuất **journey map** dạng bảng (screen → action → next → expected feedback) để report dễ hành động.
- Tránh kết luận sai khi chỉ nhìn 1 screenshot/frame.

## Khi nào chạy

- **P0**: khi scope là 1 flow hoặc 1 page có nhiều frames.
- **P2**: trước khi kết luận UX-08/UX-09.

## Input cần có

- `get_metadata(fileKey, nodeId)` cho scope (page/section/flow container)
- Nếu metadata có prototype link fields (tuỳ MCP version), dùng chúng; nếu không có, fallback.

## Bước 1 — Xác định screens trong scope

1. Liệt kê các top-level frames (candidate screens).
2. Với mỗi screen, xác định:
   - `Screen ID`
   - `Screen name`
   - Danh sách CTA/back/close/cancel nodes (candidate navigation nodes)

## Bước 2 — Nhận diện Escape Hatch trong mỗi screen

Escape hatch = có ít nhất 1 trong:
- Back (`←`, `Back`, `Quay lại`)
- Close (`×`, `Đóng`, `Close`, `Dismiss`)
- Cancel (`Hủy`, `Huỷ`, `Cancel`)
- Home/Exit (`Trang chủ`, `Thoát`, `Exit`)

Evidence record:
- `nodeId`
- `label`
- `location hint` (nếu có)

## Bước 3 — Dựng edge (navigation) theo 2 chế độ

### 3.1 Mode A — Prototype-linked (confidence high)

Nếu metadata có thông tin link/transition:
- tạo edge `screen -> targetScreen` cho mỗi navigation node có link

### 3.2 Mode B — Fallback inferred (confidence low/medium)

Nếu không có prototype:
- coi “flow order” là theo user prompt (nếu user gửi nhiều URL theo thứ tự)
- hoặc suy luận rất nhẹ theo naming: `Step_1`, `Step_2`, `Confirm`, `Success`, `Error`

**Bắt buộc** ghi rõ `flow_confidence = low` nếu dùng fallback.

## Bước 4 — Dead-end detection (evidence-first)

Dead-end candidate nếu:
- Screen có CTA/next step rõ nhưng **không tìm thấy** link/target (Mode A), và
- Screen cũng **không có escape hatch**

Trong Mode B, chỉ đánh **⚠️ candidate**, không kết luận fail chắc chắn.

## Bước 4.5 — Tính toán Tỷ lệ % (Measured Metric)
Để chuyển UX-08 và UX-09 thành tiêu chí `measured`, cần tính 2 tỷ lệ:
- **Tỷ lệ Dead-end**: `Số màn hình là Dead-end / Tổng số màn hình trong scope`. (Chỉ tính trong Mode A. Mode B sẽ ghi % candidate).
- **Tỷ lệ Escape Hatch**: `Số Modal/Screen phụ có escape hatch / Tổng số Modal/Screen phụ`.

## Bước 5 — Output bảng (scratchpad)

```markdown
### UX Flow Scan Results (Scanner)

**Flow confidence**: [high|medium|low] (prototype links: [yes/no])
**Tỷ lệ Dead-end**: [X]% ([số màn hình fail]/[tổng màn hình])
**Tỷ lệ Escape Hatch**: [Y]% ([số modal đạt]/[tổng modal])

| Screen | Escape hatch | Outgoing edges | Dead-end risk | Evidence |
|--------|--------------|---------------|--------------|----------|
| `Checkout` (12:34) | ✅ back:`56:78` | → `Confirm` | low | back nodeId |
| `Confirm` (90:12) | ❌ | (none) | ⚠️ high | no back/close, no link |
```

### Journey Map (Proxy)

| Step | Screen (id) | Primary action | Expected feedback/state | Next screen | Notes |
|------|-------------|----------------|--------------------------|------------|-------|
| 1 | `Checkout` (12:34) | `CTA_Primary` (11:22) | loading → success/ error | `Confirm` | if error: show retry |
| 2 | `Confirm` (90:12) | `Xác nhận` (33:44) | success toast + redirect | `Success` | missing escape hatch? |

Rules:
- Nếu thiếu prototype links: điền “Next screen” theo user-provided order hoặc để `—` và đánh confidence low.
- “Expected feedback/state” phải align với UX-05/06/07 và state coverage scan.

## Bước 6 — Mapping sang checklist

- **UX-08 Dead-end**:
  - PASS nếu Tỷ lệ Dead-end = 0% (Mode A).
  - FAIL nếu > 0%.
  - Tag method: `measured (prototype)` nếu Mode A; `inferred` nếu Mode B.
- **UX-09 Escape hatch**:
  - PASS nếu Tỷ lệ Escape Hatch = 100%.
  - FAIL nếu < 100%.
  - Tag method: `measured (scan)` nếu tìm thấy rõ ràng các node escape; fallback `inferred`.

## Finding templates

```text
🟡 [UX][<screenId>][challenges H?][US-XX][img:F-XXX]: screen thiếu escape hatch hoặc có dead-end risk — flow scan confidence <level>
```

Chụp screenshot screen + vùng header/footer nơi escape hatch nên nằm.

