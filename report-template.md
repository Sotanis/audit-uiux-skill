# Template Báo cáo Audit UI/UX

Sử dụng template dưới đây khi tạo báo cáo ở Bước 12. Viết bằng tiếng Việt. Chỉ giữ nguyên tiếng Anh với thuật ngữ chuyên dụng (xem Bảng thuật ngữ cuối template). Thay thế tất cả `[placeholder]` bằng nội dung thực tế.

---

## Template

```markdown
# Báo cáo Audit UI/UX — [Tên màn hình / luồng]

## ⚡ Gate Decision (Bàn giao được hay chưa)

```
═══════════════════════════════════════════════
HAND-OFF DECISION: [READY / READY WITH NOTES / NEEDS REWORK / BLOCKED]
═══════════════════════════════════════════════

📊 Score 4 trục (cần MIN ≥ 80%):
  UI         [bar]  [x]% [Mức]   ([pass]/11 active, M:[n]/I:[n])
  UX         [bar]  [x]% [Mức]   ([pass]/9 active, toàn inferred ±15%)
  Nghiệp vụ  [bar]  [x]% [Mức]   ([pass]/10 active, toàn inferred ±15%)
  Use-case   [bar]  [x]% [Mức]   ([pass]/8 active, M:[n]/I:[n])
  ─────────────────────────────────
  MIN        [x]% — [đạt / chưa đạt] ngưỡng 80%

🎯 Độ tin cậy: [n] measured / [n] inferred / 4 out_of_scope
   ⚠️ [Trục nào đó] có ≥40% items inferred — score ±10–15%

🚦 3 tầng gate:
  Tầng 1 Hard Gate:  [✅ PASS / ❌ FAIL — lý do]
  Tầng 2 Score Gate: [✅ PASS / ❌ FAIL — trục yếu]
  Tầng 3 Severity:   [P0: n / P1: n / P2: n]

⚠️ Hành động bắt buộc trước bàn giao:
  1. [Hành động cụ thể, tham chiếu F-XXX]
  2. ...

📈 Khoảng cách đến READY:
  - [Trục yếu] cần +[x] điểm ([n] item nữa)
  - Đóng [n] P0 + đóng ít nhất [n] P1

📋 Khuyến nghị test sau bàn giao (out_of_scope, không gate):
  - UI-12 zoom 200% (browser test)
  - UX-01 first-glance test (5 user, UsabilityHub/Maze)
  - UX-03 hierarchy attention (Hotjar heatmap)
  - UX-04 feedback timing (Lighthouse trên build)
═══════════════════════════════════════════════
```

> **M** = measured (đo chính xác từ Figma MCP) | **I** = inferred (agent judgment, ±10–15%)

> Tham chiếu công thức: [gate-rules.md](gate-rules.md)

---

## Giới hạn định lượng và phương pháp

Báo cáo này được tạo bởi agent AI đọc Figma qua MCP — **không thay thế** kiểm thử WCAG trên bản build, không có usability test người thật, không có analytics hành vi.

| Nội dung | Giới hạn |
|----------|-----------|
| **Hard Gate H1–H11 (% đạt, danh sách node)** | Chỉ tin cậy tuyệt đối khi đã đếm bằng script/`use_figma` có hệ thống. Nếu ghi `[ước lượng]` / `[inferred]` → là **suy luận**, cần xác minh bằng plugin/công cụ chuyên dụng trước khi kết luận pháp lý hoặc compliance. |
| **Score 4 trục** | Nhiều item trong [gate-rules.md](gate-rules.md) có method `inferred` — mang sai số ±10–15% theo tài liệu gate. |
| **Emotion / Peak-End / JTBD** | Suy diễn từ thiết kế tĩnh và brief; không phải kết quả nghiên cứu người dùng. |
| **Tần suất × Impact** | Tần suất thường là **giả định** nếu không có dữ liệu sản phẩm trong prompt. |

---

## Tổng quan

| Mục | Chi tiết |
|-----|----------|
| **Đường dẫn Figma** | [URL đầy đủ] |
| **Ngày đánh giá** | [YYYY-MM-DD] |
| **Phạm vi** | [Toàn trang / Luồng / Thành phần] |
| **Quyết định** | [READY / READY WITH NOTES / NEEDS REWORK / BLOCKED] |

### Phân bổ điểm 4 trục

| Trục | Điểm | Mức | Item pass / Tổng active | Method (M/I) | Ghi chú |
|------|------|-----|-------------------------|--------------|---------|
| UI (Craft) | [x]% | [Xuất sắc / Tốt / Trung bình / Yếu] | [pass]/11 | [n]/[n] | UI-12 zoom 200% → §Khuyến nghị test |
| UX (Usability) | [x]% | [...] | [pass]/9 | 0/9 | Toàn inferred ±15%; UX-01/03/04 → §Khuyến nghị test |
| Nghiệp vụ (Business Logic) | [x]% | [...] | [pass]/10 | 0/10 | Toàn inferred ±15% |
| Use-case (JTBD Coverage) | [x]% | [...] | [pass]/8 | 1/7 | UC-02 measured |

> **M** = measured (đo chính xác từ Figma data) | **I** = inferred (agent judgment, có sai số ±10–15%)

### Ảnh tổng quan

![Tổng quan màn hình](screenshot-overview.png)

### Kết luận tổng quan

[1–2 câu tóm tắt: sẵn sàng / cần sửa nhỏ / cần rework, kèm 1 quan sát chiến lược]

---

## Bối cảnh công việc người dùng (JTBD)

### Công việc chính

[Mô tả công việc cốt lõi mà người dùng cần hoàn thành trên màn hình/luồng này. VD: "Tìm bác sĩ phù hợp và đặt lịch hẹn khám bệnh"]

### Chân dung người dùng

[Mô tả ngắn. VD: "Bệnh nhân 25-45 tuổi, sử dụng ứng dụng di động để đặt lịch khám"]

### Bản đồ công việc

| Bước | Mô tả cụ thể | Câu chuyện người dùng | Giả thuyết thiết kế |
|------|---------------|----------------------|---------------------|
| [Tên bước] | [Người dùng làm gì ở bước này] | Là một [chân dung], tôi muốn [hành động] để [kết quả mong muốn] | Chúng tôi tin rằng [quyết định thiết kế] sẽ giúp [chân dung] đạt được [kết quả] vì [lý do] |
| ... | ... | ... | ... |

---

## Tóm tắt phát hiện

| Mức độ | Số lượng | Tóm tắt |
|--------|----------|---------|
| **P0 (Nghiêm trọng)** | [n] | [Liệt kê ngắn gọn] |
| **P1 (Quan trọng)** | [n] | [Liệt kê ngắn gọn] |
| **P2 (Nhỏ)** | [n] | [Liệt kê ngắn gọn] |

**Tổng cộng**: [N] phát hiện

---

## Chi tiết phát hiện

### [F-001] — [Tên phát hiện ngắn gọn]

**Thông tin cơ bản**

| Mục | Chi tiết |
|-----|----------|
| **Mức độ** | P0 / P1 / P2 |
| **Hạng mục** | [Phản hồi hiển thị / Nhất quán / Điều hướng / Chữ / Bố cục / Màu sắc / Trạng thái / Ngăn lỗi / UX Writing / UX Flow / UX Emotion] |
| **Bước công việc bị ảnh hưởng** | [Xác định / Tìm kiếm / Chuẩn bị / Xác nhận / Thực hiện / Theo dõi / Xử lý] |
| **Tần suất × Tác động** | [Cao/Trung bình/Thấp] × [Cao/Trung bình/Thấp] |

**Bằng chứng**

- **Ảnh chụp vùng có vấn đề** (chụp sát node chứa lỗi qua `get_screenshot(fileKey, nodeId)`, không phải toàn màn hình):

<table>
<tr>
<td width="50%">

**Vùng có vấn đề**

![F-001 — vùng lỗi](screenshot-F-001.png)

</td>
<td width="50%">

**Ngữ cảnh xung quanh** *(tùy chọn — khi vùng lỗi nhỏ, cần ảnh parent để hiểu vị trí)*

![F-001 — ngữ cảnh](screenshot-F-001-context.png)

</td>
</tr>
</table>

- **Node ID**: `[123:456]` *(ID Figma thật để traceback, không chỉ tên)*
- **Vị trí (layer path)**: `Page > Frame > Section > [tên node]`
- **Mong đợi**: [Mô tả trạng thái thiết kế nên có]
- **Thực tế**: [Mô tả trạng thái thiết kế hiện tại — số đo cụ thể: contrast 2.1:1, size 32×32, spacing 13px...]

**Câu chuyện người dùng liên quan**

> Là một [chân dung], tôi muốn [hành động] để [kết quả mong muốn].

**Giả thuyết thiết kế tham chiếu**

> Chúng tôi tin rằng [quyết định thiết kế] sẽ giúp [chân dung] đạt được [kết quả] vì [lý do].
>
> **Đánh giá**: [Thiết kế hiện tại đáp ứng / không đáp ứng giả thuyết này vì ...]

**Phân tích tác động hành vi**

- **Hành vi bị ảnh hưởng**: [Mô tả cụ thể hành vi sử dụng bị thay đổi/cản trở. VD: "Người dùng phải cuộn dài để tìm nút gửi, tăng gánh nặng nhận thức và nguy cơ bỏ dở"]
- **Tác động đến câu chuyện người dùng**: [Câu chuyện nào bị ảnh hưởng? Người dùng không thể hoàn thành hành động gì? VD: "Không thể hoàn thành 'xác nhận đặt lịch' vì nút hành động chính bị ẩn dưới màn hình"]
- **Tác động đến kết quả**: [Tốc độ / Chính xác / Hài lòng bị ảnh hưởng ra sao? VD: "Tốc độ giảm — thêm ~3 lần cuộn; Hài lòng giảm — cảm giác 'lạc' khi nút hành động không hiển thị"]

**Đề xuất khắc phục**

[Đề xuất cụ thể, liên kết với việc khôi phục kết quả cho người dùng. VD: "Đưa nút hành động lên trên màn hình hoặc dùng thanh cố định ở dưới → khôi phục tốc độ (bớt cuộn) + hài lòng (nút luôn hiển thị)"]

---

*(Lặp lại khối [F-XXX] cho mỗi phát hiện, sắp xếp P0 → P1 → P2)*

---

## Phân tích UX Writing

### Tổng quan chất lượng nội dung

| Hạng mục | Đánh giá | Ghi chú |
|----------|----------|---------|
| Microcopy & Labels | [Tốt / Trung bình / Yếu] | [Ghi chú ngắn] |
| Error Messages | [Tốt / Trung bình / Yếu] | [Ghi chú ngắn] |
| Tone of Voice | [Nhất quán / Không nhất quán] | [Ghi chú ngắn] |
| Empty State Copy | [Có / Thiếu / Không áp dụng] | [Ghi chú ngắn] |
| CTA Clarity | [Tốt / Trung bình / Yếu] | [Ghi chú ngắn] |

*(Chi tiết từng vấn đề nằm trong phần Chi tiết phát hiện, gắn mã F-XXX)*

---

## Phân tích UX Flow

### Tổng quan luồng

| Mục | Chi tiết |
|-----|----------|
| **Số bước hoàn thành job chính** | [n bước] |
| **Số điểm rẽ nhánh** | [n điểm] |
| **Dead-end phát hiện** | [Có / Không — mô tả ngắn] |
| **Escape hatch** | [Có đủ / Thiếu ở bước...] |
| **Lưu tiến trình** | [Có / Không] |

*(Chi tiết từng vấn đề nằm trong phần Chi tiết phát hiện, gắn mã F-XXX)*

---

## Bản đồ cảm xúc người dùng (UX Emotion)

### Ánh xạ cảm xúc theo bước

| Bước | Cảm xúc mong đợi | Cảm xúc từ thiết kế | Chênh lệch | Ghi chú |
|------|-------------------|---------------------|------------|---------|
| [Bước] | [Tin tưởng / An tâm / Vui / ...] | [Bối rối / Lo lắng / ...] | [Tích cực / Tiêu cực / Phù hợp] | [Nguyên nhân ngắn] |
| ... | ... | ... | ... | ... |

### Điểm đỉnh & điểm đáy

- **Điểm đỉnh (Peak)**: [Bước nào tạo trải nghiệm tích cực nhất — mô tả ngắn]
- **Điểm đáy (Valley)**: [Bước nào gây cảm xúc tiêu cực nhất — mô tả ngắn]
- **Bước cuối (End)**: [Cảm xúc ở bước cuối — ảnh hưởng đến ấn tượng tổng thể]

*(Chi tiết từng vấn đề nằm trong phần Chi tiết phát hiện, gắn mã F-XXX)*

---

## Tổng hợp tác động theo bước công việc

Bảng tổng hợp tác động của tất cả phát hiện lên từng bước công việc:

| Bước công việc | Phát hiện liên quan | Kết quả bị ảnh hưởng | Mức ảnh hưởng |
|----------------|--------------------|-----------------------|---------------|
| [Bước] | [F-001, F-003] | [Tốc độ / Chính xác / Hài lòng] | [Cao / Trung bình / Thấp] |
| ... | ... | ... | ... |

---

## Khuyến nghị trước khi bàn giao

### Phải sửa trước khi bàn giao (P0)

1. [Mô tả hành động cụ thể — tham chiếu F-XXX]
2. ...

### Nên sửa trước khi bàn giao (P1)

1. [Mô tả hành động cụ thể — tham chiếu F-XXX]
2. ...

### Cải thiện sau khi bàn giao (P2)

1. [Mô tả hành động cụ thể — tham chiếu F-XXX]
2. ...

### Ghi chú cho lập trình viên

[Thông tin bổ sung cần biết khi triển khai: các trường hợp đặc biệt, trạng thái cần xử lý, cách ứng xử trên nhiều kích thước màn hình, thông số hiệu ứng chuyển động, v.v.]

---

## Khuyến nghị test sau bàn giao (items `out_of_scope`)

Các check dưới đây **không đo được trên design tĩnh** — agent không tính vào gate %, nhưng QA / designer cần lập kế hoạch test sau khi dev triển khai để đảm bảo trải nghiệm hoàn chỉnh.

| ID | Item | Cách test | Công cụ gợi ý |
|----|------|-----------|---------------|
| UI-12 | Zoom 200% — text vẫn đọc được, không cắt nội dung (WCAG 1.4.4) | Mở build trên trình duyệt, zoom 200%, scan từng vùng text | Browser zoom, WAVE |
| UX-01 | First-glance test (5 giây) | Cho 5 user xem màn 5 giây rồi hỏi: "Màn này để làm gì? CTA chính? Thông tin chính? Cách thoát?" — đếm câu đúng | UsabilityHub, Maze |
| UX-03 | Hierarchy attention map | Heatmap eye-tracking hoặc click-test — primary CTA cần nằm top-3 attention | Hotjar, Attention Insight |
| UX-04 | Feedback timing | Đo trên build với DevTools — <1s instant / <3s loading / >3s progress | Lighthouse, WebPageTest |

**Trách nhiệm**: QA hoặc UX researcher chạy các test này sau khi build có sẵn. Kết quả không ảnh hưởng quyết định bàn giao Figma → dev, nhưng ảnh hưởng quyết định **release sản phẩm**.

---

## Checklist áp dụng (COOK NOW) — dùng khi muốn agent sửa trực tiếp trên Figma

> Mục này chỉ thêm khi người đọc muốn chuyển từ “đề xuất” sang “thực thi”. Mỗi mục có mã `A-XXX` để người dùng chọn và xác nhận **COOK NOW**.

| Mã | Ưu tiên | Tham chiếu | Việc cần làm | Cách sửa trên Figma (tóm tắt) | Loại | Rủi ro |
|----|---------|------------|--------------|-------------------------------|------|--------|
| A-001 | P0 | F-001 | [Tên hành động] | [Node/section nào, đổi gì: autolayout/padding/text style/constraints/swap component/bind variables…] | auto / needs_decision / manual | [Thấp/Trung/Cao + lý do] |
| A-002 | P1 | F-003 | ... | ... | ... | ... |

### Hướng dẫn chọn mục để COOK NOW

- **Chọn nhanh**: “COOK NOW tất cả P0” hoặc “COOK NOW các mã: A-001, A-004, A-007”.
- Nếu mục là `needs_decision`, hãy ghi rõ lựa chọn (VD: “sticky bottom bar” hoặc “đưa CTA lên trên fold”).

### Báo cáo kết quả sau COOK NOW (agent tự điền)

- **Backup đã tạo**: `Backup - Before COOK NOW - <timestamp>` (kèm ID nếu có)
- **Đã áp dụng**: A-...
- **Bị chặn / cần quyết định**: A-... (lý do)
- **Ảnh sau chỉnh sửa**: [đính kèm]

---

## Bảng thuật ngữ

| Thuật ngữ | Giải nghĩa |
|-----------|------------|
| **JTBD (Jobs to Be Done)** | Khung phân tích tập trung vào công việc mà người dùng cần hoàn thành, thay vì tập trung vào tính năng sản phẩm |
| **Heuristic** | Nguyên tắc đánh giá khả năng sử dụng dựa trên kinh nghiệm và tiêu chuẩn đã được kiểm chứng |
| **Hand-off** | Quá trình bàn giao thiết kế từ nhà thiết kế sang lập trình viên để triển khai |
| **Persona** | Chân dung đại diện cho nhóm người dùng mục tiêu, bao gồm đặc điểm, nhu cầu và hành vi |
| **User-Story** | Câu chuyện người dùng — mô tả ngắn gọn một nhu cầu từ góc nhìn người dùng theo mẫu: "Là một [ai], tôi muốn [làm gì] để [đạt kết quả gì]" |
| **Hypothesis** | Giả thuyết thiết kế — dự đoán về cách một quyết định thiết kế sẽ giúp người dùng đạt kết quả mong muốn |
| **CTA (Call to Action)** | Nút hành động chính — thành phần giao diện kêu gọi người dùng thực hiện hành động quan trọng nhất trên màn hình |
| **Outcome** | Kết quả mong muốn — điều người dùng đạt được sau khi hoàn thành công việc |
| **Cognitive load** | Gánh nặng nhận thức — mức độ nỗ lực tư duy mà người dùng phải bỏ ra khi sử dụng giao diện |
| **Friction** | Điểm cản trở — bất kỳ yếu tố nào làm chậm hoặc ngăn người dùng hoàn thành công việc |
| **Auto-layout** | Bố cục tự động — tính năng trong Figma giúp các thành phần tự sắp xếp khi nội dung thay đổi |
| **Token** | Biến thiết kế — giá trị được đặt tên (màu sắc, khoảng cách, cỡ chữ) dùng nhất quán trong hệ thống thiết kế |
| **Component** | Thành phần — khối giao diện tái sử dụng được (nút bấm, ô nhập, thẻ thông tin, v.v.) |
| **Design system** | Hệ thống thiết kế — bộ quy tắc, thành phần, và biến thiết kế dùng chung để đảm bảo nhất quán |
| **Detached style** | Kiểu dáng tách rời — giá trị trực tiếp (mã màu, cỡ chữ cụ thể) thay vì dùng biến thiết kế từ hệ thống |
| **Touch target** | Vùng chạm — kích thước tối thiểu của vùng có thể nhấn/chạm trên màn hình (khuyến nghị ≥ 44×44pt hoặc 48×48dp) |
| **WCAG** | Tiêu chuẩn quốc tế về khả năng tiếp cận nội dung web, bao gồm yêu cầu về độ tương phản màu sắc, cỡ chữ, điều hướng bàn phím |
| **Fold** | Đường gấp màn hình — ranh giới nội dung hiển thị được mà không cần cuộn |
| **Empty state** | Trạng thái trống — giao diện hiển thị khi chưa có dữ liệu (danh sách trống, kết quả tìm kiếm bằng 0) |
| **Loading state** | Trạng thái đang tải — giao diện hiển thị khi hệ thống đang xử lý (vòng quay, khung xương, thanh tiến trình) |
| **Skeleton** | Khung xương — bản phác thảo mờ của bố cục, hiển thị trong khi nội dung đang tải |
| **Breakpoint** | Điểm chuyển bố cục — ngưỡng kích thước màn hình tại đó giao diện thay đổi cách sắp xếp |
| **HIG (Human Interface Guidelines)** | Hướng dẫn giao diện của Apple cho các nền tảng iOS, macOS, watchOS |
| **Material Design** | Hệ thống thiết kế của Google, cung cấp nguyên tắc và thành phần chuẩn cho Android và Web |
| **UX Writing** | Viết nội dung cho trải nghiệm người dùng — bao gồm microcopy, label, thông báo lỗi, hướng dẫn trên giao diện |
| **Microcopy** | Đoạn chữ ngắn trên giao diện hướng dẫn hoặc phản hồi người dùng (label nút, placeholder, tooltip, thông báo) |
| **Tone of Voice** | Giọng văn — phong cách ngôn ngữ nhất quán thể hiện tính cách sản phẩm (thân thiện, trang trọng, trung tính) |
| **Drop-off** | Điểm bỏ dở — nơi người dùng rời khỏi luồng trước khi hoàn thành công việc |
| **Dead-end** | Đường cụt — trạng thái mà người dùng không có hành động tiếp theo rõ ràng |
| **Escape Hatch** | Lối thoát — cách để người dùng rời khỏi luồng hiện tại (nút hủy, quay lại, đóng) |
| **Peak-End Rule** | Quy tắc tâm lý: người dùng đánh giá trải nghiệm dựa chủ yếu vào điểm đỉnh cảm xúc và bước cuối cùng |
| **Trust Signal** | Dấu hiệu tin cậy — yếu tố giao diện tạo cảm giác an toàn (biểu tượng bảo mật, chính sách, đánh giá) |
| **Emotion Map** | Bản đồ cảm xúc — ánh xạ cảm xúc người dùng qua từng bước trong luồng sử dụng |
```

---

## Hướng dẫn sử dụng template

### Quy tắc ngôn ngữ

1. **Tiếng Việt là chủ đạo**: Toàn bộ báo cáo viết bằng tiếng Việt.
2. **Thuật ngữ chuyên dụng giữ nguyên tiếng Anh**: Chỉ giữ tiếng Anh với các thuật ngữ kỹ thuật không có từ tiếng Việt phổ biến tương đương (VD: auto-layout, token, component, CTA, WCAG). Khi thuật ngữ xuất hiện lần đầu trong báo cáo, ghi kèm giải nghĩa tiếng Việt trong ngoặc.
3. **Bảng thuật ngữ bắt buộc**: Mọi báo cáo phải có bảng thuật ngữ ở cuối để người đọc tra cứu.
4. **Ưu tiên từ Việt khi có thể**: "bàn giao" thay vì "hand-off", "bố cục" thay vì "layout", "chân dung người dùng" thay vì "persona", "tốc độ/chính xác/hài lòng" thay vì "speed/accuracy/satisfaction".

### Quy tắc viết nội dung

1. **Bằng chứng**: Mỗi phát hiện phải có ảnh chụp **đúng vùng có vấn đề** (chụp sát node chứa lỗi bằng `get_screenshot` với nodeId của vùng đó, không dùng ảnh toàn màn hình). Ảnh lưu cùng thư mục, đặt tên `screenshot-FXXX.png`. Ảnh tổng quan toàn màn đặt tên `screenshot-overview.png`.
2. **Cụ thể**: Tránh mô tả chung chung. "Nút quá nhỏ" → "Nút 'Gửi' có vùng chạm 32×32dp, nhỏ hơn mức tối thiểu 48×48dp theo Material Design".
3. **Hành động được ngay**: Đề xuất phải cụ thể đến mức lập trình viên có thể hành động ngay.
4. **Liên kết JTBD**: Mỗi phát hiện phải gắn với ít nhất 1 câu chuyện người dùng và 1 chỉ số kết quả.

### Quy tắc chấm điểm

Tham chiếu [checklist.md](checklist.md) cho cách tính điểm chi tiết từng hạng mục.

### Thứ tự viết

1. Hoàn thành phần Bối cảnh công việc trước (công việc, chân dung, bản đồ công việc).
2. Viết phát hiện theo mức độ P0 → P1 → P2.
3. Tạo bảng tổng hợp tác động sau khi liệt kê hết phát hiện.
4. Khuyến nghị viết cuối cùng, ưu tiên theo mức độ.
5. Bảng thuật ngữ đặt cuối báo cáo.
