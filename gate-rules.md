# Gate Rules — Quy tắc đánh giá bàn giao thiết kế

File này định nghĩa **ngưỡng cứng**, **công thức tính %**, và **logic quyết định** để agent ra status: READY / READY WITH NOTES / NEEDS REWORK / BLOCKED.

Đọc đầu mỗi review (P0). Tính ở P3.

**Nguyên tắc**: thiết kế đạt **≥80% trên cả 4 trục** mới được bàn giao. Quyết định cuối = `MIN(% UI, % UX, % Nghiệp vụ, % Use-case)`.

---

## Method labels — phân biệt độ tin cậy của từng item

Mỗi item được tag bằng 1 trong 3 nhãn để báo cáo trung thực với khả năng đo thật:

| Nhãn | Định nghĩa | Cách output |
|------|-----------|-------------|
| `measured` | Đo trực tiếp từ Figma MCP data (số đếm, ratio, %) | Hiển thị giá trị + nguồn data |
| `inferred` | Agent judgment dựa heuristic, có sai số ±10–15% | Hiển thị + cảnh báo "ước lượng" |
| `out_of_scope` | Không đo được trên design tĩnh — cần build / user test | **Không tính vào gate**, đưa xuống §"Khuyến nghị test sau bàn giao" |

**Quy tắc compute %**:
- Mẫu số (total) = chỉ đếm items `measured` + `inferred` (items `out_of_scope` bị loại khỏi gate).
- Nếu trục có ≥40% items `inferred` → ghi rõ "score này có sai số ±10%" trong báo cáo.

---

## Kiến trúc 3 tầng gate

```
┌─────────────────────────────────────────────────────┐
│ Tầng 1: HARD GATE     — vi phạm = BLOCKED ngay      │
├─────────────────────────────────────────────────────┤
│ Tầng 2: SCORE GATE    — MIN(4 trục) ≥ 80% mới READY │
├─────────────────────────────────────────────────────┤
│ Tầng 3: SEVERITY GATE — bất kỳ P0 mở = BLOCKED      │
└─────────────────────────────────────────────────────┘

Quyết định cuối = MIN(Tầng 1, Tầng 2, Tầng 3)
```

---

## Tầng 1 — HARD GATE

Vi phạm **bất kỳ 1 mục** dưới đây → **BLOCKED**, dừng compute tầng 2/3, báo cáo lý do và hành động sửa bắt buộc.

| ID | Mục | Ngưỡng | Method | Ghi chú |
|----|-----|--------|--------|---------|
| H1 | Contrast WCAG AA | ≥95% text element đạt 4.5:1 (normal) hoặc 3:1 (large ≥18pt hoặc 14pt bold) | `inferred` | Đo trên text-on-background; agent phải walk hierarchy để tìm bg fill, có thể sai khi background nhiều layer |
| H2 | Tap target | ≥95% interactive element đạt 24×24 CSS px (WCAG 2.5.8). Mobile khuyến nghị 44×44pt | `inferred` | Cần nhận diện đâu là "interactive" — Figma không tag rõ button vs frame, dựa naming + component |
| H3 | Primary CTA | Tồn tại + visible above fold + duy nhất / màn | `inferred` | Phải phân biệt primary vs secondary qua style; multiple primary CTA → user phân vân, fail |
| H4 | Empty state | Mọi list / data view có empty state | `inferred` | Phụ thuộc layer naming/variant naming; nếu thiếu convention → có thể miss |
| H5 | Error state | Mọi form input + mọi async action có error state | `inferred` | Cùng phụ thuộc naming/variant |
| H6 | Loading state | Mọi async action có loading indicator | `inferred` | Skeleton / spinner / progress |
| H7 | Destructive action | Có confirmation dialog HOẶC undo affordance | `inferred` | Cross-frame analysis (button "Delete" → có dialog tương ứng?) — agent dễ miss |
| H8 | Layer naming | ≤20% layer mang tên mặc định (`Frame N`, `Group N`, `Rectangle N`) | `measured` | Đếm trực tiếp qua get_metadata |
| H9 | Detached components | ≤5% instance bị detach | `measured` | get_design_context phân biệt component vs detached |
| H10 | Hardcoded color | ≤10% color không bind variable / token | `measured` | get_variable_defs cho biết bind hay không |
| H11 | Auto-layout | ≥80% container dùng auto-layout (không absolute positioning) | `measured` | Metadata có layoutMode |

**Tổng hard gate**: 11 items — 4 `measured` + 7 `inferred`. Báo cáo BLOCKED phải nói rõ item nào đo chính xác, item nào ước lượng.

### Tính toán Hard Gate

Mỗi mục H1–H11:
- **Đếm tổng** element thuộc loại đó (ví dụ H1: tổng text node)
- **Đếm vi phạm** (ví dụ H1: text node có contrast < 4.5:1)
- **Tỉ lệ đạt** = (tổng - vi phạm) / tổng × 100%
- **So với ngưỡng** ở cột "Ngưỡng"

Nếu >1 mục fail → liệt kê tất cả trong báo cáo, không chỉ cái đầu.

### Output khi BLOCKED

```
═══════════════════════════════════
HAND-OFF DECISION: ⛔ BLOCKED
═══════════════════════════════════
Tầng 1 (Hard Gate):    ❌ FAIL
  - H1 Contrast: 78% (cần ≥95%) [inferred ±10%]
    → 12 text node fail: [list node IDs]
  - H2 Tap target: 91% (cần ≥95%) [inferred ±10%]
    → 8 icon button <44×44

Tầng 2 (Score):        N/A (chưa qua tầng 1)
Tầng 3 (Severity):     N/A

Hành động bắt buộc:
  1. Sửa 12 text node contrast <4.5:1 (xem screenshot-Hard-H1.png)
  2. Tăng size 8 icon button lên ≥44×44 (Material §accessibility)
═══════════════════════════════════
```

---

## Tầng 2 — SCORE GATE (4 trục)

Chỉ tính khi qua tầng 1. Mỗi trục có checklist riêng. Items `out_of_scope` bị loại khỏi mẫu số. **% trục = (số item pass / tổng item active) × 100**.

### Trục UI (Craft) — 11 items active (1 out_of_scope)

| # | Item | Pass khi | Method |
|---|------|----------|--------|
| UI-01 | Token color | ≥90% color element bind variable | `measured` |
| UI-02 | Token typography | ≥90% text dùng text style từ design system | `measured` |
| UI-03 | Spacing scale | 100% spacing ∈ {4, 8, 12, 16, 24, 32, 48} (hoặc 8/16/24…) | `measured` |
| UI-04 | Type hierarchy | ≤6 distinct font size, hierarchy rõ (H1>H2>H3>body>caption) | `measured` |
| UI-05 | Border radius | ≤3 distinct values | `measured` |
| UI-06 | Color palette | ≤7 distinct color trong palette chính | `measured` |
| UI-07 | Icon consistency | Cùng style (outline / filled / duotone), size ∈ {16, 20, 24, 32} | `inferred` |
| UI-08 | Auto-layout | ≥80% container dùng auto-layout | `measured` |
| UI-09 | Constraint set | 100% element trong frame có constraint | `measured` |
| UI-10 | State coverage button | Button có ≥4/5 state (default/hover/pressed/focused/disabled) | `inferred` |
| UI-11 | State coverage input | Input có ≥4/5 state (default/focused/filled/error/disabled) | `inferred` |
| ~~UI-12~~ | ~~Zoom 200% test~~ | ~~Text vẫn đọc được, không cắt nội dung (WCAG 1.4.4)~~ | `out_of_scope` → §Khuyến nghị test |

**Ngưỡng pass trục UI: ≥80% (≥9/11 item active)**

### Trục UX (Usability) — 9 items active (3 out_of_scope)

| # | Item | Pass khi | Method |
|---|------|----------|--------|
| ~~UX-01~~ | ~~First-glance test~~ | ~~Trả lời được 4/4 câu trong 5 giây~~ | `out_of_scope` → §Khuyến nghị test |
| UX-02 | Cognitive load | ≤12 (interactive_count + info_groups×0.5 + decisions×2) trên 1 viewport | `inferred` |
| ~~UX-03~~ | ~~Hierarchy attention~~ | ~~Primary CTA top-3 attention~~ | `out_of_scope` → §Khuyến nghị test |
| ~~UX-04~~ | ~~Feedback timing~~ | ~~<1s instant / <3s loading / >3s progress với ETA~~ | `out_of_scope` → §Khuyến nghị test |
| UX-05 | Loading state đầy đủ | 100% async action có loading | `inferred` |
| UX-06 | Empty state guidance | 100% empty state có icon + message + CTA | `inferred` |
| UX-07 | Error message chất lượng | 100% error message nói rõ vấn đề + cách sửa | `inferred` |
| UX-08 | Dead-end | 0 dead-end (mọi state có path tiếp) | `inferred` |
| UX-09 | Escape hatch | Mọi luồng có nút thoát/hủy/quay lại | `inferred` |
| UX-10 | Confirmation destructive | 100% destructive action có confirm hoặc undo | `inferred` |
| UX-11 | Consistency platform | Tuân HIG (iOS) / Material (Android, Web) cho navigation pattern | `inferred` |
| UX-12 | Recognition over recall | Quan trọng visible, không bắt user nhớ từ màn trước | `inferred` |

**Ngưỡng pass trục UX: ≥80% (≥8/9 item active)** — vì toàn `inferred`, sai số ±10–15%

### Trục Nghiệp vụ (Business Logic) — 10 items active

| # | Item | Pass khi | Method |
|---|------|----------|--------|
| NV-01 | Happy path | 100% bước job map có UI tương ứng | `inferred` |
| NV-02 | Empty data state | Có UI cho zero data | `inferred` |
| NV-03 | Network error / timeout | Có UI + retry option | `inferred` |
| NV-04 | Permission denied | Có UI giải thích + hành động tiếp theo | `inferred` |
| NV-05 | Session expired | Có UI cảnh báo + recovery | `inferred` |
| NV-06 | Invalid input | Inline validation + format hint trước khi submit | `inferred` |
| NV-07 | Role-based view | Nếu nhiều role: mỗi role có view phù hợp; disabled vs hidden chọn đúng | `inferred` |
| NV-08 | Data scale | Design xử lý zero / 1 / few / many / max (truncation, pagination) | `inferred` |
| NV-09 | Trust signal | Bước nhạy cảm (payment, PII) có trust signal (lock icon, security note, policy link) | `inferred` |
| NV-10 | Confirmation summary | Action không reversible kèm summary (cái gì, ai, bao nhiêu, khi nào) | `inferred` |

**Ngưỡng pass trục Nghiệp vụ: ≥80% (≥8/10 item)** — toàn `inferred`, phụ thuộc convention naming và brief từ user

### Trục Use-case (JTBD Coverage) — 8 items active

| # | Item | Pass khi | Method |
|---|------|----------|--------|
| UC-01 | JTBD rõ ràng | Articulate được "Khi X, tôi muốn Y, để Z" | `inferred` |
| UC-02 | US ≥2, ≤5 | Số US hợp lý cho scope màn | `measured` |
| UC-03 | AC testable | Mỗi US có 3–5 AC testable | `inferred` |
| UC-04 | US coverage | ≥80% US có UI element phục vụ (✅ Tốt) | `inferred` |
| UC-05 | Outcome metrics | Mỗi US có speed/accuracy/satisfaction rõ | `inferred` |
| UC-06 | Hypothesis có bằng chứng | Mọi 🔴/🟡 hypothesis trích Baymard/WCAG/Nielsen/cognitive law/data | `inferred` |
| UC-07 | Không US orphan | Không có US nào không có UI | `inferred` |
| UC-08 | Không UI orphan | Không có UI element nào không phục vụ US (over-design) | `inferred` |

**Ngưỡng pass trục Use-case: ≥80% (≥7/8 item)**

### Mapping điểm trục → mức

| % trục | Mức |
|--------|-----|
| 90–100 | Xuất sắc |
| 80–89  | Tốt (đạt ngưỡng pass) |
| 65–79  | Trung bình (chưa đạt) |
| < 65   | Yếu |

---

## Khuyến nghị test sau bàn giao (items out_of_scope)

Các check dưới đây không đo được trên design tĩnh — agent KHÔNG đưa vào gate %, nhưng phải liệt kê trong báo cáo dưới phần "Khuyến nghị test sau bàn giao" để designer/QA biết.

| ID | Item | Cách test | Công cụ gợi ý |
|----|------|-----------|---------------|
| UI-12 | Zoom 200% — text vẫn đọc được, không cắt nội dung | Mở build trên trình duyệt, zoom 200%, scan từng vùng text | Browser zoom, WAVE |
| UX-01 | First-glance test (5 giây) | Cho 5 user xem màn 5 giây rồi hỏi: "Màn này để làm gì? CTA chính? Thông tin chính? Cách thoát?" — đếm câu đúng | UsabilityHub, Maze |
| UX-03 | Hierarchy attention map | Heatmap eye-tracking hoặc click-test — primary CTA cần nằm top-3 attention | Hotjar, Attention Insight |
| UX-04 | Feedback timing | Đo trên build với DevTools — <1s instant / <3s loading / >3s progress | Lighthouse, WebPageTest |

---

## Tầng 3 — SEVERITY GATE

| Tình trạng P0/P1 | Quyết định |
|------------------|-----------|
| Có ≥1 P0 mở (chưa fix) | BLOCKED, bất kể điểm |
| 0 P0, ≤3 P1 | OK (chuyển tầng 2 quyết định) |
| 0 P0, 4–7 P1 | Hạ 1 mức (READY → READY WITH NOTES) |
| 0 P0, >7 P1 | NEEDS REWORK, bất kể điểm |

### Quy tắc nâng severity

Một finding mặc định severity từ ma trận tần suất × tác động, nhưng **bắt buộc nâng** trong các trường hợp:

| Điều kiện | Nâng tới |
|-----------|---------|
| Vi phạm hard gate H1–H7 | P0 |
| Chặn job step Execute hoặc Confirm | ≥ P1 |
| Khiến user không đạt outcome chính | P0 |
| Vi phạm WCAG AA rõ ràng | ≥ P1 |
| Có thể dẫn đến mất tiền / sai data quan trọng | P0 |
| US-XX bị mark ❌ Chưa đáp ứng | ≥ P1 |
| Finding chỉ ảnh hưởng polish / consistency nhẹ | P2 |

---

## Logic quyết định cuối

```
1. Compute Tầng 1 (Hard Gate)
   - Nếu FAIL bất kỳ H1–H11 → BLOCKED. STOP.

2. Compute Tầng 2 (Score Gate)
   - Tính % cho 4 trục (loại items out_of_scope khỏi mẫu số)
   - Mark trục có ≥40% items inferred → confidence ±10%
   - MIN_SCORE = MIN(4 trục)
   - Nếu MIN_SCORE ≥ 90 và mọi trục ≥ 80 → tier_2 = READY
   - Nếu MIN_SCORE 80–89 và mọi trục ≥ 80 → tier_2 = READY WITH NOTES
   - Nếu bất kỳ trục < 80 → tier_2 = NEEDS REWORK

3. Compute Tầng 3 (Severity Gate)
   - Nếu P0 mở > 0 → tier_3 = BLOCKED
   - Nếu P1 > 7 → tier_3 = NEEDS REWORK
   - Nếu P1 4–7 → tier_3 = downgrade 1 step
   - Else → tier_3 = pass-through

4. Quyết định cuối = MIN(tier_1, tier_2, tier_3)
   Theo thứ tự: BLOCKED < NEEDS REWORK < READY WITH NOTES < READY
```

---

## Output — Gate Decision Box

Mọi báo cáo BẮT ĐẦU bằng box này, ngay sau title:

```
═══════════════════════════════════════════════
HAND-OFF DECISION: [READY / READY WITH NOTES / NEEDS REWORK / BLOCKED]
═══════════════════════════════════════════════

📊 Score 4 trục:
  UI         ████████░░  82% [Tốt]   (10/11 active, 2 inferred)
  UX         █████████░  91% [Xuất sắc] (8/9 active, 9 inferred ±15%)
  Nghiệp vụ  ██████░░░░  64% [Trung bình] ← KÉO TỔNG XUỐNG (10 inferred ±15%)
  Use-case   ████████░░  85% [Tốt]   (7/8 active, 7 inferred)
  ─────────────────────────────────
  MIN        64% — chưa đạt ngưỡng 80%

🎯 Độ tin cậy: 4 measured / 32 inferred / 4 out_of_scope
   ⚠️ Trục UX, Nghiệp vụ có ≥40% items inferred — score ±10–15%

🚦 3 tầng gate:
  Tầng 1 Hard Gate:  ✅ PASS
  Tầng 2 Score Gate: ❌ NEEDS REWORK (Nghiệp vụ 64% < 80%)
  Tầng 3 Severity:   ⚠️ 1 P0 mở, 5 P1 mở

⚠️ Hành động bắt buộc trước bàn giao:
  1. Sửa P0 [F-003]: thiếu confirmation dialog ở action xóa
  2. Bổ sung 4 unhappy path ở trục Nghiệp vụ
     (network error, session expired, permission denied, invalid input)
  3. Sau khi fix → audit lại để check lại Score Gate

📈 Khoảng cách đến READY:
  - Trục Nghiệp vụ cần +16 điểm (2 item nữa)
  - Đóng 1 P0 + đóng ít nhất 2 P1

📋 Khuyến nghị test sau bàn giao (out_of_scope, không gate):
  - UI-12 zoom 200% (browser test)
  - UX-01 first-glance test (5 user, UsabilityHub/Maze)
  - UX-03 hierarchy attention (Hotjar heatmap)
  - UX-04 feedback timing (Lighthouse trên build)
═══════════════════════════════════════════════
```

---

## Workflow tính trong P3

```
1. Đọc scratchpad full, đếm finding theo severity
2. Với mỗi trục UI / UX / NV / UC:
   a. Mở checklist tương ứng (11/9/10/8 item active)
   b. Đánh dấu pass/fail mỗi item dựa trên evidence từ Phase 2
   c. Tag mỗi item với method (measured / inferred)
   d. Tính % = (pass / total active) × 100
   e. Nếu inferred ratio ≥40% → mark confidence ±10%
3. Compute Tầng 1: kiểm 11 hard gate
4. Compute Tầng 2: MIN(4 trục) + check ngưỡng riêng
5. Compute Tầng 3: đếm P0 + P1
6. Quyết định cuối = MIN
7. Liệt kê items out_of_scope vào §Khuyến nghị test sau bàn giao
8. Render Gate Decision Box
9. Chèn lên đầu báo cáo, trước Framing
```

---

## Quy tắc tinh thần

- **MIN, không AVERAGE**: 1 trục yếu kéo cả thiết kế. Tránh "trục mạnh đỡ trục yếu".
- **80% không phải target lười**: 100% là trạng thái lý tưởng không tồn tại trên design tĩnh. 80% nghĩa là "đủ chín để dev không phải hỏi lại quá 2 lần / màn".
- **Hard gate không thương lượng**: contrast, tap target, error/empty state thiếu — không có chỗ cho "ship trước, fix sau" trong những thứ này.
- **Severity gate chống "điểm cao gian lận"**: 1 P0 chí mạng vô hiệu mọi điểm số. Tránh tình huống "82% tổng nhưng không gửi được tiền".
- **Trung thực với phương pháp**: nếu item là `inferred` thì ghi rõ; nếu `out_of_scope` thì đừng giả vờ đo được trên design tĩnh. Báo cáo `measured` cao + `inferred` thấp đáng tin hơn báo cáo điểm số đẹp nhưng toàn ước lượng.
- **Khoảng cách đến READY** phải hiển thị trong Gate Decision Box: designer biết cần +bao nhiêu điểm ở trục nào → action rõ ràng.
