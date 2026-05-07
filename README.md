# Audit UI/UX — Figma Design Review Agent

Agent review thiết kế Figma trước khi bàn giao cho developer. Kết hợp:
- **JTBD** (Jobs-To-Be-Done) để framing đúng “job” và outcome
- **Heuristics** (Apple HIG, Material, Nielsen) + **WCAG 2.2 AA**
- **Scanner** (contrast, tap target, spacing, naming, hardcoded color, auto-layout, …) để giảm “audit cảm tính”

**Output** (tiếng Việt):
- Quyết định bàn giao: **READY / READY WITH NOTES / NEEDS REWORK / BLOCKED**
- 3 tầng gate: **Hard Gate** (H1–H11) → **Score Gate** (4 trục ≥80%) → **Severity Gate**
- Finding **P0 / P1 / P2** có **ảnh + nodeId + đề xuất cụ thể**
- Xuất báo cáo **2 bản**: `bao-cao.md` + `bao-cao.html` (ảnh nhúng base64)

Tài liệu nền: [GIOI-THIEU.md](GIOI-THIEU.md)

---

## Quickstart

### 1) Cài agent (Cursor / Claude Code)

Chạy một lệnh:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sotanis/audit-uiux-skill/main/install.sh)
```

Script sẽ copy đúng file vào:
- Cursor: `~/.cursor/skills/audit-uiux/`
- Claude Code: `~/.claude/agents/audit-uiux.md` (+ `scripts/`)

> Nếu shell của bạn không hỗ trợ `bash <(curl ...)`, hãy clone repo và chạy `./install.sh` (xem mục “Cài đặt” bên dưới).

### 2) Kết nối Figma MCP (official, OAuth)

> **Quan trọng**: **Claude app (chat trực tiếp)** không hỗ trợ MCP. Bạn cần **Cursor** hoặc **Claude Code**.
>
> Hướng dẫn official: [`remote-server-installation/#claude-code`](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/#claude-code)

#### Cursor (preferred)

Trong Cursor Agent chat:

```
/add-plugin figma
```

Sau đó Authenticate/Allow theo UI trong Settings → MCP.

#### Claude Code (preferred)

Chạy trong terminal:

```bash
claude plugin install figma@claude-plugins-official
```

Mở Claude Code mới → gõ `/mcp` → chọn `figma` → **Authenticate** → **Allow Access**.

#### Claude Code (manual)

```bash
claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp
```

Sau đó `/mcp` → Authenticate.

### 3) Chạy audit

Copy link từ **frame cụ thể** trong Figma (bắt buộc có `node-id`), rồi prompt:

```text
/audit-uiux https://www.figma.com/design/<FILE_KEY>/<NAME>?node-id=<NODE_ID>
```

Nếu agent hỏi context, trả lời ngắn gọn 3 ý: **persona → JTBD → tiêu chí thành công**.

---

## Yêu cầu hệ thống

| Yêu cầu | Ghi chú |
|---------|--------|
| macOS / Linux (Windows: WSL2) | Khuyến nghị |
| bash + curl | Để chạy `install.sh` |
| Cursor **hoặc** Claude Code | Để chạy agent |
| Tài khoản Figma có quyền đọc file | Cần để MCP đọc node |

> **Rate limit**: Figma MCP có giới hạn theo plan/seat. Khi tool chậm hoặc bị cắt ngữ cảnh, hãy giảm scope (chọn frame nhỏ hơn).

---

## Cài đặt

### Cách 1 — Một lệnh (tự tải từ GitHub)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sotanis/audit-uiux-skill/main/install.sh)
```

### Cách 2 — Clone repo (offline / muốn xem code)

```bash
git clone https://github.com/Sotanis/audit-uiux-skill.git ~/Downloads/audit-uiux-skill
cd ~/Downloads/audit-uiux-skill
chmod +x install.sh
./install.sh
```

`install.sh` cũng copy **`package.json`** + **`scripts/render-report.mjs`** + **`scripts/report-shell.html`** vào thư mục skill đã chọn và **chạy `npm install`** ở đó nếu máy có lệnh `npm` (cài [Node.js LTS](https://nodejs.org/) nếu chưa có). Như vậy bạn có thể xuất HTML cố định ngay sau khi cài Agent: `cd ~/.cursor/skills/audit-uiux` (hoặc `~/.claude/agents`) rồi `npm run render-report -- /path/bao-cao.md`. Nếu không có `npm`, bước này bị bỏ qua — Agent vẫn chạy bình thường.

### Cách 3 — Cài thủ công

```bash
# Cursor
mkdir -p ~/.cursor/skills/audit-uiux/scripts
cp SKILL.md ~/.cursor/skills/audit-uiux/
cp gate-rules.md heuristics.md jtbd-framework.md checklist.md \
   report-template.md html-template.md \
   PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md SELF-TEST-BAO-CAO.md \
   ~/.cursor/skills/audit-uiux/
cp scripts/*.md ~/.cursor/skills/audit-uiux/scripts/

# Claude Code
mkdir -p ~/.claude/agents/scripts
cp claude-agent.md ~/.claude/agents/audit-uiux.md
cp gate-rules.md heuristics.md jtbd-framework.md checklist.md \
   report-template.md html-template.md \
   PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md SELF-TEST-BAO-CAO.md \
   ~/.claude/agents/
cp scripts/*.md ~/.claude/agents/scripts/
```

---

## Sử dụng

### Lấy link Figma đúng

1. Mở Figma file
2. Right-click **frame/màn hình** cần audit
3. **Copy link** → URL phải có `?node-id=...`

Ví dụ:

```text
https://www.figma.com/design/<FILE_KEY>/<FILE_NAME>?node-id=<NODE_ID>&t=...
```

### Prompt mẫu

```text
Audit UI/UX cho màn hình: <Figma URL có node-id>
Nền tảng: iOS / Android / Web
Persona: ...
JTBD: ...
Tiêu chí thành công: ...
```

### Output tạo ra

Agent sẽ tạo thư mục:

```text
~/Downloads/audit-report-<screen>-<YYYY-MM-DD>/
```

Bao gồm:
- `bao-cao.md`
- `bao-cao.html`
- `screenshot-overview.png`
- `screenshot-F-*.png`
- `review-scratchpad-*.md` (debug/resume)

### Xuất `bao-cao.html` ổn định (script)

Sau khi đã có `bao-cao.md` + ảnh trong cùng thư mục, có thể render HTML **cùng theme mọi lần** (không phụ thuộc LLM):

```bash
cd /path/to/audit-uiux-skill
npm install
npm run render-report -- ~/Downloads/audit-report-<screen>-<date>/bao-cao.md
```

Shell CSS nằm trong [`scripts/report-shell.html`](scripts/report-shell.html). Chi tiết: [`html-template.md`](html-template.md).

### COOK NOW (tuỳ chọn)

Sau khi có báo cáo, bạn có thể yêu cầu agent sửa trực tiếp Figma theo checklist trong báo cáo:

```text
COOK NOW các mục: A-001, A-003
```

> Điều kiện: tài khoản Figma đã Authenticate OAuth phải có quyền **edit** với file đó.

---

## Troubleshooting

| Hiện tượng | Cách xử lý |
|------------|-----------|
| Claude “chat thường” không có `/mcp` | Bạn đang ở Claude app chat → cần Claude Code |
| MCP `figma` chưa connected | `/mcp` → `figma` → Authenticate/Allow |
| `permission denied` | Authenticate nhầm account, hoặc account không có quyền file/team |
| `node không tồn tại` | Copy link mới từ đúng frame (có `node-id`) |
| Tool chậm / output bị cắt | Giảm scope: chọn frame nhỏ hơn, tránh audit cả page/file |

---

## Cấu trúc file trong repo

- `SKILL.md`: brain file cho Cursor
- `claude-agent.md`: brain file cho Claude Code (được copy thành `~/.claude/agents/audit-uiux.md`)
- `gate-rules.md`, `checklist.md`, `heuristics.md`, `jtbd-framework.md`: KB cốt lõi
- `report-template.md`, `html-template.md`: template báo cáo
- `scripts/`: scanner + `render-report.mjs`, `report-shell.html`
- `package.json`: dependency `marked` cho `npm run render-report`
- `install.sh`: script cài đặt

---

## Tham khảo

- Triết lý + ví dụ output: [GIOI-THIEU.md](GIOI-THIEU.md)
- Workflow chi tiết: `SKILL.md` / `claude-agent.md`
- Hướng dẫn official Figma MCP: [`https://developers.figma.com/docs/figma-mcp-server/`](https://developers.figma.com/docs/figma-mcp-server/)
