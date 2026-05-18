# Báo cáo Self-test — Audit UI/UX Agent

**Ngày:** 2026-05-06 (máy môi trường agent)
**Phạm vi:** Kiểm tra tài liệu + cấu trúc workflow phased (P0–P4) + kết nối Figma MCP. Không chạy full audit trên file Figma "vàng/sạch" vì cần file test do team chuẩn bị.

---

## 1. Ma trận T1–T5 (máy lạnh, kiểm tra tài liệu)

| ID | Mô tả | Kết quả | Ghi chú |
|----|--------|---------|---------|
| **T1** | Đủ file bắt buộc trong `audit-uiux/` | **PASS** | `SKILL.md`, `claude-agent.md`, `report-template.md`, `heuristics.md`, `gate-rules.md`, `checklist.md`, `jtbd-framework.md`, `html-template.md`, `install.sh`, `scripts/` (10 file). |
| **T2** | Nhất quán workflow phased: SKILL.md ↔ claude-agent.md | **PASS** | Cả hai đều có 5 phase P0–P4, P0 step 6–7 (naming + measurement scripts), P3 Validation Checklist, sub-checklist UX Writing/Platform/Layout, cross-check H7. |
| **T3** | Nhất quán ngưỡng pass per-trục | **PASS** | `gate-rules.md` + `checklist.md` + `SKILL.md` + `claude-agent.md` + `GIOI-THIEU.md` đều ghi rõ UI ≥9/11, UX ≥8/9, NV ≥8/10, UC ≥7/8. |
| **T4** | `install.sh` hợp lệ + copy `scripts/` | **PASS** | `bash -n install.sh` cú pháp OK. `SCRIPT_FILES` array có 10 file, hàm `copy_scripts` áp cho Claude Code. |
| **T5** | Hard Gate H3, H8, H9, H10, H11 có scanner cover | **PASS** | `scripts/metadata-stat-counter.md` đếm 5 metric measured. |

---

## 2. Ma trận P-PHASES (kiểm tra workflow phased)

| Phase | Mô tả | Đầu vào | Đầu ra | Token budget |
|-------|-------|---------|--------|--------------|
| **P0** | Triage + Framing + Measurement | Figma URL, context | Scratchpad (Context, Framing, Lens Plan, Measurement Results) | ~5–10K |
| **P1** | Load KB targeted | Lens plan từ P0 | Đoạn KB cần thiết | ~1.5–2K |
| **P2** | Run 4 lenses + capture evidence | KB sections + measurement | Compressed findings + ảnh F-XXX | ~6–12K |
| **P3** | Compute gate + compile + validate | Scratchpad complete | `bao-cao.md` + `bao-cao.html` | ~4–6K |
| **P4** | Apply fix (gated, optional) | User confirm + checklist A-XXX | Edits applied + log | tuỳ batch |

**Tổng**: ~20–40K cho 1 màn trung bình; ~40–70K cho 1 màn phức tạp; ~80–150K cho luồng 3–5 màn.

---

## 3. Ma trận F1–F5 (Figma MCP — cần chạy thực)

| ID | Mô tả | Kết quả | Ghi chú |
|----|--------|---------|---------|
| **F1** | `whoami` Figma MCP | **PASS** | Xác thực thành công khi token đủ quyền. |
| **F2** | Màn "vàng" (lỗi cố ý) — chạy P0–P3 | **SKIP** | Cần URL + file test cố định do team cung cấp. |
| **F3** | Màn "sạch" — chạy P0–P3, kỳ vọng READY | **SKIP** | Cùng lý do. |
| **F4** | Brief mâu thuẫn — kiểm cơ chế hỏi 3 câu | **SKIP** | Cần chạy agent trong session chat với prompt cụ thể. |
| **F5** | Xuất `bao-cao.md` + `bao-cao.html` tại `~/Downloads/` | **SKIP** | Cần chạy full workflow P0–P3 với quyền ghi file. |

**Khuyến nghị:** Chuẩn bị 2 file Figma (vàng/sạch), lưu URL trong wiki nội bộ, lặp lại F2–F5 mỗi khi đổi phiên bản skill.

---

## 4. Rubric khả năng hoạt động (0–5)

| Tiêu chí | Điểm | Nhận xét |
|----------|------|----------|
| **Đúng fact từ Figma** | 4/5 | Sau khi có 10 scanner + metadata-stat-counter, độ chính xác `measured` cải thiện đáng kể. Vẫn phụ thuộc MCP API expose đủ field. |
| **Đúng nguyên tắc** | 4/5 | Heuristics + gate-rules rõ; method labels (`measured`/`inferred`/`out_of_scope`) bắt buộc minh bạch. |
| **Tính hành động** | 4/5 | P3 BẮT BUỘC mỗi finding 🔴/🟡 đủ 5 mục (a–e); ma trận Effort × Impact; checklist A-XXX cho COOK NOW. |
| **Trung thực uncertainty** | 4/5 | Method labels + confidence ±10–15% khi inferred ratio ≥40%; contrast-checker tag `measured (full)` vs `measured (sampled n=N)`. |
| **Nhất quán nội bộ** | 4/5 | Hai brain file đã đồng bộ scanner integration + P3 validation; ngưỡng pass nhất quán giữa 5 file. |

**Trung bình ~4.0/5** — agent mạnh về **khung phased + scanner integration**; còn rủi ro khi MCP version không expose đủ field (boundVariables, layoutMode chi tiết).

---

## 5. Ưu điểm

- Workflow phased P0–P4 rõ ràng, mỗi phase có exit criteria.
- 10 scanner cover hết 11 Hard Gate (H1–H11) với method `measured` hoặc `inferred` minh bạch.
- P3 Validation Checklist bắt buộc → giảm risk xuất báo cáo thiếu mục.
- Method labels (`measured`/`inferred`/`out_of_scope`) chống "trông giống số liệu máy".
- Evidence Capture Rules: 100% finding 🔴/🟡 phải có ảnh + nodeId.
- Token budget quantify per scope; scratchpad pattern bắt buộc.

## 6. Nhược điểm / rủi ro

- Hard Gate H3 (Primary CTA) phụ thuộc nhận diện → agent có thể tag `inferred` thay vì `measured` nếu thiếu naming convention.
- UX Emotion / Peak-End trong template là suy diễn — đã tag optional + disclaimer trong report-template.md.
- "Above fold" lệch theo thiết bị; chỉ đo trên 1 viewport size mặc định.
- Ghi `~/Downloads/` phụ thuộc môi trường agent (sandbox).

## 7. Việc còn lại cho team

1. Chạy **F2–F5** với file Figma chuẩn hóa (1 vàng + 1 sạch).
2. Định kỳ **đồng bộ** skill local với `git pull` / chạy `install.sh`.
3. (Tuỳ chọn) Build plugin Figma đo contrast/tap target real-time để giảm phụ thuộc suy luận.
4. Định kỳ review `scripts/` khi Figma MCP nâng version (có field mới → có thể đo thêm).
