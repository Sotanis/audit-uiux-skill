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
    --bg: #ffffff;
    --page: #f6f7f9;
    --text: #0f172a;
    --muted: #475569;
    --border: rgba(15, 23, 42, 0.12);
    --border-strong: rgba(15, 23, 42, 0.18);
    --shadow: 0 1px 2px rgba(15, 23, 42, 0.06), 0 6px 18px rgba(15, 23, 42, 0.06);
    --code-bg: rgba(15, 23, 42, 0.06);

    --p0: #dc2626;
    --p1: #d97706;
    --p2: #2563eb;

    --radius: 12px;
    --radius-sm: 10px;
    --content: 980px;
  }

  * { margin: 0; padding: 0; box-sizing: border-box; }
  html { color-scheme: light; }
  body {
    font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, "Apple Color Emoji", "Segoe UI Emoji";
    line-height: 1.65;
    color: var(--text);
    background: var(--page);
    -webkit-font-smoothing: antialiased;
    text-rendering: optimizeLegibility;
  }

  a { color: inherit; text-decoration: underline; text-underline-offset: 3px; text-decoration-color: rgba(37, 99, 235, 0.35); }
  a:hover { text-decoration-color: rgba(37, 99, 235, 0.65); }

  .container { max-width: var(--content); margin: 0 auto; padding: 28px 18px 56px; }
  .paper {
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 26px 22px;
  }

  /* Typography */
  h1 {
    font-size: 1.7rem;
    line-height: 1.25;
    letter-spacing: -0.02em;
    margin: 0 0 14px;
  }
  h2 {
    font-size: 1.18rem;
    line-height: 1.3;
    letter-spacing: -0.01em;
    margin: 22px 0 10px;
    padding-top: 4px;
  }
  h3 {
    font-size: 1.03rem;
    line-height: 1.35;
    margin: 18px 0 8px;
  }
  p { margin: 10px 0; color: var(--text); }
  em { color: var(--muted); }

  hr { border: none; border-top: 1px solid var(--border); margin: 18px 0; }

  /* Code */
  code {
    background: var(--code-bg);
    padding: 0.12rem 0.38rem;
    border-radius: 8px;
    font-size: 0.92em;
  }
  pre {
    background: var(--code-bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    padding: 12px 14px;
    overflow: auto;
    margin: 12px 0;
  }
  pre code { background: transparent; padding: 0; border-radius: 0; font-size: 0.9em; }

  /* Lists */
  ul, ol { padding-left: 1.35rem; margin: 10px 0; }
  li { margin: 6px 0; }

  /* Blockquote */
  blockquote {
    border-left: 3px solid rgba(37, 99, 235, 0.5);
    background: rgba(37, 99, 235, 0.06);
    border-radius: 10px;
    padding: 10px 12px;
    margin: 12px 0;
    color: var(--muted);
  }

  /* Tables */
  .table-wrap { overflow: auto; margin: 12px 0; border: 1px solid var(--border); border-radius: var(--radius-sm); }
  table { width: 100%; border-collapse: collapse; font-size: 0.92rem; min-width: 640px; }
  th, td { border-bottom: 1px solid var(--border); padding: 10px 12px; text-align: left; vertical-align: top; }
  th { background: rgba(15, 23, 42, 0.04); font-weight: 650; }
  tr:last-child td { border-bottom: none; }
  tbody tr:hover td { background: rgba(15, 23, 42, 0.02); }

  /* Images */
  figure { margin: 12px 0; }
  img {
    max-width: 100%;
    height: auto;
    border-radius: 10px;
    border: 1px solid var(--border);
    background: rgba(15, 23, 42, 0.02);
  }
  figcaption { margin-top: 6px; font-size: 0.88rem; color: var(--muted); }

  /* Severity */
  .severity-p0 { color: var(--p0); font-weight: 750; }
  .severity-p1 { color: var(--p1); font-weight: 750; }
  .severity-p2 { color: var(--p2); font-weight: 700; }

  /* Score */
  .score { font-size: 1.8rem; font-weight: 800; letter-spacing: -0.02em; }

  /* Finding blocks */
  .finding {
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 14px 14px;
    margin: 14px 0;
    background: #fff;
  }
  .finding h3 { margin-top: 0; }
  .finding-p0 { border-left: 4px solid var(--p0); }
  .finding-p1 { border-left: 4px solid var(--p1); }
  .finding-p2 { border-left: 4px solid var(--p2); }

  /* Print */
  @media print {
    :root { --page: #ffffff; }
    body { background: #fff; }
    .container { padding: 0; }
    .paper { box-shadow: none; border: none; padding: 0; }
    a { text-decoration: none; }
    .finding { break-inside: avoid; }
    img { max-height: 420px; }
    .table-wrap { border-color: rgba(0,0,0,0.12); }
  }
</style>
</head>
<body>
  <div class="container">
    <main class="paper">
      {{CONTENT}}
    </main>
  </div>
</body>
</html>
```

## Quy tắc chuyển đổi

### Thay thế placeholder

- `{{TITLE}}`: Tiêu đề báo cáo (dòng h1 đầu tiên)
- `{{CONTENT}}`: Toàn bộ nội dung markdown đã chuyển sang HTML

### Table wrapper (khuyến nghị)

Để bảng dễ đọc trên màn hình nhỏ và giữ UI “clean”, bọc mọi `<table>` trong:

```html
<div class="table-wrap">
  <table>...</table>
</div>
```

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
