# Friction Scanner — Proxy đo “hesitation/backtracking risk” từ layout & CTA density

> Agent đọc file này ở P0/P2 để tăng chất lượng đánh giá UX-02 (cognitive load) và tìm “friction hotspots” theo proxy (không có event log thật).

## Mục đích

- Bắt các nguyên nhân UX hay dẫn đến hesitation/backtracking:
  - Quá nhiều quyết định trên viewport đầu
  - Nhiều CTA cạnh tranh cùng trọng số
  - Nhóm thông tin không rõ (grouping kém)
- Xuất bảng evidence nodeId để tạo finding nhất quán.

## Khi nào chạy

- **P0**: sau `get_metadata`
- **P2 (Lens UX)**: dùng kết quả để hỗ trợ UX-02 và finding về hierarchy/decision overload

## Input cần có

- `get_metadata(fileKey, nodeId)` (frame size, node bounding boxes nếu có)

## Bước 1 — Ước lượng “decision points” và “interactive density”

Trong scope frame (viewport đầu tiên):
- **interactive_count**: số node interactive (dùng cùng tiêu chí với tap-target checker)
- **decision_points**: số “nhóm lựa chọn” (radio group, segmented control, multi-CTA cluster, filter panel)
- **info_groups**: số nhóm nội dung (cards/sections) trong viewport đầu

## Bước 2 — Proxy score (khớp checklist UX-02)

Tính:

```
UX02_score = interactive_count + info_groups × 0.5 + decision_points × 2
```

Pass khi `UX02_score ≤ 12`.

## Bước 3 — Detect “competing CTAs”

Flag nếu trong cùng viewport:
- Có ≥2 CTA có kích thước/visual weight tương đương (khó xác định primary)
- Có CTA label mơ hồ + CTA phụ cạnh nhau

## Bước 4 — Output bảng (scratchpad)

```markdown
### Friction Scan Results (Scanner)

| Screen/Frame | interactive | info_groups | decision_points | UX02_score | Pass? | Hotspots (nodeId sample) |
|--------------|------------:|------------:|----------------:|-----------:|:-----:|--------------------------|
| `Filter` (12:34) | 14 | 6 | 3 | 14 + 3 + 6 = 23 | ❌ | CTA cluster:`56:78`, filter-group:`90:12` |

Notes:
- interactive_count nên lấy theo interactive registry (button/input/toggle/chip/tab/menu-item…)
- decision_points tính 1 cho mỗi cụm lựa chọn lớn (radio/segmented/filter panel)
```

## Bước 5 — Mapping

- **UX-02**: nếu bảng scan cho thấy UX02_score > 12 → FAIL hoặc tạo finding 🟡/🔴 tuỳ ảnh hưởng job step.
- **Hard Gate H3 (Primary CTA)**: kết hợp với “competing CTAs” để cảnh báo nguy cơ multiple primary CTA.

## Finding template

```text
🟡 [UX][<frameId>][challenges H?][US-XX][img:F-XXX]: cognitive load cao (UX02_score=<n> > 12) — quá nhiều quyết định trên viewport đầu
```

