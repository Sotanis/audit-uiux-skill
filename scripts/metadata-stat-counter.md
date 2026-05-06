# Metadata Stat Counter — Đếm các tỷ lệ phục vụ Hard Gate H3, H8, H9, H10, H11

> Agent đọc file này ở P0 sau khi đã có `get_metadata`, `get_design_context`, `get_variable_defs`. Thực hiện TỪNG BƯỚC.

## Mục đích

Chuyển 5 Hard Gate từ ad-hoc count → `measured` bằng cách đếm trực tiếp từ Figma metadata:

| Hard Gate | Mục | Ngưỡng |
|-----------|-----|--------|
| H3 | Primary CTA / màn | tồn tại + above fold + duy nhất |
| H8 | Default layer name | ≤20% layer mang tên mặc định |
| H9 | Detached components | ≤5% instance bị detach |
| H10 | Hardcoded color | ≤10% color không bind variable |
| H11 | Auto-layout ratio | ≥80% container dùng auto-layout |

## Khi nào chạy

- **P0** sau khi đã fetch metadata + design_context + variable_defs.
- Chạy 1 lần / scope. Output ghi vào scratchpad mục `## Measurement Results — Metadata Stats`.

## Bước 1 — Tổng hợp tập node theo loại

Từ `get_metadata`, phân loại nodes:

```
- ALL_NODES: tất cả node trong scope
- CONTAINERS: nodes có thể chứa children (FRAME, GROUP, COMPONENT, INSTANCE, SECTION)
- INSTANCES: nodes type = INSTANCE (component instance)
- TEXT_NODES: type = TEXT
- SHAPE_NODES: nodes có fills hoặc strokes (RECTANGLE, ELLIPSE, VECTOR, ...)
```

Ghi tổng số mỗi loại để dùng làm mẫu số.

## Bước 2 — H8 Default Layer Name

**Default name patterns** (regex):

```
^Frame \d+$
^Group \d+$
^Rectangle \d+$
^Ellipse \d+$
^Vector \d+$
^Line \d+$
^Component \d+$
^Instance$
```

**Đếm**:
```
default_count = số node trong ALL_NODES có name match pattern trên
default_ratio = default_count / |ALL_NODES| × 100%
H8 PASS nếu default_ratio ≤ 20%
```

**Output**:
```
| Tổng node | Default name | Tỷ lệ | H8 |
|-----------|--------------|-------|-----|
| 245       | 32           | 13.1% | ✅  |
```

Nếu fail, list tối đa 20 node ID đầu tiên có default name để designer sửa.

## Bước 3 — H9 Detached Components

**Phát hiện instance detached**:

Một instance bị detach khi:
- Trước là `INSTANCE` của một component → bây giờ là `FRAME`/`GROUP` cùng tên main component
- Hoặc node có `componentId` field mà MCP trả về `null`/`undefined` trong khi tên gợi ý là instance

**Đếm**:
```
total_instances_expected = số node có tên giống component (pattern: "Button/Primary", "Card/Default", ...) HOẶC type=INSTANCE
detached_count = số node có tên dạng instance NHƯNG type ≠ INSTANCE
detached_ratio = detached_count / total_instances_expected × 100%
H9 PASS nếu detached_ratio ≤ 5%
```

**Lưu ý**: Nếu Figma MCP không expose đủ field để xác định detach → tag method `inferred` cho H9, ghi confidence ±10%.

**Output**:
```
| Total instances | Detached | Tỷ lệ | H9 |
|-----------------|----------|-------|-----|
| 84              | 3        | 3.6%  | ✅  |
```

## Bước 4 — H10 Hardcoded Color

Từ `get_variable_defs` và fills của shape/text nodes:

**Đếm**:
```
total_color_usages = tổng số fill/stroke có color (text + shape)
bound_count = số fill/stroke có boundVariables.color hoặc dùng style reference
hardcoded_count = total_color_usages - bound_count
hardcoded_ratio = hardcoded_count / total_color_usages × 100%
H10 PASS nếu hardcoded_ratio ≤ 10%
```

**Output**:
```
| Total color usages | Bound to variable | Hardcoded | Tỷ lệ hardcode | H10 |
|--------------------|-------------------|-----------|----------------|-----|
| 312                | 287               | 25        | 8.0%           | ✅  |
```

Nếu fail, list top 10 hex value xuất hiện nhiều nhất chưa bind variable.

## Bước 5 — H11 Auto-layout Ratio

**Đếm**:
```
total_containers = |CONTAINERS| (loại SECTION ngoài cùng nếu có)
autolayout_count = số container có layoutMode ∈ {HORIZONTAL, VERTICAL, WRAP}
autolayout_ratio = autolayout_count / total_containers × 100%
H11 PASS nếu autolayout_ratio ≥ 80%
```

**Output**:
```
| Total containers | Auto-layout | Tỷ lệ | H11 |
|------------------|-------------|-------|-----|
| 96               | 82          | 85.4% | ✅  |
```

Nếu fail, list 10 container lớn nhất (theo bounding box) chưa auto-layout — ưu tiên fix.

## Bước 6 — H3 Primary CTA per Viewport

**Phát hiện CTA**:
- Node là `INSTANCE` có name match: `Button/Primary`, `CTA/Primary`, hoặc text-on-button có style `H1/Button`, `Action/Primary`.
- Hoặc node `FRAME` có style fill = primary color của brand + chứa text với label hành động (Lưu, Xác nhận, Đăng ký, Tiếp tục, Submit, …).

**Phân biệt primary vs secondary**:
- Primary: fill solid (brand color), text contrast cao.
- Secondary: outline, ghost, hoặc fill nhạt.

**Đếm per viewport** (mỗi top-level FRAME = 1 viewport):

```
Với mỗi viewport V trong scope:
  primary_ctas_in_V = số node primary CTA nằm trong V
  - 0 → flag: "thiếu primary CTA" (H3 FAIL nếu V là màn action)
  - 1 → ✅
  - ≥2 → flag: "multiple primary CTA, user phân vân" (H3 FAIL)

  above_fold_check:
  - Nếu primary CTA Y-position > viewport height × 0.6 → flag "below fold"
```

**Output**:
```
| Viewport (frame) | Primary CTA count | Above fold | H3 |
|------------------|-------------------|------------|-----|
| Confirm screen   | 1                 | ✅          | ✅  |
| Settings list    | 0                 | —          | ⚠️ wireframe-like, cần xác nhận với user |
| Form input       | 2                 | ❌ Submit dưới fold | ❌  |
```

**Lưu ý**: H3 phụ thuộc nhận dạng "primary" → tag method `inferred` nếu thiếu naming convention; `measured` nếu component instance rõ ràng.

## Bước 7 — Tổng kết

Ghi vào scratchpad:

```markdown
## Measurement Results — Metadata Stats

### Tổng hợp Hard Gate

| Gate | Metric | Giá trị | Ngưỡng | Status | Method |
|------|--------|---------|--------|--------|--------|
| H3   | Primary CTA / viewport | [list] | 1, above fold | [PASS/FAIL] | measured/inferred |
| H8   | Default layer name | X.X% | ≤20% | [PASS/FAIL] | measured |
| H9   | Detached instances | X.X% | ≤5% | [PASS/FAIL] | measured/inferred |
| H10  | Hardcoded color | X.X% | ≤10% | [PASS/FAIL] | measured |
| H11  | Auto-layout container | X.X% | ≥80% | [PASS/FAIL] | measured |

### Top vi phạm (nếu có)

[Liệt kê node ID + name + lý do, tối đa 10/gate]
```

## Bước 8 — Tạo Finding (nếu fail)

Mỗi gate fail → finding 🔴:

```
🔴 [UI/Nghiệp vụ][<top-vi-phạm-node>][unrelated][—][img:F-XXX]: H<gate> fail — [metric] [actual]% vượt ngưỡng [threshold]%
```

Chụp ảnh:
- H3: chụp viewport thiếu/thừa CTA.
- H8: chụp panel layers Figma có nhiều default name (nếu `get_screenshot` không lấy được panel → ảnh frame chính + ghi chú).
- H9: chụp instance bị detach.
- H10: chụp vùng có hardcoded color rõ.
- H11: chụp container không auto-layout lớn nhất.

## Lưu ý

- Tỷ lệ tính trên scope đã chọn (node mục tiêu + descendants), KHÔNG tính toàn file Figma.
- Nếu MCP không expose đủ field (ví dụ `boundVariables`) → ghi rõ trong scratchpad: "H10 method = inferred do MCP version thiếu field".
- Cho component đơn lẻ (scope nhỏ) — H3 không áp dụng (component không phải viewport); chỉ skip H3, các gate còn lại vẫn chạy.
