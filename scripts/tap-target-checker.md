# Tap Target Checker — Hướng dẫn đo kích thước vùng chạm

> Agent đọc file này ở P0/P2 khi cần kiểm tra tap target size. Thực hiện TỪNG BƯỚC.

## Mục đích

Chuyển Hard Gate H2 (Tap target ≥ 24×24px) từ `inferred` → `measured` bằng cách đọc kích thước thật từ Figma metadata.

## Khi nào chạy

- **P0**: Sau khi `get_metadata` trả về, lọc tất cả interactive nodes.
- **P2 Lens 1**: Đo size → ghi kết quả vào scratchpad.

## Bước 1 — Xác định Interactive Nodes

Từ kết quả `get_metadata`, lọc nodes có khả năng là interactive bằng các tiêu chí:

**Tiêu chí 1 — Type**:
- `type = "INSTANCE"` (component instance — thường là button, input, icon button)
- `type = "COMPONENT"` (component definition)

**Tiêu chí 2 — Tên layer** (case-insensitive, match partial):

```
button, btn, cta, action, submit, save, cancel, close, back,
icon-button, icon_button, iconButton, fab,
link, anchor, href,
checkbox, check-box, radio, switch, toggle,
tab, tab-item, tabItem,
chip, tag, badge (nếu clickable),
dropdown, select, picker, combobox,
input, text-field, textField, search-bar, searchBar,
menu-item, menuItem, list-item, listItem,
stepper, slider, rating,
close-button, closeButton, dismiss, x-button
```

**Tiêu chí 3 — Prototype link**: Nếu node có `transitionNodeID` (link prototype) → interactive.

## Bước 2 — Đo kích thước

Với mỗi interactive node, đọc từ metadata:

```
- absoluteBoundingBox.width  (px)
- absoluteBoundingBox.height (px)
```

**Nếu không có `absoluteBoundingBox`** → đọc `size.x` và `size.y`.

## Bước 3 — Đánh giá Pass/Fail

| Nền tảng | Ngưỡng tối thiểu | Ngưỡng khuyến nghị |
|----------|-------------------|--------------------|
| **Mobile iOS** (HIG) | 44 × 44 pt | 44 × 44 pt |
| **Mobile Android** (Material) | 48 × 48 dp | 48 × 48 dp |
| **WCAG 2.5.8** (Level AAA) | 24 × 24 CSS px | 44 × 44 CSS px |
| **WCAG 2.5.5** (Level AAA) | 44 × 44 CSS px | — |

**Quy tắc đánh giá cho agent**:
- Nếu context là iOS app → dùng 44 × 44 pt
- Nếu context là Android app → dùng 48 × 48 dp
- Nếu context là Web → dùng 24 × 24 CSS px (WCAG 2.5.8 Level AA)
- Nếu không rõ → dùng **24 × 24 px** (ngưỡng thấp nhất WCAG AA)

**Ngoại lệ** (không đánh fail):
- Inline text link trong paragraph (size phụ thuộc text length)
- Element có padding ẩn mở rộng hit area (kiểm tra nếu parent có padding lớn hơn)

## Bước 4 — Ghi kết quả vào Scratchpad

```markdown
### Tap Target Measurement Results

**Nền tảng**: [iOS / Android / Web]
**Ngưỡng áp dụng**: [44×44pt / 48×48dp / 24×24px]

| # | Node ID | Tên layer | Width | Height | Min dim | Pass? | Ghi chú |
|---|---------|-----------|-------|--------|---------|-------|---------|
| 1 | 123:456 | btn-save | 120 | 48 | 48 | ✅ | |
| 2 | 123:789 | icon-close | 20 | 20 | 20 | ❌ | < 44pt, thiếu padding |
| 3 | 124:100 | chip-filter | 80 | 32 | 32 | ❌ | height < 44pt |
| 4 | 124:200 | tab-item | 90 | 44 | 44 | ✅ | vừa đủ |

**Tổng kết**: [n]/[total] interactive nodes đạt ngưỡng = [x]%
**Method**: measured
**Hard Gate H2**: [PASS/FAIL] (ngưỡng ≥95%)
```

## Bước 5 — Tạo Finding (nếu fail)

Nếu % đạt < 95%, tạo finding:

```
🔴 [UI][node-id-smallest][unrelated][—][img:F-XXX]: tap target [W]×[H]px < [ngưỡng] — [tên layer]
```

Chụp ảnh node nhỏ nhất + parent container bằng `get_screenshot`.

## Lưu ý

- **Padding ẩn**: Một số button có visual size 20×20 nhưng nằm trong container 44×44 với padding — vẫn PASS nếu container là hit area thật. Kiểm tra parent node size.
- **Icon-only button**: Thường bị nhỏ nhất. Ưu tiên kiểm tra loại này.
- **Close button (×)**: Hay nằm ở góc, thường bị < 44pt. Đặc biệt chú ý.
- **Cluster buttons**: 2 button sát nhau → kiểm tra gap ≥ 8px để tránh miss-tap.
- **Figma measurement = design intent**: Kích thước trong Figma là kích thước thiết kế, dev có thể implement khác. Ghi rõ method = `measured (design intent)`.
