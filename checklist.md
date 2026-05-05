# Checklist — Hand-off Readiness (4 trục)

Checklist đánh giá theo **4 trục độc lập**: UI / UX / Nghiệp vụ / Use-case. Đồng bộ với [gate-rules.md](gate-rules.md). Mỗi item có nhãn **Method** (`measured` / `inferred` / `out_of_scope`).

**Quy tắc compute %**:
- Mẫu số = chỉ items `measured` + `inferred` (loại `out_of_scope`).
- Pass khi **% trục ≥ 80%**.
- Quyết định bàn giao = `MIN(% UI, % UX, % NV, % UC)`.

---

## Trục UI (Craft) — 11 items active

Token, type scale, spacing, contrast, icon, state coverage, auto-layout.

| ID | Item | Pass khi | Method | Cách kiểm |
|----|------|----------|--------|-----------|
| UI-01 | Token color | ≥90% color element bind variable | `measured` | `get_variable_defs` + `get_design_context` — đếm fill có variable ID vs raw hex |
| UI-02 | Token typography | ≥90% text dùng text style từ design system | `measured` | `get_design_context` — text node có textStyleId vs none |
| UI-03 | Spacing scale | 100% spacing ∈ {4, 8, 12, 16, 24, 32, 48} (hoặc 8/16/24…) | `measured` | `get_metadata` — đọc itemSpacing/padding của auto-layout, scan magic numbers |
| UI-04 | Type hierarchy | ≤6 distinct font size, hierarchy rõ (H1>H2>H3>body>caption) | `measured` | Đếm distinct fontSize trong tất cả text node |
| UI-05 | Border radius | ≤3 distinct values | `measured` | Đếm distinct cornerRadius |
| UI-06 | Color palette | ≤7 distinct color trong palette chính | `measured` | Đếm distinct fill colors (loại trừ accent <5% usage) |
| UI-07 | Icon consistency | Cùng style (outline / filled / duotone), size ∈ {16, 20, 24, 32} | `inferred` | Style detection từ stroke vs fill — dễ sai khi icon là vector flatten |
| UI-08 | Auto-layout | ≥80% container dùng auto-layout (không absolute) | `measured` | `layoutMode != "NONE"` |
| UI-09 | Constraint set | 100% element trong frame có constraint khác default | `measured` | `constraints.horizontal/vertical` |
| UI-10 | State coverage button | Button có ≥4/5 state (default/hover/pressed/focused/disabled) | `inferred` | Variant detection — phụ thuộc naming |
| UI-11 | State coverage input | Input có ≥4/5 state (default/focused/filled/error/disabled) | `inferred` | Variant detection — phụ thuộc naming |

**Items `out_of_scope` (chuyển §Khuyến nghị test sau bàn giao):**
- UI-12 Zoom 200% test (WCAG 1.4.4) — cần browser

**Ngưỡng pass UI**: ≥80% = ≥9/11 items active.

---

## Trục UX (Usability) — 9 items active

Nielsen heuristics, hierarchy, flow, feedback, error prevention, navigation.

| ID | Item | Pass khi | Method | Cách kiểm |
|----|------|----------|--------|-----------|
| UX-02 | Cognitive load | ≤12 (interactive_count + info_groups×0.5 + decisions×2) trên 1 viewport | `inferred` | Đếm interactive element trong viewport đầu tiên — công thức ước lượng, có sai số |
| UX-05 | Loading state đầy đủ | 100% async action có loading | `inferred` | Tìm variant/frame có "loading" / "skeleton" trong tên |
| UX-06 | Empty state guidance | 100% empty state có icon + message + CTA | `inferred` | Tìm variant "empty" — kiểm 3 thành phần (icon, text, button) |
| UX-07 | Error message chất lượng | 100% error message nói rõ vấn đề + cách sửa | `inferred` | Đọc text error frame — heuristic: tránh "Đã xảy ra lỗi" / "Error 500" |
| UX-08 | Dead-end | 0 dead-end (mọi state có path tiếp) | `inferred` | Walk flow connections — phụ thuộc prototype links có đầy đủ không |
| UX-09 | Escape hatch | Mọi luồng có nút thoát/hủy/quay lại | `inferred` | Tìm Cancel/Back/Close button trong mọi modal/page |
| UX-10 | Confirmation destructive | 100% destructive action có confirm hoặc undo | `inferred` | Tìm action button "Delete/Send/Submit" + dialog tương ứng |
| UX-11 | Consistency platform | Tuân HIG (iOS) / Material (Android, Web) cho nav pattern | `inferred` | Check pattern nav (tab bar position, back gesture, sheet style) |
| UX-12 | Recognition over recall | Quan trọng visible, không bắt user nhớ từ màn trước | `inferred` | Check label, breadcrumb, summary panels |

**Items `out_of_scope` (chuyển §Khuyến nghị test sau bàn giao):**
- UX-01 First-glance test (5 giây) — cần user thật
- UX-03 Hierarchy attention top-3 — cần eye-tracking
- UX-04 Feedback timing <1s/<3s — đo trên build

**Ngưỡng pass UX**: ≥80% = ≥8/9 items active. **Toàn `inferred`** → ghi confidence ±10–15%.

---

## Trục Nghiệp vụ (Business Logic) — 10 items active

Happy / unhappy path, edge case, role / permission, data state, validation, trust signal.

| ID | Item | Pass khi | Method | Cách kiểm |
|----|------|----------|--------|-----------|
| NV-01 | Happy path | 100% bước job map có UI tương ứng | `inferred` | Map từng job step (Define→Resolve) sang frame — phụ thuộc framing P0 |
| NV-02 | Empty data state | Có UI cho zero data | `inferred` | Tìm variant/frame "empty" cho mọi list/data view |
| NV-03 | Network error / timeout | Có UI + retry option | `inferred` | Tìm error variant với retry button |
| NV-04 | Permission denied | Có UI giải thích + hành động tiếp theo | `inferred` | Tìm 403/permission frame |
| NV-05 | Session expired | Có UI cảnh báo + recovery | `inferred` | Tìm session timeout dialog/page |
| NV-06 | Invalid input | Inline validation + format hint trước khi submit | `inferred` | Form input có error variant + helper text |
| NV-07 | Role-based view | Nếu nhiều role: mỗi role có view phù hợp; disabled vs hidden chọn đúng | `inferred` | Tìm các variant theo role (admin, viewer, editor) |
| NV-08 | Data scale | Design xử lý zero / 1 / few / many / max (truncation, pagination) | `inferred` | Có ít nhất 3 trạng thái dữ liệu khác nhau |
| NV-09 | Trust signal | Bước nhạy cảm (payment, PII) có trust signal (lock icon, security note, policy link) | `inferred` | Scan màn payment/login/checkout |
| NV-10 | Confirmation summary | Action không reversible kèm summary (cái gì, ai, bao nhiêu, khi nào) | `inferred` | Confirm dialog hiển thị đầy đủ 4 yếu tố |

**Ngưỡng pass NV**: ≥80% = ≥8/10 items. **Toàn `inferred`** → ghi confidence ±10–15%, **phụ thuộc nặng vào brief từ user**.

---

## Trục Use-case (JTBD Coverage) — 8 items active

User story coverage, AC testable, outcome metrics, không US/UI orphan.

| ID | Item | Pass khi | Method | Cách kiểm |
|----|------|----------|--------|-----------|
| UC-01 | JTBD rõ ràng | Articulate được "Khi X, tôi muốn Y, để Z" | `inferred` | Đọc framing P0 — nếu user khai "audit luôn" → suy luận từ giao diện, sai số cao |
| UC-02 | US ≥2, ≤5 | Số US hợp lý cho scope màn | `measured` | Đếm US trong scratchpad |
| UC-03 | AC testable | Mỗi US có 3–5 AC testable | `inferred` | Đọc AC — kiểm có động từ đo được (hiển thị, nhận, gửi) |
| UC-04 | US coverage | ≥80% US có UI element phục vụ | `inferred` | Map US → UI element, đánh dấu ✅/⚠️/❌ |
| UC-05 | Outcome metrics | Mỗi US có speed/accuracy/satisfaction rõ | `inferred` | Đọc outcome — đảm bảo có ≥1 trong 3 chiều |
| UC-06 | Hypothesis có bằng chứng | Mọi 🔴/🟡 hypothesis trích Baymard/WCAG/Nielsen/cognitive law/data | `inferred` | Đọc hypothesis — kiểm có cite nguồn |
| UC-07 | Không US orphan | Không có US nào không có UI | `inferred` | Mỗi US phải có ít nhất 1 UI element |
| UC-08 | Không UI orphan | Không có UI element nào không phục vụ US (over-design) | `inferred` | Mỗi major UI element phải link tới US-XX |

**Ngưỡng pass UC**: ≥80% = ≥7/8 items.

---

## Tổng quan compute

```
% UI = (pass UI / 11) × 100      ngưỡng pass: ≥9/11 (≥80%)
% UX = (pass UX / 9)  × 100      ngưỡng pass: ≥8/9  (≥88%)
% NV = (pass NV / 10) × 100      ngưỡng pass: ≥8/10 (≥80%)
% UC = (pass UC / 8)  × 100      ngưỡng pass: ≥7/8  (≥87%)

MIN_SCORE = MIN(% UI, % UX, % NV, % UC)
Decision  = áp gate logic trong gate-rules.md
```

### Mức theo % trục

| % trục | Mức | Ý nghĩa |
|--------|-----|---------|
| 90–100 | Xuất sắc | Đạt vượt ngưỡng, sẵn sàng bàn giao |
| 80–89  | Tốt | Đạt ngưỡng pass |
| 65–79  | Trung bình | Chưa đạt, cần cải thiện 2–3 item |
| < 65   | Yếu | Cần rework đáng kể |

### Items `out_of_scope` — không tính vào gate

Liệt kê trong báo cáo dưới phần "Khuyến nghị test sau bàn giao":

| ID | Item | Cách test sau bàn giao |
|----|------|------------------------|
| UI-12 | Zoom 200% — text đọc được, không cắt | Mở build, browser zoom 200%, scan |
| UX-01 | First-glance test | 5 user xem màn 5 giây, hỏi 4 câu (job, CTA, info, escape) |
| UX-03 | Hierarchy attention map | Heatmap eye-tracking hoặc click-test |
| UX-04 | Feedback timing | Đo trên build — Lighthouse / WebPageTest |

---

## Liên kết

- Công thức tính + 3-tầng gate: [gate-rules.md](gate-rules.md)
- Workflow agent: [SKILL.md](SKILL.md) (Cursor) hoặc [claude-agent.md](claude-agent.md) (Claude Code)
- Template báo cáo: [report-template.md](report-template.md)
