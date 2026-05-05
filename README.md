# Audit UI/UX — Figma Design Review Agent

Agent review thiết kế Figma trước khi bàn giao cho developer. Kết hợp JTBD framework + heuristic evaluation (Apple HIG, Material Design, Nielsen). Báo cáo tiếng Việt với phân loại P0/P1/P2.

Hỗ trợ **Cursor** và **Claude Code**. Xem [GIOI-THIEU.md](GIOI-THIEU.md) để biết agent làm được gì và lợi ích chi tiết.

---

## Cài đặt

### Cách 1 — Một lệnh (tự tải từ GitHub)

Mở **Terminal**, chạy:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Sotanis/audit-uiux/main/install.sh)
```

Script tự tải tất cả file từ GitHub → hỏi bạn dùng gì → copy vào đúng chỗ.

### Cách 2 — Tải folder về trước

1. Nhấn **Code → Download ZIP** trên [GitHub](https://github.com/Sotanis/audit-uiux), giải nén
2. Mở Terminal:

```bash
cd ~/Downloads/audit-uiux
./install.sh
```

### Script làm gì?

Hỏi bạn dùng **Cursor**, **Claude Code**, hay **cả hai** — rồi tự copy file:

| Chọn | File được copy | Đích |
|------|---------------|------|
| **Cursor** | `SKILL.md` + 8 file KB | `~/.cursor/skills/audit-uiux/` |
| **Claude Code** | `claude-agent.md` (→ đổi tên thành `audit-uiux.md`) + 8 file KB | `~/.claude/agents/` |
| **Cả hai** | Cả hai bước trên | Cả hai thư mục |

8 file KB: `gate-rules.md`, `heuristics.md`, `jtbd-framework.md`, `checklist.md`, `report-template.md`, `html-template.md`, `PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md`, `SELF-TEST-BAO-CAO.md`.

---

## Kết nối Figma MCP

### Bước 1: Tạo Figma Token

1. Mở **Figma** → **Settings** → **Personal Access Tokens**
2. Nhấn **Generate new token** → đặt tên (ví dụ: `audit-agent`)
3. Quyền: **File content — read** (thêm **write** nếu muốn dùng chế độ COOK NOW sửa trực tiếp)
4. Nhấn **Generate** → sao chép token (chỉ hiện một lần)

### Bước 2: Kết nối trong công cụ bạn dùng

**Cursor:**

1. Mở **Cursor Settings** (Cmd + , hoặc bánh răng góc trái dưới) → chọn mục **MCP**
2. Nhấn **+ Add new MCP server**
3. Điền:
   - Name: `figma`
   - Type: `command`
   - Command: `npx -y @anthropic-ai/figma-mcp@latest`
4. Mở phần **Environment Variables** → thêm:
   - Key: `FIGMA_ACCESS_TOKEN`
   - Value: token vừa tạo
5. Nhấn **Save** → chờ trạng thái chuyển sang **connected**

**Claude Code:**

1. Mở Claude Code, gõ `/mcp`
2. Chọn **Add new MCP server**
3. Điền:
   - Name: `figma`
   - Type: `command`
   - Command: `npx -y @anthropic-ai/figma-mcp@latest`
4. Khi được hỏi biến môi trường → thêm `FIGMA_ACCESS_TOKEN` = token vừa tạo
5. Scope: chọn **User** (dùng cho mọi project)
6. Lưu → trạng thái hiện **connected** là thành công

---

## Sử dụng

### Lấy đường dẫn Figma

Trong Figma → chuột phải vào frame cần audit → **Copy link**. Đường dẫn cần chứa `node-id`.

### Gọi Agent

**Cursor:**

1. Mở **Agent chat** (Cmd + L hoặc nhấn biểu tượng chat)
2. Gõ yêu cầu audit hoặc /audit-uiux kèm đường dẫn Figma:

```
Audit UI/UX cho màn hình: https://figma.com/design/ABC123/App?node-id=10-5
/audit-uiux thiết kế https://figma.com/design/ABC123/App?node-id=10-5

```

Cursor tự nhận skill `audit-uiux` và chạy workflow.

**Claude Code:**

1. Mở Claude Code trong Terminal
2. Gõ yêu cầu tương tự — Claude tự delegate cho agent `audit-uiux` dựa vào nội dung tin nhắn:

```
Audit UI/UX cho màn hình: https://figma.com/design/ABC123/App?node-id=10-5

```

Nếu Claude không tự delegate, gọi trực tiếp:

```
Dùng audit-uiux để review: https://figma.com/design/ABC123/App?node-id=10-5
```

### Trả lời câu hỏi bổ sung

Agent có thể hỏi 1–3 câu nếu thiếu thông tin (chân dung, công việc, tiêu chí thành công). Trả lời ngắn gọn hoặc gõ **"audit luôn"** để bỏ qua.

### Các kiểu phạm vi

| Phạm vi | Cách gọi |
|---------|----------|
| Một màn hình | Gửi 1 URL |
| Luồng nhiều màn | Liệt kê nhiều URL theo thứ tự |
| Một thành phần | Gửi URL node + ghi chú |
| Chỉ vài hạng mục | Ghi rõ nhóm cần đánh giá |

### Sau khi nhận báo cáo

- Điểm /100, phân loại P0 / P1 / P2, bằng chứng kèm ảnh, đề xuất sửa.
- Báo cáo xuất **2 bản**: markdown (`.md`) + **HTML** (`.html` — ảnh nhúng sẵn, gửi 1 file xem ngay trên trình duyệt).
- Muốn agent **sửa trực tiếp trên Figma**: chọn mục trong checklist → xác nhận **COOK NOW**.

---

## Cấu trúc file

| File | Vai trò |
|------|---------|
| `install.sh` | Script cài đặt |
| `SKILL.md` | Brain file cho Cursor |
| `claude-agent.md` | Brain file cho Claude Code |
| `gate-rules.md` | Gate bàn giao (Hard / Score / Severity) |
| `heuristics.md` | Bộ tiêu chí đánh giá (8 nhóm) |
| `jtbd-framework.md` | Khung phân tích JTBD |
| `checklist.md` | Checklist bàn giao |
| `report-template.md` | Mẫu báo cáo |
| `html-template.md` | Hướng dẫn xuất báo cáo HTML |
| `PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md` | Phạm vi & tham chiếu |
| `SELF-TEST-BAO-CAO.md` | Kết quả self-test agent (máy lạnh + MCP) |

---

## Xử lý sự cố

| Hiện tượng | Gợi ý |
|------------|--------|
| Agent không nhận | Cursor: Reload Window. Claude Code: restart (`/exit` rồi `claude`) |
| MCP không connected | Kiểm tra token, thử tạo lại |
| Không đọc được file Figma | Token thiếu quyền hoặc file thuộc team khác |
| Báo cáo bị cắt | Thu hẹp `node-id` hoặc chia nhỏ scope |
| COOK NOW không sửa được | Token Figma cần quyền **write** |
