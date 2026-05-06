# UX State Scanner — Quét Loading/Empty/Error/Success có hệ thống

> Agent đọc file này ở P0/P2 (sau `get_metadata` + `get_design_context`). Mục tiêu: giảm miss các state quan trọng cho UX-05/06/07 và Hard Gate H4/H5/H6.

## Mục đích

- Thay vì chỉ dựa vào *tên layer*, script này dùng **nhiều tín hiệu** để nhận diện state:
  - Keyword trong tên layer (VN/EN, có dấu/không dấu)
  - Keyword trong **text nodes** bên trong
  - “Dấu hiệu UI” phổ biến (retry CTA, icon cảnh báo, spinner/skeleton)
- Xuất **bảng coverage theo từng screen/frame** + nodeId evidence để agent có thể:
  - Pass/Fail minh bạch (có/không có evidence)
  - Chụp screenshot đúng node khi tạo finding

## Khi nào chạy

- **P0**: sau khi fetch Figma data và chạy naming-scanner (nếu có rename).
- **P2** (Lens UX): đối chiếu coverage trước khi kết luận UX-05/06/07.

## Input cần có

- `get_metadata(fileKey, nodeId)` cho frame/page scope
- `get_design_context(fileKey, nodeId)` để biết component/token (nếu cần)

## Bước 1 — Chọn scope quét

1. Xác định danh sách **top-level frames** trong scope (thường là các node type `FRAME` dưới page/section).
2. Với mỗi frame, quét cây con (descendants) để tìm candidate state.

## Bước 2 — Nhận diện candidates theo 3 loại tín hiệu

### 2.1 Tín hiệu A — Tên layer (name signal)

Match case-insensitive, bỏ dấu (normalize) nếu có thể. Các pattern gợi ý:

- **Loading**: `loading`, `dang-tai`, `skeleton`, `shimmer`, `progress`, `spinner`, `wait`
- **Empty**: `empty`, `no-data`, `khong-co`, `trong`, `rong`, `blank`, `chua-co`, `0-items`
- **Error**: `error`, `fail`, `loi`, `warning`, `alert`, `canh-bao`, `timeout`, `network`
- **Success**: `success`, `done`, `thanh-cong`, `hoan-tat`, `confirmed`, `complete`

### 2.2 Tín hiệu B — Text nodes (text signal)

Tìm text nodes bên trong candidate group/frame chứa các cụm:

- **Empty copy**: `Không có dữ liệu`, `Chưa có`, `Không tìm thấy`, `No results`, `Nothing here`
- **Error copy**: `Đã xảy ra lỗi`, `Không thể`, `Thử lại`, `Retry`, `Something went wrong`, `Timeout`
- **Success copy**: `Thành công`, `Hoàn tất`, `Đã lưu`, `Success`

### 2.3 Tín hiệu C — UI pattern (pattern signal)

Các dấu hiệu “gần như chắc chắn”:

- **Retry CTA**: button/link có label `Thử lại`, `Retry`, `Tải lại`, `Reload`
- **Spinner/skeleton**: node tên `spinner`, `loading`, hoặc instance/component trùng thư viện (nếu context trả về)
- **Alert icon**: vector/icon với tên chứa `warning`, `error`, `alert`, `exclamation`

## Bước 3 — Chuẩn hoá evidence record

Với mỗi candidate state tìm thấy, ghi lại:

- `Frame ID` (top-level frame đang quét)
- `Candidate Node ID`
- `Type`: `loading | empty | error | success`
- `Signals`: list (name/text/pattern)
- `Snippet`: 1–2 text snippets (nếu có)
- `Confidence`: `high` nếu có ≥2 signal type hoặc có pattern signal; `medium` nếu chỉ 1 signal; `low` nếu mơ hồ

## Bước 4 — Tạo bảng coverage (đưa vào scratchpad)

```markdown
### UX State Coverage Results (Scanner)

| Screen/Frame | Loading | Empty | Error | Success | Evidence (nodeId sample) | Notes |
|-------------|---------|-------|-------|---------|---------------------------|-------|
| `Home` (12:34) | ✅ | ✅ | ⚠️ | ❌ | empty:`56:78` error:`—` | Error chỉ thấy toast text, cần frame rõ |
| `Search` (98:10) | ✅ | ✅ | ✅ | ✅ | loading:`11:22` empty:`33:44` error:`55:66` success:`77:88` | confidence high |

Rules:
- ✅ = thấy ≥1 evidence confidence high/medium
- ⚠️ = chỉ có evidence low hoặc “toast-only”
- ❌ = không thấy evidence trong scope
```

## Bước 5 — Mapping sang checklist/gate

- **Hard Gate**
  - H4 Empty state: PASS nếu mọi list/data view quan trọng có ✅ (không phải chỉ ⚠️)
  - H5 Error state: PASS nếu form + async action quan trọng có ✅
  - H6 Loading state: PASS nếu mọi async action quan trọng có ✅
- **UX checklist**
  - UX-05/06/07 ưu tiên dựa trên bảng coverage này.

## Bước 6 — Tạo finding “missing evidence”

Nếu thiếu state hoặc chỉ có ⚠️:

```text
🟡 [UX][<frameId>][challenges H?][US-XX][img:F-XXX]: thiếu/không rõ state <loading|empty|error|success> — scanner không tìm thấy evidence
```

Chụp screenshot frame + vùng liên quan (nếu có candidate ⚠️).

## Lưu ý

- Nếu design dùng **component library** cho state, hãy ưu tiên evidence từ `INSTANCE`/component name.
- Nếu state chỉ xuất hiện dưới dạng toast mà không có frame/variant, đánh dấu ⚠️ và đề xuất thêm frame/variant để hand-off rõ ràng.

