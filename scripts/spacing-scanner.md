# Spacing Scanner — Hướng dẫn phát hiện Magic Numbers

> Agent đọc file này ở P0/P2 khi cần kiểm tra spacing consistency. Thực hiện TỪNG BƯỚC.

## Mục đích

Tăng độ chính xác cho UI-03 (Spacing scale) bằng cách đếm chính xác spacing values từ Figma metadata, phát hiện magic numbers.

## Khi nào chạy

- **P0**: Sau khi `get_metadata` trả về.
- **P2 Lens 1**: Phân tích kết quả → ghi scratchpad.

## Bước 1 — Thu thập Spacing Values

Từ kết quả `get_metadata` và `get_design_context`, tìm tất cả nodes có `layoutMode != "NONE"` (auto-layout nodes) và đọc:

```
Mỗi auto-layout node:
- Node ID
- Tên layer
- itemSpacing (gap giữa các children)
- paddingTop
- paddingRight
- paddingBottom
- paddingLeft
```

**Bổ sung**: Đọc cả `counterAxisSpacing` nếu có (wrap layout).

## Bước 2 — Kiểm tra Scale Compliance

So sánh mỗi spacing value với **spacing scale chuẩn**:

**Scale 4pt (phổ biến nhất)**:
```
Hợp lệ: {0, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96, 120}
```

**Scale 8pt (strict)**:
```
Hợp lệ: {0, 4, 8, 16, 24, 32, 40, 48, 64, 80, 96}
```

**Quy tắc chọn scale**: Xem đa số spacing values thuộc scale nào → dùng scale đó làm chuẩn.

**Magic number** = giá trị KHÔNG thuộc scale đã chọn. VD: 5, 7, 9, 11, 13, 15, 17, 18, 19, 21, 22, 23, 25, 26, 27...

## Bước 3 — Phân loại kết quả

| Loại | Định nghĩa | Ví dụ |
|------|-----------|-------|
| ✅ On-scale | Giá trị thuộc spacing scale | 8, 16, 24 |
| ⚠️ Near-miss | Giá trị lệch 1px so với scale (có thể do rounding) | 15 (gần 16), 23 (gần 24) |
| ❌ Magic number | Giá trị lệch ≥2px so với giá trị scale gần nhất | 13, 17, 22, 37 |

## Bước 4 — Ghi kết quả vào Scratchpad

```markdown
### Spacing Measurement Results

**Scale phát hiện**: 4pt base (phổ biến nhất trong design)
**Tổng auto-layout nodes**: [n]

#### Phân bố spacing values

| Value | Số lần dùng | Loại | Nodes (sample) |
|-------|-------------|------|-----------------|
| 0 | 12 | ✅ on-scale | — |
| 4 | 8 | ✅ on-scale | — |
| 8 | 15 | ✅ on-scale | — |
| 12 | 6 | ✅ on-scale | — |
| 13 | 2 | ❌ magic | `3460:96816` (filter-row gap), `3475:121305` (field-list padding) |
| 16 | 20 | ✅ on-scale | — |
| 17 | 1 | ❌ magic | `3527:160686` (date-picker paddingTop) |
| 24 | 10 | ✅ on-scale | — |

#### Tổng kết

- **Tổng spacing values (unique)**: [n]
- **On-scale**: [n] ([x]%)
- **Near-miss**: [n] ([x]%)
- **Magic numbers**: [n] ([x]%)
- **Method**: measured
- **UI-03**: [PASS/FAIL] (ngưỡng 100% on-scale, tolerance 1 near-miss)
```

## Bước 5 — Tạo Finding (nếu có magic numbers)

Nếu có ≥2 magic numbers:

```
🟡 [UI][node-id-first-magic][unrelated][—][img:F-XXX]: [n] magic spacing numbers — [values] tại [node names]
```

Nếu có ≥5 magic numbers:

```
🔴 [UI][node-id-worst][unrelated][—][img:F-XXX]: spacing inconsistency — [n] magic numbers, hệ thống spacing không nhất quán
```

## Ví dụ phát hiện

```
Node: 3460:96816 (filter-panel)
├── itemSpacing: 16 ✅
├── paddingTop: 24 ✅
├── paddingRight: 16 ✅
├── paddingBottom: 24 ✅
├── paddingLeft: 16 ✅
│
├── child: filter-row-1
│   ├── itemSpacing: 8 ✅
│   └── paddingBottom: 13 ❌ MAGIC (gần 12 hoặc 16)
│
└── child: filter-row-2
    ├── itemSpacing: 8 ✅
    └── paddingBottom: 12 ✅

→ 1 magic number (13px tại filter-row-1 paddingBottom)
→ Đề xuất: chuyển 13 → 12 hoặc 16 để align với scale
```

## Lưu ý

- **Padding 0**: Hợp lệ — nhiều element không cần padding.
- **Spacing rất lớn (>120px)**: Có thể là intentional (section separator) — không flag là magic, ghi "large spacing — verify intent".
- **Component instance**: Nếu spacing kỳ lạ đến từ component master → ghi nhận ở component master, không flag từng instance.
- **Responsive override**: Một số spacing có thể khác giữa breakpoints — ghi nhận breakpoint nếu phát hiện.
