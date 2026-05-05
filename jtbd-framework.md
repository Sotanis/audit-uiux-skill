# JTBD Framework — Lens cho UI/UX Audit

Tài liệu tham chiếu cho bước JTBD Analysis (Step 3) trong audit workflow. Mục đích: đặt mọi đánh giá heuristic vào bối cảnh "user đang cố hoàn thành công việc gì" để finding có tính hành động cao hơn.

---

## Job Map Template

Mỗi screen/flow phục vụ một **Job** chính. Phân tách job thành 7 bước chuẩn. Chọn các bước relevant cho screen đang audit.

| # | Job Step | Mô tả | Câu hỏi audit UI/UX |
|---|----------|--------|----------------------|
| 1 | **Define** | User xác định nhu cầu hoặc mục tiêu | UI có giúp user hiểu rõ mình cần làm gì? Có instruction/guidance? |
| 2 | **Locate** | User tìm kiếm thông tin, công cụ, hoặc đối tượng cần thiết | Search, filter, sort có đủ? Information architecture có hỗ trợ tìm kiếm? |
| 3 | **Prepare** | User chuẩn bị input, cấu hình trước khi thực hiện | Form, settings, options có rõ ràng? Defaults có hợp lý? |
| 4 | **Confirm** | User xác nhận lựa chọn trước khi thực hiện | Preview, summary, confirmation step có đầy đủ? |
| 5 | **Execute** | User thực hiện action chính | Primary CTA rõ ràng? Feedback khi thực hiện? Không có blocker? |
| 6 | **Monitor** | User theo dõi kết quả, tiến trình | Progress indicator, status updates, real-time feedback? |
| 7 | **Resolve** | User xử lý kết quả, sửa lỗi, hoặc hoàn tất | Error recovery, undo, next steps rõ ràng? |

### Cách dùng

Không phải screen nào cũng có đủ 7 bước. Ví dụ:
- **Search screen**: chủ yếu Locate + Prepare (filter).
- **Checkout flow**: Prepare + Confirm + Execute + Monitor.
- **Dashboard**: Define (nhận diện tình hình) + Locate (tìm metric cần xem).
- **Settings page**: Locate + Prepare + Execute.
- **Form screen**: Prepare + Confirm + Execute.

---

## User-Story Format

Viết user-story cho mỗi job step relevant. Format:

```
As a [persona],
I want to [action cụ thể trên screen/component này]
so that [desired outcome - kết quả user đạt được, KHÔNG phải mô tả tính năng].
```

### Quy tắc viết outcome

- Outcome phải trả lời: "Vì sao user muốn làm điều này? Kết quả cuối cùng là gì?"
- Outcome KHÔNG phải là mô tả tính năng.

| Sai (mô tả tính năng) | Đúng (desired outcome) |
|------------------------|------------------------|
| ...so that I can see the search results | ...so that I can find the right product quickly without browsing |
| ...so that I can fill in the form | ...so that my order has correct delivery information |
| ...so that I can click the submit button | ...so that my request is processed and I get confirmation |
| ...so that the filter is applied | ...so that I only see items matching my budget and preferences |

### Ví dụ hoàn chỉnh

**Job**: Đặt lịch hẹn khám bệnh

| Job Step | User-Story |
|----------|------------|
| Locate | As a patient, I want to search for available doctors by specialty so that I can find a qualified doctor for my condition without calling the clinic. |
| Prepare | As a patient, I want to select a date and time slot so that the appointment fits my schedule without conflicts. |
| Confirm | As a patient, I want to review appointment details before confirming so that I avoid booking mistakes and unnecessary rescheduling. |
| Execute | As a patient, I want to confirm my booking with one tap so that my appointment is secured immediately. |
| Monitor | As a patient, I want to receive confirmation and reminder so that I don't forget or miss my appointment. |

---

## Hypothesis Format

Hypothesis liên kết design decision cụ thể với outcome mong đợi. Dùng làm baseline để đánh giá design hiện tại.

```
We believe [design decision X]
will help [persona]
achieve [outcome Y]
because [rationale Z].
```

### Ví dụ

| Design Decision | Hypothesis |
|-----------------|------------|
| Calendar picker hiển thị available slots bằng màu xanh | We believe color-coding available slots will help patients select a time faster because visual distinction reduces scanning time. |
| Inline validation trên form | We believe showing inline errors as user types will help patients submit correct information on first attempt because immediate feedback prevents accumulation of mistakes. |
| Bottom sheet cho doctor profile | We believe showing doctor details in a bottom sheet (not new page) will help patients compare doctors faster because they stay in context without navigation overhead. |

### Cách dùng trong audit

Khi phát hiện finding, đối chiếu với hypothesis:
1. Design hiện tại có đáp ứng hypothesis không?
2. Nếu không, hypothesis nào bị vi phạm?
3. Consequence: outcome nào bị ảnh hưởng?

---

## Outcome Metrics

Đánh giá mỗi user-story theo 3 chiều:

### Speed (Tốc độ)

User hoàn thành job step nhanh đến mức nào?

- **Tốt**: Ít bước, ít input, progressive disclosure.
- **Xấu**: Quá nhiều bước, phải quay lại, phải chờ, phải scroll dài.

Câu hỏi audit:
- Số bước tối thiểu để hoàn thành job step là bao nhiêu? Design hiện tại có thêm bước không cần thiết?
- Có element nào gây delay (unnecessary loading, redundant confirmation)?
- Information hierarchy có giúp user scan nhanh không?

### Accuracy (Chính xác)

User hoàn thành đúng không? Có lỗi/undo không?

- **Tốt**: Defaults hợp lý, validation rõ ràng, preview trước khi commit.
- **Xấu**: Dễ nhầm action, thiếu validation, undo khó hoặc không có.

Câu hỏi audit:
- User có thể nhầm lẫn giữa hai actions gần nhau không? (VD: "Save" vs "Save & Close")
- Error prevention đã đủ chưa? (confirmation cho destructive, validation cho input)
- User có thể undo nếu làm sai?

### Satisfaction (Hài lòng)

Trải nghiệm có mượt mà không? Frustration không?

- **Tốt**: Flow liền mạch, feedback kịp thời, aesthetically pleasing.
- **Xấu**: Jarring transitions, missing feedback, inconsistent visual, dead-ends.

Câu hỏi audit:
- Flow có bị gián đoạn ở đâu (redirect, page reload, lost context)?
- Visual polish đã đủ chưa (alignment, spacing, animation)?
- User có bị "bỏ rơi" ở state nào (empty state, error without guidance)?

---

## JTBD-to-UX Mapping Table

Hướng dẫn map job step sang UX concerns cụ thể để audit có trọng tâm.

| Job Step | UX Concerns chính | Heuristic Groups liên quan |
|----------|-------------------|---------------------------|
| **Define** | Onboarding, instruction, value proposition, page title/subtitle | #1 Visibility, #3 Navigation |
| **Locate** | Search, filter, sort, information architecture, list/grid view | #3 Navigation, #5 Layout |
| **Prepare** | Form design, input types, defaults, option presentation, settings | #2 Consistency, #4 Typography, #8 Error Prevention |
| **Confirm** | Summary, preview, review step, edit-before-submit | #1 Visibility, #8 Error Prevention |
| **Execute** | Primary CTA, button placement, loading states, submit flow | #7 Interactive States, #1 Visibility |
| **Monitor** | Progress bar, status updates, notifications, real-time feedback | #1 Visibility, #6 Color (status colors) |
| **Resolve** | Error messages, retry, undo, success state, next-step guidance | #8 Error Prevention, #1 Visibility, #3 Navigation |

### Cách dùng trong audit

1. Xác định các job steps relevant cho screen.
2. Tra bảng trên để biết cần audit UX concerns nào.
3. Khi đánh giá heuristic (Step 5), ưu tiên các heuristic groups liên quan đến job steps chính.
4. Khi ghi nhận finding, tag job step bị ảnh hưởng.
