# Báo cáo Self-test — Audit UI/UX Agent

**Ngày:** 2026-05-04 (máy môi trường agent)  
**Phạm vi:** Kiểm tra tài liệu + kết nối Figma MCP; không chạy full audit trên file Figma “vàng/sạch” vì cần file test do team chuẩn bị.

---

## 1. Ma trận T1–T4 (máy lạnh)

| ID | Mô tả | Kết quả | Ghi chú |
|----|--------|---------|---------|
| **T1** | Đủ file bắt buộc trong `audit-uiux/` | **PASS** | Có `SKILL.md`, `report-template.md`, `heuristics.md`, `gate-rules.md`, `install.sh`, `claude-agent.md`, … |
| **T2** | Nhất quán quyết định bàn giao: gate vs điểm /100 | **PASS** (sau chỉnh sửa) | `SKILL.md` Step 12: gate-rules là chuẩn chính; điểm /100 từ checklist là bổ sung; ưu tiên gate khi mâu thuẫn. |
| **T3** | Grep lệch version (9 bước, APPLY) | **PASS** (sau chỉnh sửa) | Sửa `PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md` (9 → 12 bước). Không còn “9 bước” trong repo. |
| **T4** | `install.sh` hợp lệ | **PASS** | `bash -n install.sh` — cú pháp OK. `gate-rules.md` đã thêm vào `AGENT_FILES` + `KB_FILES`. |

---

## 2. Ma trận F1–F5 (Figma MCP)

| ID | Mô tả | Kết quả | Ghi chú |
|----|--------|---------|---------|
| **F1** | `whoami` Figma MCP | **PASS** | Xác thực thành công (email/handle/plans trả về). |
| **F2** | Màn “vàng” (lỗi cố ý) | **SKIP** | Cần URL + file test cố định do team cung cấp. |
| **F3** | Màn “sạch” | **SKIP** | Cùng lý do. |
| **F4** | Brief mâu thuẫn | **SKIP** | Cần chạy agent trong session chat với prompt cụ thể. |
| **F5** | Xuất `bao-cao.md` + `bao-cao.html` tại `~/Downloads/` | **SKIP** | Cần chạy full workflow Step 12 với quyền ghi file của agent. |

**Khuyến nghị:** Chuẩn bị 2 file Figma (vàng/sạch), lưu URL trong wiki nội bộ, lặp lại F2–F5 mỗi khi đổi phiên bản skill.

---

## 3. Rubric khả năng hoạt động (0–5, đánh giá **thiết kế agent + tài liệu**, không phải một lần chạy audit cụ thể)

| Tiêu chí | Điểm | Nhận xét |
|----------|------|----------|
| **Đúng fact từ Figma** | 3/5 | Phụ thuộc MCP + phạm vi `node-id`; agent có thể đọc sai nếu node quá lớn (truncate). |
| **Đúng nguyên tắc** | 4/5 | Heuristic + `gate-rules` rõ; rủi ro ở % H1–H11 nếu không đếm thật. |
| **Tính hành động** | 4/5 | Template + P0/P1/COOK NOW; tốt nếu finding gắn node. |
| **Trung thực uncertainty** | 3/5 | Đã bổ sung quy tắc anti-hallucination + mục “Giới hạn định lượng” trong template; cần kỷ luật khi chạy. |
| **Nhất quán nội bộ** | 4/5 | (Sau sửa) Gate vs /100 đã tách vai trò; còn rủi ro nếu agent cũ không đọc `gate-rules.md`. |

**Trung bình ~3.6/5** — agent mạnh về **khung** và **báo cáo**, yếu hơn ở **định lượng y hệt tool chuyên dụng** nếu không có bước đếm xác thực.

---

## 4. Ưu điểm (tóm tắt)

- Quy trình 12 bước + gate 3 tầng + báo cáo có cấu trúc.  
- Đa lăng kính: JTBD, heuristic, UX Writing/Flow/Emotion, behavioral impact.  
- `gate-rules.md` chuẩn hóa READY/BLOCKED.  
- Phân phối qua GitHub + `install.sh`; HTML portable.  
- Thừa nhận giới hạn (template + SKILL).

## 5. Nhược điểm / rủi ro

- % Hard Gate và danh sách node: dễ “trông giống số liệu máy” nếu không gắn `[inferred]`.  
- Emotion / tần suất: thiếu dữ liệu người dùng thật.  
- Một screenshot = một viewport; “above fold” có thể lệch thiết bị.  
- Ghi `~/Downloads/` phụ thuộc môi trường agent (sandbox).

## 6. Điểm phi thực tế (agent ≠ người)

- Emotion map, Peak-End: văn bản suy diễn, không validate được bằng user research.  
- JTBD khi “audit luôn”: đúng mặt UI, có thể sai nghiệp vụ sâu.  
- Bias tự tin của LLM — cần template disclaimer + kỷ luật `[ước lượng]`.

---

## 7. Thay đổi tài liệu đã áp dụng (doc-fixes)

| File | Thay đổi |
|------|----------|
| [SKILL.md](SKILL.md) | Prerequisites + Step 12: ưu tiên `gate-rules`, điểm /100 bổ sung, anti-hallucination H1–H11, Reference `gate-rules.md`. |
| [report-template.md](report-template.md) | Bước 12; thêm mục **Giới hạn định lượng và phương pháp**. |
| [PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md](PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md) | 12 bước; bảng file: `gate-rules`, `html-template`. |
| [install.sh](install.sh) | `gate-rules.md` trong `AGENT_FILES` + `KB_FILES`. |
| [README.md](README.md) | 7 file KB; dòng `gate-rules.md` trong bảng cấu trúc. |

---

## 8. Việc còn lại cho team

1. Chạy **F2–F5** với file Figma chuẩn hóa.  
2. Định kỳ **đồng bộ** skill local với `git pull` / copy từ repo.  
3. (Tùy chọn) Thêm script đếm WCAG/contrast thật qua plugin — giảm phụ thuộc suy luận cho H1.
