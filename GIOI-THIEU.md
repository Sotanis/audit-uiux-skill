# Audit UI/UX Agent — Giới thiệu

## Agent này là gì?

Audit UI/UX là một AI agent chuyên **review thiết kế Figma trước khi bàn giao cho developer**. Agent đọc trực tiếp file Figma qua MCP, phân tích theo 4 trục độc lập (UI / UX / Nghiệp vụ / Use-case), và trả lời câu hỏi quan trọng nhất:

> **"Thiết kế này đã đủ chín để bàn giao cho dev chưa?"**

Câu trả lời không phải điểm số mơ hồ "78/100", mà là **quyết định nhị phân**: `READY` / `READY WITH NOTES` / `NEEDS REWORK` / `BLOCKED`.

Agent hoạt động trên **Cursor** và **Claude Code**, output báo cáo tiếng Việt.

---

## Triết lý đằng sau

### Outcome 80%, không phải 100%

100% là trạng thái lý tưởng không tồn tại trên thiết kế tĩnh. 80% là ngưỡng "đủ chín để dev không phải hỏi lại quá 2 lần / màn".

### MIN, không phải AVERAGE

4 trục đánh giá: UI, UX, Nghiệp vụ, Use-case. Quyết định cuối = **MIN(4 trục)**, không phải trung bình. Lý do: 1 trục yếu kéo cả thiết kế. Tổng điểm 85 nhưng Nghiệp vụ chỉ 60% nghĩa là dev sẽ phát hiện thiếu nghiệp vụ giữa code, đập đi làm lại.

### Hypothesis có bằng chứng, không phải sở thích

Mỗi đề xuất sửa phải kèm hypothesis có nguồn: Baymard, Nielsen, WCAG, Material, cognitive law, data benchmark. Cấm "vì đẹp hơn", "vì best practice".

### 5 finding sắc bén > 30 finding nhạt

Agent không pad báo cáo. Finding nào không gắn được với user story → đó là polish hoặc noise, bỏ.

---

## Agent làm được gì?

### 1. Đọc và phân tích thiết kế Figma tự động

- Chụp ảnh khung (`get_screenshot`), đọc cây layer (`get_metadata`), lấy token/component (`get_design_context`) — qua Figma MCP, không cần xuất file thủ công
- Hỗ trợ 3 phạm vi: một màn hình, một luồng nhiều màn, một component cụ thể

### 2. Đánh giá theo 4 trục độc lập

| Trục | Đánh giá | Items active | Out_of_scope |
|------|----------|-------------|--------------|
| **UI** (Craft) | Token, type scale, spacing, contrast, icon, state coverage, auto-layout | 11 | 1 (zoom 200%) |
| **UX** (Usability) | Nielsen heuristics, hierarchy, flow, feedback, error prevention, navigation | 9 | 3 (first-glance, attention, timing) |
| **Nghiệp vụ** (Business Logic) | Happy/unhappy path, edge case, role/permission, data state, validation, trust signal | 10 | 0 |
| **Use-case** (JTBD Coverage) | User story coverage, AC testable, outcome metrics, không US/UI orphan | 8 | 0 |

Mỗi item gắn nhãn **Method**: `measured` (đo trực tiếp từ Figma data) / `inferred` (agent judgment, có sai số ±10–15%) / `out_of_scope` (không đo được trên design tĩnh, chuyển vào "Khuyến nghị test sau bàn giao"). Báo cáo minh bạch tỷ lệ measured/inferred cho mỗi trục — không giả vờ tất cả đều đo được.

Nguồn tham chiếu: **Apple HIG**, **Material Design**, **Nielsen 10 Heuristics**, **WCAG 2.2 AA**, **Baymard research**, **Laws of UX**.

### 3. Hệ thống gate 3 tầng cho quyết định bàn giao

```
Tầng 1 — HARD GATE     (vi phạm = BLOCKED ngay)
Tầng 2 — SCORE GATE    (MIN 4 trục ≥ 80% mới READY)
Tầng 3 — SEVERITY GATE (P0 mở > 0 = BLOCKED)

Quyết định cuối = MIN(3 tầng)
```

**Tầng 1 — Hard Gate** có 11 ngưỡng cứng không thương lượng:

- Contrast WCAG AA: ≥95% text đạt 4.5:1
- Tap target: ≥95% interactive đạt 24×24 CSS px (mobile khuyến nghị 44×44)
- Primary CTA tồn tại + duy nhất / màn
- Empty / Error / Loading state đầy đủ
- Destructive action có confirm hoặc undo
- Layer naming: ≤20% mặc định
- Detached components: ≤5%
- Hardcoded color: ≤10%
- Auto-layout: ≥80% container

Vi phạm bất kỳ → BLOCKED, không cần tính tiếp.

### 4. Phân tích JTBD bám đúng nghiệp vụ

Mỗi review bắt buộc xác định 3 lớp framing:

- **JTBD**: "Khi [tình huống], tôi muốn [hành động] để [outcome]"
- **User Stories** (US-01 … US-N, tối đa 5): "Là [vai trò], tôi muốn [hành động] để [lợi ích]" + 3–5 acceptance criteria testable
- **Hypothesis**: "Tin rằng [decision] cho [user] sẽ [outcome đo được] vì [bằng chứng]"

Mọi finding 🔴/🟡 phải gắn US-XX. Không gắn được → bỏ.

### 5. Phân loại 3 mức độ với quy tắc nâng severity

| Mức | Nghĩa |
|-----|-------|
| **🔴 P0** | Chặn bàn giao — fail WCAG AA, dark pattern, mất tiền/data, chặn job chính |
| **🟡 P1** | Sửa trong sprint — friction lớn, có workaround |
| **🟢 P2** | Polish, sau cũng được |

Quy tắc nâng tự động: vi phạm hard gate → P0; chặn job step Execute/Confirm → ≥ P1; US ❌ Chưa đáp ứng → ≥ P1.

### 6. Mỗi finding có ảnh chụp vùng lỗi

Agent gọi `get_screenshot(fileKey, nodeId)` cho **đúng node lỗi**, không dùng ảnh toàn màn. Báo cáo HTML hiển thị side-by-side: "Vùng có vấn đề" + "Ngữ cảnh xung quanh", viền màu theo severity (đỏ P0, cam P1, xám P2).

Validation cuối cùng: 100% finding 🔴/🟡 phải có ảnh trước khi compile.

### 7. Phased execution kỷ luật token

```
P0 Triage + Framing  (~1.5–3K tokens) — fetch Figma 1 lần, derive JTBD/US/Hypothesis
P1 Load KB targeted  (~1.5–2K tokens) — chỉ load section của lens cần chạy
P2 Run 4 lenses      (~1.5–3K/lens)   — compressed finding vào scratchpad
P3 Compute Gate      (~3–5K tokens)   — tính %, ra decision, expand prose
P4 Apply fix         (~1K/edit)       — chỉ khi user xác nhận COOK NOW
```

Tổng token thực tế theo scope:

| Scope | Token budget |
|-------|--------------|
| Component đơn lẻ | 10–20K |
| 1 màn trung bình (≤50 nodes) | 20–40K |
| 1 màn phức tạp (>50 nodes, có biến/component lồng) | 40–70K |
| Luồng 3–5 màn | 80–150K — đề xuất chia phiên 1 màn / session |

Naive review không phased có thể vượt 100K cho 1 màn — chênh lệch là kỷ luật phase + scratchpad. Agent có **Token guard** ở P0: nếu node count >80 hoặc `get_design_context` truncate, agent cảnh báo và đề xuất chia subtree thay vì cố gắng nuốt cả file.

### 8. Resumability — review bị ngắt vẫn tiếp được

Agent ghi state vào file `review-scratchpad-<screen>-<timestamp>.md`. Bạn audit 1 màn lớn trong 2 session, bị ngắt giữa chừng vẫn tiếp tục từ đó, không phải làm lại.

### 9. Sửa trực tiếp trên Figma (chế độ COOK NOW)

Sau khi nhận báo cáo, nếu muốn agent sửa luôn:

1. Agent tạo checklist `A-XXX` (auto / needs_decision / manual)
2. Bạn chọn mục muốn sửa
3. Gõ **COOK NOW** để xác nhận
4. Agent backup → sửa từng batch nhỏ → chụp ảnh trước/sau

Không bao giờ động đến design system source-of-truth — đề xuất designer tự làm.

---

## Hỗ trợ những công việc gì?

| Công việc | Cách dùng |
|-----------|-----------|
| **Self-audit trước bàn giao** | Gửi URL Figma → nhận quyết định READY/REWORK + checklist sửa |
| **Kiểm tra luồng người dùng** | Gửi nhiều URL theo thứ tự → agent đánh giá cả luồng + flow continuity |
| **Kiểm tra component** | Gửi URL node → agent kiểm variant, state, token (skip lens Nghiệp vụ + Use-case) |
| **Đánh giá design system** | Agent kiểm token usage, detached, hardcoded, missing state |
| **Chuẩn bị tài liệu bàn giao** | Báo cáo có Gate Decision Box + ảnh node + đề xuất cụ thể |
| **Sửa nhanh trên Figma** | Chọn checklist → COOK NOW → agent sửa, bạn kiểm tra |
| **Tối ưu cho AI codegen** | Hard gate H8–H11 đảm bảo AI codegen dev sinh code chuẩn (layer naming, token, auto-layout) |

---

## Output mẫu

Mỗi báo cáo bắt đầu bằng **Gate Decision Box**:

```
═══════════════════════════════════════════════
HAND-OFF DECISION: ❌ NEEDS REWORK
═══════════════════════════════════════════════

📊 Score 4 trục (cần MIN ≥ 80%):
  UI         ████████░░  82% [Tốt]
  UX         █████████░  91% [Xuất sắc]
  Nghiệp vụ  ██████░░░░  64% [Trung bình] ← KÉO TỔNG XUỐNG
  Use-case   ████████░░  85% [Tốt]
  ─────────────────────────────────
  MIN        64% — chưa đạt ngưỡng 80%

🚦 3 tầng gate:
  Tầng 1 Hard Gate:  ✅ PASS
  Tầng 2 Score Gate: ❌ FAIL (Nghiệp vụ 64%)
  Tầng 3 Severity:   ⚠️ 1 P0 mở, 5 P1 mở

⚠️ Hành động bắt buộc trước bàn giao:
  1. Sửa P0 [F-003]: thiếu confirmation dialog ở action xóa
  2. Bổ sung 4 unhappy path (network/session/permission/invalid)
  3. Sau khi fix → audit lại

📈 Khoảng cách đến READY:
  - Trục Nghiệp vụ cần +16 điểm (2 item nữa)
  - Đóng 1 P0 + đóng ít nhất 2 P1
═══════════════════════════════════════════════
```

Sau Gate Decision Box: JTBD + User Stories + danh sách finding 🔴 → 🟡 → 🟢 với ảnh node + hypothesis + đề xuất.

---

## Lợi ích

### Quyết định nhị phân thay vì điểm mơ hồ

Cũ: "78/100 — bàn giao được không?" Bạn tự diễn giải.
Mới: BLOCKED / NEEDS REWORK / READY WITH NOTES / READY — không tranh cãi.

### Tránh "điểm cao gian lận"

MIN(4 trục) + Severity Gate ngăn tình huống "85/100 nhưng có 1 P0 chí mạng, hoặc Nghiệp vụ chỉ 60%".

### Action rõ ràng

Mỗi báo cáo có dòng "Khoảng cách đến READY: trục X cần +16 điểm (2 item nữa) + đóng 1 P0" → bạn biết chính xác phải làm gì, không tê liệt với 30 finding.

### Tiết kiệm thời gian

- Self-audit thủ công 1 màn: 30–60 phút
- Với agent: 5–10 phút (gồm đọc báo cáo)
- Không cần chụp ảnh, mở tab so sánh, tra WCAG / HIG

### Phù hợp pipeline AI codegen

Hard gate H8 (layer naming) + H9 (detached) + H10 (hardcoded color) + H11 (auto-layout) đảm bảo AI codegen của dev đọc Figma → sinh code chuẩn, ít rác.

### Báo cáo có bằng chứng

- Mỗi finding có ảnh node lỗi + node ID Figma + số đo cụ thể (contrast 2.1:1, size 32×32, spacing 13px)
- Hypothesis trích nguồn cụ thể (Baymard, Nielsen, WCAG)
- Dev đọc xong biết sửa ở đâu, sửa gì, vì sao

### Gắn với mục đích người dùng

Mỗi finding 🔴/🟡 link tới user story bị ảnh hưởng. Không đề xuất "đẹp hơn" — chỉ đề xuất "khôi phục outcome cho user".

### Resumability

Bị ngắt giữa chừng tiếp được. Không mất công làm lại.

---

## Giới hạn cần biết

| Giới hạn | Giải thích |
|----------|-----------|
| Không thay review của người | Agent hỗ trợ, không thay design lead / PM sign-off |
| JTBD có thể suy luận sai | Nếu thiếu brief, agent đoán từ giao diện — ghi rõ "suy luận" trong báo cáo |
| Không chạy prototype thật | Đánh giá luồng dựa ảnh tĩnh + liên kết, không tương tác |
| Trạng thái động hạn chế | Hover / animation chỉ đánh giá được nếu có frame/variant riêng |
| WCAG trên design | Đánh giá rule + giá trị từ context, không thay axe / VoiceOver trên bản build |
| File Figma quá lớn | `get_design_context` truncate → có thể sót chi tiết dù đã chia phần |
| Hành vi người dùng thật | Behavioral impact là lập luận từ heuristic, không phải research thực địa |

Khi giới hạn áp dụng, agent ghi rõ trong phần ghi chú cuối báo cáo (ví dụ: "thiếu variant trạng thái", "JTBD suy luận", "prototype chưa test trên thiết bị").

---

## Khác biệt so với phiên bản cũ

| Trước | Sau |
|-------|-----|
| 8 nhóm heuristic + 12 bước workflow | 4 trục độc lập + 5 phase execution |
| Điểm 4 trụ × 25 (tổng /100) | % 4 trục, MIN quyết định, ngưỡng 80% mỗi trục |
| Output điểm số "78/100" | Output decision: READY / WITH NOTES / REWORK / BLOCKED |
| Finding có thể không gắn US | Finding 🔴/🟡 BẮT BUỘC gắn US-XX |
| Step UX Emotion đoán cảm xúc | Bỏ — không đo được trên design tĩnh |
| Hypothesis có thể chung chung | Hypothesis BẮT BUỘC trích nguồn (Baymard / Nielsen / WCAG / cognitive law) |
| Ảnh chụp dễ bị quên | Schema bắt buộc `[img:F-XXX]` + validation P3 |
| Token cao 50–80K / màn không kiểm soát | Phased execution + token guard, chia chunk khi vượt ngưỡng |
| Không resume được | Resume từ scratchpad |
| Không chống "điểm cao gian lận" | Severity Gate: P0 mở > 0 = BLOCKED bất kể điểm |

---

## Bắt đầu

Xem [README.md](README.md) để cài đặt và sử dụng.

Tài liệu kỹ thuật:
- [SKILL.md](SKILL.md) — Brain file cho Cursor
- [claude-agent.md](claude-agent.md) — Brain file cho Claude Code
- [gate-rules.md](gate-rules.md) — Công thức tính %, ngưỡng gate
- [heuristics.md](heuristics.md) — 8 nhóm tiêu chí chi tiết
- [jtbd-framework.md](jtbd-framework.md) — Job Map, user-story, hypothesis
- [checklist.md](checklist.md) — Checklist hand-off
- [report-template.md](report-template.md) — Template báo cáo
- [html-template.md](html-template.md) — Xuất HTML có ảnh nhúng
- [PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md](PHAM-VI-TIEU-CHI-VA-THAM-CHIEU.md) — Phạm vi & tham chiếu
