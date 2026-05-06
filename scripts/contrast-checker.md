# Contrast Checker — Hướng dẫn đo WCAG Contrast Ratio

> Agent đọc file này ở P0/P2 khi cần tính contrast ratio. Thực hiện TỪNG BƯỚC theo thứ tự.

## Mục đích

Chuyển Hard Gate H1 (Contrast WCAG AA) từ `inferred` → `measured` bằng cách tính chính xác contrast ratio từ hex color.

## Khi nào chạy

- **P0**: Sau khi `get_design_context` trả về, extract tất cả text nodes có fill color + parent background color.
- **P2 Lens 1**: Tính ratio cho từng cặp → ghi kết quả vào scratchpad.

## Bước 1 — Thu thập dữ liệu màu

Từ kết quả `get_design_context`, tìm tất cả **text nodes** và ghi lại:

```
Mỗi text node cần:
- Node ID
- Text content (10 ký tự đầu để nhận diện)
- Foreground color (fill color của text): hex 6 ký tự, VD: #1A1A1A
- Background color (fill color của parent container gần nhất): hex 6 ký tự, VD: #FFFFFF
- Font size (để xác định normal text vs large text)
```

**Quy tắc xác định background**:
- Lấy fill color của **parent gần nhất** có fill không transparent
- Nếu parent có gradient → lấy color stop tối nhất (worst case)
- Nếu parent không có fill → đệ quy lên parent tiếp → cuối cùng mặc định `#FFFFFF`
- Nếu text nằm trên ảnh → ghi `bg: image` → chuyển sang `inferred` cho node này
- Nếu text hoặc background có **opacity < 1.0** → xử lý theo Bước 2a (Alpha Compositing)
- Nếu parent có **blend mode** khác `NORMAL` (ví dụ: multiply, overlay, screen) → ghi `bg: blend_mode` → chuyển sang `inferred` cho node này (không tính chính xác được từ data tĩnh)
- Nếu parent có **nhiều fill layers chồng lên nhau** → composite từ dưới lên (Botto→Top), lấy kết quả là effective background

## Bước 2a — Alpha Compositing (khi có opacity < 1.0)

Khi text hoặc background có opacity < 1.0, cần composite trước khi tính contrast:

```
Composite màu foreground (FG) lên background (BG) với alpha A:
  R_eff = R_fg × A + R_bg × (1 - A)
  G_eff = G_fg × A + G_bg × (1 - A)
  B_eff = B_fg × A + B_bg × (1 - A)

Ví dụ: Text #000000 opacity 0.5 trên nền #FFFFFF
  R_eff = 0 × 0.5 + 1 × 0.5 = 0.5 → #808080
  Contrast = (1.0 + 0.05) / (0.216 + 0.05) = 3.95:1 → ❗ FAIL AA normal
```

**Trường hợp cần xử lý**:

| Tình huống | Xử lý |
|-----------|--------|
| Text opacity < 1.0 | Composite text color với bg, tính ratio trên effective color |
| Background opacity < 1.0 | Composite bg với parent bg (hoặc #FFFFFF nếu không có parent) |
| Cả text và bg đều < 1.0 | Composite bg trước, rồi composite text lên kết quả |
| Overlay/modal (semi-transparent bg) | Composite overlay bg với content bg bên dưới, rồi tính contrast text |
| Fill stack (nhiều fill layers) | Composite từ bottom → top theo thứ tự layer |
| Blend mode khác Normal | Ghi `inferred` — không tính chính xác từ data tĩnh |

**Tag method cho opacity cases**: `measured (composited)` — giá trị tính từ công thức, chính xác cho Normal blend mode.

## Bước 2 — Tính Relative Luminance

Với mỗi hex color, tính relative luminance theo công thức WCAG 2.1:

```
1. Chuyển hex → sRGB (0–255 → 0–1):
   R_srgb = R_hex / 255
   G_srgb = G_hex / 255
   B_srgb = B_hex / 255

2. Chuyển sRGB → linear RGB:
   Với mỗi channel C (R, G, B):
   - Nếu C_srgb ≤ 0.04045: C_linear = C_srgb / 12.92
   - Nếu C_srgb > 0.04045:  C_linear = ((C_srgb + 0.055) / 1.055) ^ 2.4

3. Tính relative luminance:
   L = 0.2126 × R_linear + 0.7152 × G_linear + 0.0722 × B_linear
```

## Bước 3 — Tính Contrast Ratio

```
L1 = luminance cao hơn (lighter color)
L2 = luminance thấp hơn (darker color)

Contrast Ratio = (L1 + 0.05) / (L2 + 0.05)
```

Kết quả là số thập phân, VD: `4.72:1`

## Bước 4 — Đánh giá Pass/Fail

| Loại text | WCAG AA (tối thiểu) | WCAG AAA (khuyến nghị) |
|-----------|---------------------|------------------------|
| **Normal text** (< 18pt hoặc < 14pt bold) | ≥ 4.5:1 | ≥ 7:1 |
| **Large text** (≥ 18pt hoặc ≥ 14pt bold) | ≥ 3:1 | ≥ 4.5:1 |
| **UI component / focus indicator** | ≥ 3:1 | — |

**Quy đổi font size**: 1pt ≈ 1.333px. Vậy 18pt ≈ 24px, 14pt ≈ 18.67px.

## Bước 5 — Ghi kết quả vào Scratchpad

Format ghi:

```markdown
### Contrast Measurement Results

| # | Node ID | Text (10 char) | FG | BG | Font size | Ratio | AA | Loại |
|---|---------|----------------|----|----|-----------|-------|----|------|
| 1 | 123:456 | "Lưu bộ lọc" | #1A1A1A | #FFFFFF | 16px | 12.6:1 | ✅ | normal |
| 2 | 123:789 | "Bất kỳ nh" | #999999 | #FFFFFF | 14px | 2.85:1 | ❌ | normal |
| 3 | 124:100 | "Đặt lại" | #FF4444 | #FFFFFF | 16px | 3.94:1 | ❌ | normal |

**Tổng kết**: [n]/[total] text nodes đạt AA = [x]%
**Method**: `measured (full)` nếu quét toàn bộ; `measured (sampled n=N)` nếu sampling. Ghi rõ N và rule sampling.
**Hard Gate H1**: [PASS/FAIL] (ngưỡng ≥95%)
```

> **Quy tắc tag method**:
> - `measured (full)`: quét 100% text nodes trong scope.
> - `measured (sampled n=N)`: nếu >50 text nodes — sampling theo Bước 7. Báo cáo PHẢI ghi rõ tag này và confidence ±5%, không được ghi `measured` chung chung.

## Bước 6 — Tạo Finding (nếu fail)

Nếu % đạt AA < 95%, tạo finding:

```
🔴 [UI][node-id-worst][unrelated][—][img:F-XXX]: contrast [ratio]:1 < 4.5:1 WCAG AA — [text content]
```

Chụp ảnh node có contrast thấp nhất bằng `get_screenshot`.

## Ví dụ tính toán

**Input**: Text `#767676` trên nền `#FFFFFF`

```
1. sRGB: R=0.463, G=0.463, B=0.463
2. Linear: R=0.179, G=0.179, B=0.179 (> 0.04045 → dùng công thức mũ)
3. Luminance text: 0.2126×0.179 + 0.7152×0.179 + 0.0722×0.179 = 0.179
4. Luminance bg (#FFFFFF): 1.0

Contrast = (1.0 + 0.05) / (0.179 + 0.05) = 1.05 / 0.229 = 4.58:1

→ AA normal text: ✅ PASS (4.58 ≥ 4.5)
→ AAA normal text: ❌ FAIL (4.58 < 7.0)
```

## Bước 7 — Sampling khi >50 text nodes

Khi tổng text node >50 và token budget eo hẹp:
1. **Bao gồm 100%** text trên nền **không phải trắng/đen** (đây là vùng dễ fail nhất, không sampling).
2. **Sampling 10 ngẫu nhiên** trong nhóm text trên nền trắng/đen (nhóm low-risk).
3. Tag method: `measured (sampled n=<full_count + 10>)`.
4. Nếu kết quả sample fail ≥1 node → mở rộng quét full nhóm trắng/đen, đổi tag thành `measured (full)`.

## Lưu ý

- Sampling chỉ dùng khi token budget thiếu — ưu tiên `measured (full)` nếu có thể.
- Placeholder text (opacity thấp) vẫn cần đạt contrast 4.5:1 vì chứa thông tin (WCAG 1.4.3). Dùng Bước 2a để composite trước khi đo.
- Icon text (icon font) xử lý như UI component → ngưỡng 3:1.
- Text trên overlay/modal: luôn composite overlay background với layer bên dưới trước khi tính. Nếu overlay có scrim (#000 opacity 0.4) thì effective bg khác hẳn bg gốc.
