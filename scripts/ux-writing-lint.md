# UX Writing Lint — Quét chất lượng microcopy/CTA/error message theo rule

> Agent đọc file này ở P0/P2 để tăng chất lượng đánh giá **UX Writing** và đặc biệt là checklist **UX-07 (Error message chất lượng)**. Đây là “lint” theo rule (không phải NLP/sentiment).

## Mục đích

- Giảm phụ thuộc vào “đọc tay” và giảm bỏ sót lỗi copy phổ biến.
- Tạo **bảng evidence** (nodeId + text snippet + rule violated) để:
  - Tạo finding nhanh và nhất quán
  - Chụp screenshot đúng vùng có vấn đề

## Khi nào chạy

- **P0**: sau `get_metadata` / `get_design_context` (để có text nodes đầy đủ).
- **P2 (Lens UX)**: trước khi kết luận UX-07 và trước khi viết section “Phân tích UX Writing”.

## Input cần có

- `get_metadata(fileKey, nodeId)` cho scope
- (Tuỳ chọn) `get_design_context` để biết text style / token (không bắt buộc)

## Bước 1 — Thu thập text nodes trọng tâm

Từ metadata, thu thập text nodes thuộc nhóm:
- Error message (caption/error text)
- Empty state message
- CTA labels (primary/secondary)
- Form labels, helper text, placeholder

## Bước 2 — Rule set (scan theo pattern)

### 2.1 Error message quality (UX-07)

Fail patterns (ví dụ):
- Quá chung chung: `Đã xảy ra lỗi`, `Có lỗi xảy ra`, `Something went wrong`
- Code/system noise: `Error 500`, `Exception`, `Null`, `Timeout` *(hiển thị trực tiếp cho end-user)*
- Không có hướng dẫn: chỉ nói lỗi, không có “làm gì tiếp”

Pass heuristic (gợi ý):
- Có **nguyên nhân** (ở mức user hiểu)
- Có **hành động tiếp theo** (Retry/Back/Contact/Check connection)
- Ngôn ngữ phù hợp persona (B2C vs B2B)

### 2.2 CTA clarity

Flag patterns:
- CTA mơ hồ: `OK`, `Đồng ý`, `Tiếp tục`, `Lưu` *(không object)*
- 2 CTA cạnh nhau dùng từ quá giống nhau gây nhầm (Save/Save & Close)

### 2.3 Empty state copy

Flag nếu empty state message:
- Không nêu rõ “trống vì sao”
- Không có gợi ý hành động (CTA hoặc next step)

### 2.4 Terminology consistency (rule-based)

Flag nếu trong scope có các cặp thuật ngữ cùng nghĩa nhưng khác chữ:
- `Xóa` vs `Gỡ` vs `Remove` vs `Delete`
- `Đặt lại` vs `Reset`
- `Hủy` vs `Bỏ`

## Bước 3 — Output bảng lint (scratchpad)

```markdown
### UX Writing Lint Results (Scanner)

| # | Node ID | Type | Text snippet | Rule | Severity hint | Suggested fix |
|---|---------|------|--------------|------|---------------|---------------|
| 1 | 12:34 | error_message | "Đã xảy ra lỗi" | UXW-ERR-01 generic_error | 🟡 | Nêu rõ lỗi + CTA "Thử lại" |
| 2 | 56:78 | cta_label | "Lưu" | UXW-CTA-01 ambiguous_cta | 🟢 | "Lưu bộ lọc" / "Lưu thay đổi" |
| 3 | 90:12 | empty_state | "Không có dữ liệu" | UXW-EMP-01 no_next_step | 🟡 | Thêm hướng dẫn + CTA tạo mới |
```

Rule IDs gợi ý:
- UXW-ERR-01 generic_error
- UXW-ERR-02 system_noise
- UXW-ERR-03 no_next_step
- UXW-CTA-01 ambiguous_cta
- UXW-CTA-02 conflicting_ctas
- UXW-EMP-01 no_next_step
- UXW-TERM-01 inconsistent_terms
```

## Bước 4 — Mapping sang checklist/report

- **UX-07**: FAIL nếu có ≥1 lỗi UXW-ERR-01/02/03 trong các error states quan trọng của scope.
- **Section “Phân tích UX Writing”** trong báo cáo: tổng hợp các rule vi phạm + ví dụ nodeId.

## Finding template

```text
🟡 [UX][<nodeId>][supports H?][US-XX][img:F-XXX]: error message chung chung — "<snippet>" (UXW-ERR-01)
```

Chụp screenshot vùng error + ngữ cảnh xung quanh.

