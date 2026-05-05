# Hướng dẫn xuất báo cáo HTML

Agent sử dụng file này khi cần tạo file `bao-cao.html` ở Step 9.

## Quy trình tạo HTML

1. Viết báo cáo markdown (`bao-cao.md`) trước — đây là bản gốc.
2. Tạo file `bao-cao.html` bằng cách:
   - Chuyển nội dung markdown sang HTML (headings, tables, lists, blockquotes, bold/italic, code).
   - Với mỗi ảnh `![alt](screenshot-*.png)`: đọc file ảnh, encode base64, thay bằng `<img src="data:image/png;base64,..." alt="...">`.
   - Bọc trong template HTML bên dưới.

## Template HTML

```html
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{TITLE}}</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6; color: #1a1a1a; background: #f8f9fa;
    max-width: 900px; margin: 0 auto; padding: 2rem 1.5rem;
  }
  h1 { font-size: 1.8rem; margin: 2rem 0 1rem; border-bottom: 2px solid #e0e0e0; padding-bottom: 0.5rem; }
  h2 { font-size: 1.4rem; margin: 1.8rem 0 0.8rem; color: #2c3e50; }
  h3 { font-size: 1.15rem; margin: 1.4rem 0 0.6rem; color: #34495e; }
  p { margin: 0.6rem 0; }
  img { max-width: 100%; border: 1px solid #ddd; border-radius: 6px; margin: 0.8rem 0; }
  table { width: 100%; border-collapse: collapse; margin: 0.8rem 0; font-size: 0.92rem; }
  th, td { border: 1px solid #ddd; padding: 0.5rem 0.75rem; text-align: left; }
  th { background: #f0f2f5; font-weight: 600; }
  tr:nth-child(even) { background: #fafbfc; }
  blockquote {
    border-left: 3px solid #3498db; background: #f0f7ff;
    padding: 0.6rem 1rem; margin: 0.8rem 0; font-style: italic;
  }
  ul, ol { padding-left: 1.5rem; margin: 0.5rem 0; }
  li { margin: 0.3rem 0; }
  code { background: #f0f2f5; padding: 0.15rem 0.4rem; border-radius: 3px; font-size: 0.9em; }
  hr { border: none; border-top: 1px solid #e0e0e0; margin: 1.5rem 0; }
  strong { color: #1a1a1a; }

  .severity-p0 { color: #e74c3c; font-weight: 700; }
  .severity-p1 { color: #e67e22; font-weight: 700; }
  .severity-p2 { color: #3498db; font-weight: 600; }
  .score { font-size: 2rem; font-weight: 700; color: #2c3e50; }
  .finding { border: 1px solid #e0e0e0; border-radius: 8px; padding: 1.2rem; margin: 1rem 0; background: #fff; }
  .finding-p0 { border-left: 4px solid #e74c3c; }
  .finding-p1 { border-left: 4px solid #e67e22; }
  .finding-p2 { border-left: 4px solid #3498db; }

  @media print {
    body { max-width: 100%; padding: 1rem; background: #fff; }
    .finding { break-inside: avoid; }
    img { max-height: 400px; }
  }
</style>
</head>
<body>
{{CONTENT}}
</body>
</html>
```

## Quy tắc chuyển đổi

### Thay thế placeholder

- `{{TITLE}}`: Tiêu đề báo cáo (dòng h1 đầu tiên)
- `{{CONTENT}}`: Toàn bộ nội dung markdown đã chuyển sang HTML

### Finding blocks

Bọc mỗi finding (từ `### [F-XXX]` đến finding tiếp theo hoặc `---`) trong:

```html
<div class="finding finding-p0">  <!-- p0 / p1 / p2 tùy mức độ -->
  ...nội dung finding...
</div>
```

### Severity labels

Khi gặp text `P0`, `P1`, `P2` trong bảng hoặc heading, bọc bằng:

```html
<span class="severity-p0">P0 (Nghiêm trọng)</span>
<span class="severity-p1">P1 (Quan trọng)</span>
<span class="severity-p2">P2 (Nhỏ)</span>
```

### Điểm tổng

Số điểm `/100` hiển thị lớn:

```html
<span class="score">78/100</span>
```

### Ảnh base64

Đọc file ảnh → encode base64 → nhúng:

```html
<!-- Thay vì -->
<img src="screenshot-F-001.png" alt="...">

<!-- Thành -->
<img src="data:image/png;base64,iVBORw0KGgo..." alt="...">
```

Nếu không đọc được file ảnh (lỗi hoặc không tồn tại), giữ nguyên `src` gốc và thêm ghi chú `<!-- ảnh không nhúng được -->`.

### Bố cục ảnh trong finding (side-by-side khi có ảnh ngữ cảnh)

Khi finding có cả ảnh vùng lỗi + ảnh ngữ cảnh, render dạng grid 2 cột:

```html
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin: 1rem 0;">
  <figure style="margin: 0;">
    <img src="data:image/png;base64,..." alt="F-001 vùng lỗi" style="width: 100%; border: 2px solid #e74c3c; border-radius: 6px;">
    <figcaption style="font-size: 0.85rem; color: #666; margin-top: 4px;">Vùng có vấn đề</figcaption>
  </figure>
  <figure style="margin: 0;">
    <img src="data:image/png;base64,..." alt="F-001 ngữ cảnh" style="width: 100%; border: 1px solid #ddd; border-radius: 6px;">
    <figcaption style="font-size: 0.85rem; color: #666; margin-top: 4px;">Ngữ cảnh xung quanh</figcaption>
  </figure>
</div>
```

Khi chỉ có 1 ảnh (vùng lỗi đủ rõ), render full-width như bình thường:

```html
<figure style="margin: 1rem 0;">
  <img src="data:image/png;base64,..." alt="F-001" style="max-width: 100%; border: 2px solid #e74c3c; border-radius: 6px;">
  <figcaption style="font-size: 0.85rem; color: #666; margin-top: 4px;">F-001 — [mô tả ngắn]</figcaption>
</figure>
```

**Quy tắc viền màu theo severity:**
- 🔴 P0: `border: 2px solid #e74c3c`
- 🟡 P1: `border: 2px solid #e67e22`
- 🟢 P2: `border: 1px solid #ddd`

### Validation trước khi xuất HTML

Trước khi tạo file `bao-cao.html`, kiểm:
1. Mọi finding 🔴/🟡 trong `bao-cao.md` có ít nhất 1 thẻ `![...](screenshot-F-XXX.png)` không?
2. File ảnh tương ứng có tồn tại trong thư mục báo cáo không?
3. Nếu thiếu → chụp lại từ Figma (nodeId vẫn còn trong scratchpad), không skip.
