# Phạm vi Agent, Căn cứ Tham chiếu và Tiêu chí Đánh giá

Tài liệu mô tả **phạm vi** skill **Audit UI/UX**, **nguồn thông tin** agent dùng, và **tiêu chí** đánh giá / phân loại. Dùng chung cho Cursor và Claude Code.

**Workflow chi tiết từng phase:** [SKILL.md](SKILL.md) (Cursor) hoặc [claude-agent.md](claude-agent.md) (Claude Code)
**Công thức gate + ngưỡng:** [gate-rules.md](gate-rules.md)
**Checklist 4 trục:** [checklist.md](checklist.md)

---

## 1. Phạm vi Agent có thể thực hiện

### 1.1 Trong phạm vi (agent thiết kế để làm)

| Hạng mục | Mô tả |
|----------|--------|
| **Đọc thiết kế Figma qua MCP** | Ảnh chụp khung, cây layer (`metadata`), ngữ cảnh thiết kế (`design context`: token, style, component), biến (`variable defs`), tìm trong thư viện (`search_design_system`). |
| **Xác định phạm vi audit** | Một màn hình, một luồng nhiều URL, hoặc một component / khung cụ thể (theo `node-id`). |
| **Ánh xạ JTBD** | Công việc chính, bản đồ bước công việc, câu chuyện người dùng, giả thuyết thiết kế, kết quả mong đợi (tốc độ / chính xác / hài lòng) — có thể **suy luận** từ giao diện nếu thiếu brief. |
| **Đánh giá theo 4 trục độc lập** | UI / UX / Nghiệp vụ / Use-case (mục 3.2), bám [checklist.md](checklist.md). |
| **Tính 3-tầng gate** | Hard Gate (11 mục, vi phạm = BLOCKED) → Score Gate (MIN 4 trục ≥80%) → Severity Gate (P0 mở > 0 = BLOCKED). Quyết định cuối = MIN(3 tầng). |
| **Phân tích tác động hành vi** | Với mỗi finding 🔴/🟡: ảnh hưởng hành vi → ảnh hưởng câu chuyện người dùng → ảnh hưởng kết quả. |
| **Phân loại mức độ** | P0 / P1 / P2 + quy tắc nâng severity (vi phạm hard gate H1–H7 → P0; chặn job step Execute/Confirm → ≥P1; v.v.) |
| **Xuất báo cáo** | Tiếng Việt, theo [report-template.md](report-template.md), có **bảng thuật ngữ** + **Khuyến nghị test sau bàn giao** cho items `out_of_scope`. |
| **Hỏi bổ sung có kiểm soát** | Tối đa **3 câu** (chân dung, công việc, tiêu chí thành công) khi thiếu — xem [SKILL.md — Cơ chế hỏi bổ sung](SKILL.md). |
| **COOK NOW (tùy chọn)** | Sửa trực tiếp Figma theo checklist user chọn — backup trước, batch nhỏ, ảnh trước/sau. |

### 1.2 Ngoài phạm vi (agent không cam kết hoặc chỉ hỗ trợ một phần)

| Hạng mục | Giải thích ngắn |
|----------|------------------|
| **Thay review người** | Không thay design lead / PM / dev sign-off. |
| **Xác minh đúng nghiệp vụ tuyệt đối** | Chỉ kiểm tra **phù hợp** với giả định và brief đã cho. |
| **Usability test thật** | Không có người dùng thật — UX-01 first-glance, UX-03 attention map là `out_of_scope`, đưa vào "Khuyến nghị test sau bàn giao". |
| **Prototype giống thiết bị** | Không chạy prototype đầy đủ như trên máy thật; luồng nhánh là **suy luận** từ màn hình và mô tả. |
| **Trạng thái động** | Hover, focus, animation: chỉ đánh giá được nếu có **khung/variant** riêng cho từng trạng thái. UX-04 feedback timing là `out_of_scope`. |
| **Tiếp cận (accessibility) trên bản build** | Đánh giá WCAG dựa trên thiết kế và giá trị hiển thị; **không** thay công cụ a11y trên code (axe, VoiceOver). UI-12 zoom 200% là `out_of_scope`. |
| **Tuân thủ pháp lý / thương hiệu đầy đủ** | Chỉ khi bạn cung cấp quy tắc hoặc yêu cầu rõ trong prompt. |
| **Đảm bảo code giống Figma 1:1** | Thuộc triển khai và QC sau bàn giao. |
| **Quét cả thư viện Figma không giới hạn** | Cần giới hạn `node` / luồng; agent có **token guard** ở P0 cảnh báo nếu node count >80. |

Chi tiết giới hạn kỹ thuật và phương pháp: [SKILL.md — Giới hạn đã biết](SKILL.md).

---

## 2. Căn cứ và thông tin tham chiếu

### 2.1 Nguồn từ Figma (qua MCP)

| Nguồn | Công cụ MCP (tên thường dùng) | Dùng để |
|--------|-------------------------------|---------|
| Ảnh khung | `get_screenshot` | Bằng chứng trực quan, so sánh mong đợi / thực tế, chụp vùng lỗi cho mỗi finding |
| Cây layer | `get_metadata` | Tên layer, cấu trúc, kích thước, autolayout, constraints |
| Ngữ cảnh triển khai | `get_design_context` | Token, style, component, gợi ý token |
| Biến (variable) | `get_variable_defs` | Kiểm tra gán biến, chế độ sáng/tối |
| Thư viện | `get_libraries`, `search_design_system` | Khớp component/token với design system |
| Kiểm tra sâu / chỉnh sửa | `use_figma` (đọc + ghi nếu COOK NOW) | Thuộc tính node khi metadata không đủ; thực hiện edit ở P4 |

Công cụ cụ thể phụ thuộc máy chủ MCP bạn cài; danh mục đầy đủ theo tài liệu Figma MCP phiên bản hiện tại.

### 2.2 Nguồn từ folder skill (tài liệu đính kèm)

| File | Vai trò |
|------|---------|
| [SKILL.md](SKILL.md) | Brain file Cursor — workflow phased execution P0–P4, hỏi bổ sung 3 câu, ranh giới skill, giới hạn |
| [claude-agent.md](claude-agent.md) | Brain file Claude Code — cùng triết lý, frontmatter cho Claude |
| [gate-rules.md](gate-rules.md) | **Đọc đầu mỗi review.** 11 hard gate + 4 trục score gate + severity gate; method labels + công thức tính % |
| [checklist.md](checklist.md) | Checklist 4 trục UI(11) / UX(9) / NV(10) / UC(8) — dùng compute % ở P3 |
| [heuristics.md](heuristics.md) | Tám nhóm heuristic (Apple HIG + Material + Nielsen) — load section khi lens cần |
| [jtbd-framework.md](jtbd-framework.md) | Bản đồ công việc, mẫu câu chuyện người dùng, giả thuyết, ánh xạ bước → loại vấn đề UX |
| [report-template.md](report-template.md) | Khung báo cáo tiếng Việt, Gate Decision Box, Khuyến nghị test sau bàn giao, bảng thuật ngữ |
| [html-template.md](html-template.md) | Hướng dẫn xuất HTML có ảnh nhúng base64 |

### 2.3 Nguồn từ người dùng (prompt)

- Đường dẫn Figma có `node-id`
- Chân dung, công việc cần làm, tiêu chí thành công (hoặc trả lời sau 3 câu hỏi)
- Nền tảng (web / iOS / Android), mức tiếp cận mong muốn (nếu có)
- Phạm vi: một màn / luồng / component; có thể yêu cầu chỉ đánh giá một số trục (skip rules)

---

## 3. Tiêu chí đánh giá

### 3.1 Method labels — phân biệt độ tin cậy

Mỗi item gắn 1 trong 3 nhãn:

| Nhãn | Định nghĩa | Cách output |
|------|-----------|-------------|
| `measured` | Đo trực tiếp từ Figma MCP data (số đếm, ratio, %) | Hiển thị giá trị + nguồn data |
| `inferred` | Agent judgment dựa heuristic, có sai số ±10–15% | Hiển thị + cảnh báo "ước lượng" |
| `out_of_scope` | Không đo được trên design tĩnh — cần build / user test | **Không tính vào gate**, đưa vào §"Khuyến nghị test sau bàn giao" |

**Quy tắc compute %**: mẫu số chỉ đếm `measured` + `inferred`; nếu trục có ≥40% `inferred` → ghi confidence ±10%.

### 3.2 Bốn trục đánh giá

Tham chiếu đầy đủ: [checklist.md](checklist.md) + [gate-rules.md](gate-rules.md).

| Trục | Items active | Nội dung kiểm tra |
|------|-------------|-------------------|
| **UI** (Craft) | 11 (1 out_of_scope) | Token color/typography, spacing scale, type hierarchy, border radius, color palette, icon consistency, auto-layout, constraints, state coverage |
| **UX** (Usability) | 9 (3 out_of_scope) | Cognitive load, loading/empty/error state, dead-end, escape hatch, confirmation destructive, consistency platform, recognition over recall |
| **Nghiệp vụ** (Business Logic) | 10 | Happy/unhappy path, empty data, network error, permission denied, session expired, invalid input, role-based view, data scale, trust signal, confirmation summary |
| **Use-case** (JTBD Coverage) | 8 | JTBD rõ, US count, AC testable, US coverage, outcome metrics, hypothesis có bằng chứng, không US/UI orphan |

**Items `out_of_scope`** (4 mục): UI-12 zoom 200%, UX-01 first-glance test, UX-03 hierarchy attention, UX-04 feedback timing — đưa vào "Khuyến nghị test sau bàn giao".

### 3.3 Tám nhóm heuristic (đánh giá định tính + bằng chứng)

Áp dụng cho lens UI và UX. Tham chiếu đầy đủ: [heuristics.md](heuristics.md).

| # | Nhóm | Nội dung kiểm tra (tóm tắt) |
|---|------|-----------------------------|
| 1 | Hiển thị & phản hồi | Trạng thái hệ thống, tải, thành công/lỗi, trống |
| 2 | Nhất quán & chuẩn | Thuật ngữ, pattern, màu ngữ nghĩa, khoảng cách |
| 3 | Điều hướng & kiến trúc thông tin | Vị trí, lối thoát, tìm kiếm/lọc, không đường cụt |
| 4 | Chữ & khả năng đọc | Thang chữ, độ tương phản, độ dài dòng |
| 5 | Bố cục & khoảng cách | Lưới, scale khoảng cách, vùng chạm |
| 6 | Màu & độ tương phản | Token, WCAG, không chỉ dựa vào màu |
| 7 | Trạng thái tương tác | Mặc định, hover, nhấn, focus, vô hiệu, lỗi, đang tải |
| 8 | Ngăn lỗi & phục hồi | Xác nhận hành động nguy hiểm, thông báo lỗi rõ, hoàn tác |

### 3.4 Ba tầng gate quyết định bàn giao

Tham chiếu đầy đủ: [gate-rules.md](gate-rules.md).

```
Tầng 1 — HARD GATE     (vi phạm bất kỳ H1–H11 = BLOCKED ngay)
Tầng 2 — SCORE GATE    (MIN 4 trục ≥ 80% mới READY)
Tầng 3 — SEVERITY GATE (P0 mở > 0 = BLOCKED)

Quyết định cuối = MIN(3 tầng)
```

**Mức theo % trục:**

| % trục | Mức |
|--------|-----|
| 90–100 | Xuất sắc |
| 80–89  | Tốt (đạt ngưỡng pass) |
| 65–79  | Trung bình (chưa đạt) |
| < 65   | Yếu |

**Quyết định cuối:**

| Decision | Điều kiện |
|----------|-----------|
| **READY** | Hard gate PASS + MIN ≥ 90% + 0 P0 + ≤3 P1 |
| **READY WITH NOTES** | Hard gate PASS + MIN 80–89% + 0 P0 + ≤7 P1 |
| **NEEDS REWORK** | Có trục < 80%, hoặc >7 P1, hoặc Score Gate fail |
| **BLOCKED** | Vi phạm Hard Gate, hoặc có ≥1 P0 mở |

### 3.5 Mức độ nghiêm trọng (P0 / P1 / P2)

| Mức | Điều kiện (tóm tắt) | Trọng số JTBD |
|-----|---------------------|----------------|
| **P0** | Chặn hoàn thành công việc chính; người dùng không đạt kết quả mong đợi; hoặc không thể triển khai đúng nếu giữ nguyên thiết kế | Ảnh hưởng trực tiếp tới bước **Thực hiện** / **Xác nhận** hoặc chặn outcome |
| **P1** | Ma sát lớn; có cách vòng nhưng giảm chất lượng kết quả | Giảm tốc độ / chính xác / hài lòng rõ rệt |
| **P2** | Không chặn outcome; chủ yếu làm giảm độ mượt hoặc độ nhất quán | Ảnh hưởng nhẹ tới hài lòng hoặc nhất quán |

**Quy tắc nâng mức (bắt buộc):**
- Vi phạm hard gate H1–H7 → P0
- Chặn bước Thực hiện/Xác nhận → ≥ P1
- Khiến user không đạt outcome chính → P0
- Vi phạm WCAG AA rõ ràng → ≥ P1
- Có thể dẫn đến mất tiền / sai data quan trọng → P0
- US-XX bị mark ❌ Chưa đáp ứng → ≥ P1

### 3.6 Ma trận tần suất × tác động

Dùng kết hợp với P0–P2: lỗi **hay gặp + hậu quả lớn** → ưu tiên cao nhất trong báo cáo và khuyến nghị. Tần suất thường là **giả định** nếu không có dữ liệu sản phẩm trong prompt.

---

## 4. Liên kết nhanh

| Nội dung | File |
|----------|------|
| Giới thiệu agent | [GIOI-THIEU.md](GIOI-THIEU.md) |
| Cài đặt & sử dụng | [README.md](README.md) |
| Workflow Cursor | [SKILL.md](SKILL.md) |
| Workflow Claude Code | [claude-agent.md](claude-agent.md) |
| Công thức gate | [gate-rules.md](gate-rules.md) |
| Checklist 4 trục | [checklist.md](checklist.md) |
| Heuristic | [heuristics.md](heuristics.md) |
| JTBD framework | [jtbd-framework.md](jtbd-framework.md) |
| Template báo cáo | [report-template.md](report-template.md) |
| HTML export | [html-template.md](html-template.md) |
