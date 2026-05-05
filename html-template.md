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
  :root {
    color-scheme: light;
    --bg: #f5f7fb;
    --paper: #ffffff;
    --text: #111827;
    --muted: #6b7280;
    --border: #e5e7eb;
    --border-strong: #d1d5db;
    --header: #0f172a;
    --subheader: #1f2937;
    --table-head: #f3f4f6;
    --code-bg: #0b1220;
    --code-text: #e5e7eb;
    --quote-bg: #f0f7ff;
    --quote-border: #2563eb;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    font-size: 16px;
    line-height: 1.75;
    color: var(--text);
    background: var(--bg);
    padding: 28px 18px;
  }

  /* A readable "paper" container so content never blends into bg */
  .page {
    max-width: 980px;
    margin: 0 auto;
    background: var(--paper);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 28px 26px;
    box-shadow: 0 10px 25px rgba(15, 23, 42, 0.06);
  }

  h1, h2, h3 { line-height: 1.25; }
  h1 {
    font-size: 1.9rem;
    margin: 0 0 1rem;
    color: var(--header);
    letter-spacing: -0.01em;
    border-bottom: 2px solid var(--border);
    padding-bottom: 0.6rem;
  }
  h2 { font-size: 1.35rem; margin: 1.75rem 0 0.75rem; color: var(--header); }
  h3 { font-size: 1.1rem; margin: 1.25rem 0 0.55rem; color: var(--subheader); }
  p { margin: 0.65rem 0; }

  a { color: #2563eb; text-decoration: none; }
  a:hover { text-decoration: underline; }

  img {
    max-width: 100%;
    height: auto;
    display: block;
    border: 1px solid var(--border);
    border-radius: 10px;
    margin: 0.9rem 0;
    background: #fff;
  }

  hr { border: none; border-top: 1px solid var(--border); margin: 1.5rem 0; }
  strong { color: var(--text); }

  /* Lists */
  ul, ol { padding-left: 1.4rem; margin: 0.55rem 0; }
  li { margin: 0.25rem 0; }

  /* Blockquotes */
  blockquote {
    border-left: 4px solid var(--quote-border);
    background: var(--quote-bg);
    padding: 0.75rem 1rem;
    margin: 1rem 0;
    color: #0b2545;
    border-radius: 10px;
  }

  /* Inline code */
  code {
    background: #f1f5f9;
    border: 1px solid var(--border);
    padding: 0.12rem 0.35rem;
    border-radius: 6px;
    font-size: 0.92em;
  }

  /* Code blocks */
  pre {
    margin: 0.9rem 0;
    padding: 0.95rem 1rem;
    overflow: auto;
    border-radius: 12px;
    background: var(--code-bg);
    border: 1px solid rgba(148, 163, 184, 0.25);
  }
  pre code {
    background: transparent;
    border: none;
    padding: 0;
    color: var(--code-text);
    font-size: 0.92rem;
    line-height: 1.6;
  }

  /* Tables: always readable & scrollable on mobile */
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 0.9rem 0;
    font-size: 0.95rem;
  }
  th, td {
    border: 1px solid var(--border);
    padding: 0.55rem 0.75rem;
    vertical-align: top;
    text-align: left;
  }
  th {
    background: var(--table-head);
    font-weight: 700;
    color: #111827;
    border-color: var(--border-strong);
  }
  tr:nth-child(even) { background: #fafafa; }

  /* If markdown converter wraps tables, keep them scrollable */
  .table-wrap { overflow-x: auto; }
  .table-wrap table { min-width: 640px; }

  .severity-p0 { color: #e74c3c; font-weight: 700; }
  .severity-p1 { color: #e67e22; font-weight: 700; }
  .severity-p2 { color: #3498db; font-weight: 600; }
  .score { font-size: 2rem; font-weight: 700; color: #2c3e50; }
  .finding { border: 1px solid #e0e0e0; border-radius: 8px; padding: 1.2rem; margin: 1rem 0; background: #fff; }
  .finding-p0 { border-left: 4px solid #e74c3c; }
  .finding-p1 { border-left: 4px solid #e67e22; }
  .finding-p2 { border-left: 4px solid #3498db; }

  @media print {
    body { padding: 0; background: #fff; }
    .page { max-width: 100%; border: none; border-radius: 0; box-shadow: none; padding: 18px; }
    .finding { break-inside: avoid; }
    img { max-height: 400px; }
  }
</style>
</head>
<body>
<main class="page">
{{CONTENT}}
</main>
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

### Table overflow (khuyến nghị)

Để bảng không bị “bóp” trên màn hình nhỏ, khi render HTML hãy bọc mỗi `<table>` bằng:

```html
<div class="table-wrap">
  <table>...</table>
</div>
```

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
