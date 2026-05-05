# Heuristic Evaluation — Bộ tiêu chuẩn kết hợp

Bộ tiêu chuẩn kết hợp 3 nguồn: **Apple HIG**, **Material Design**, **Nielsen's 10 Usability Heuristics**. Tổ chức theo 8 nhóm đánh giá. Mỗi nhóm gồm mô tả, tiêu chí cụ thể, và ví dụ pass/fail.

---

## 1. Visibility & Feedback

**Nguồn**: Nielsen #1 (Visibility of system status) + Material feedback patterns + HIG feedback guidelines.

Hệ thống phải luôn thông báo cho user biết đang xảy ra gì thông qua feedback phù hợp và kịp thời.

### Tiêu chí

- [ ] Mọi action của user đều có visual feedback rõ ràng (click, tap, submit).
- [ ] Loading states được thiết kế cho mọi async operation (skeleton, spinner, progress bar).
- [ ] Success/error states hiển thị rõ ràng sau mỗi operation.
- [ ] Progress indicators cho multi-step process (step indicator, progress bar).
- [ ] Empty states có nội dung hướng dẫn, không để blank.
- [ ] System status hiển thị ở vị trí dễ nhận biết (toast, banner, inline message).

### Pass

- Form submit có loading spinner → success toast → redirect.
- Upload file hiển thị progress bar với phần trăm.

### Fail

- Nút "Save" không có feedback sau khi click.
- Trang danh sách không có empty state khi không có dữ liệu.
- Không có loading indicator khi chuyển trang.

---

## 2. Consistency & Standards

**Nguồn**: Nielsen #4 (Consistency and standards) + HIG platform conventions + Material theming.

Design phải tuân theo platform conventions và nội bộ nhất quán. User không cần đoán xem các từ, tình huống, hoặc action khác nhau có nghĩa giống nhau không.

### Tiêu chí

- [ ] Terminology nhất quán xuyên suốt (cùng action = cùng label).
- [ ] Cùng loại component dùng cùng visual treatment (button styles, card styles).
- [ ] Icon usage nhất quán (cùng concept = cùng icon).
- [ ] Platform conventions được tôn trọng (HIG cho iOS, Material cho Android/Web).
- [ ] Color semantic nhất quán (red = error, green = success xuyên suốt).
- [ ] Spacing scale nhất quán (4px/8px grid).
- [ ] Action placement nhất quán (primary action luôn cùng vị trí).

### Pass

- Tất cả destructive actions dùng red button, cùng position (right-aligned).
- Navigation pattern giống nhau trên mọi screen.

### Fail

- "Delete" ở screen A, "Remove" ở screen B cho cùng action.
- Primary button màu blue ở screen A, green ở screen B.
- Back button ở top-left một screen, bottom-left screen khác.

---

## 3. Navigation & Information Architecture

**Nguồn**: HIG navigation patterns + Material nav components + Nielsen #6 (Recognition rather than recall).

User phải dễ dàng biết mình đang ở đâu, có thể đi đâu, và quay lại được. Giảm tải trí nhớ bằng cách hiển thị options, actions, và information.

### Tiêu chí

- [ ] Breadcrumb hoặc navigation indicator cho biết vị trí hiện tại.
- [ ] Back/close action luôn accessible.
- [ ] Menu structure không quá 3 level sâu.
- [ ] Tab bar / bottom nav có max 5 items (mobile).
- [ ] Search available cho danh sách > 10 items.
- [ ] Related actions grouped logically.
- [ ] Không có dead-end (mọi screen đều có path tiếp theo hoặc quay lại).
- [ ] Deep-link friendly (mỗi state quan trọng có thể truy cập trực tiếp).

### Pass

- Dashboard có breadcrumb: Home > Reports > Q4 Summary.
- Bottom nav highlight active tab, 4 items.

### Fail

- Modal mở modal mở modal (3+ layers).
- Settings screen không có back button.
- Danh sách 50 items không có search/filter.

---

## 4. Typography & Readability

**Nguồn**: HIG type system + Material type scale.

Typography phải tạo hierarchy rõ ràng, dễ đọc, và nhất quán với type scale.

### Tiêu chí

- [ ] Type scale có hierarchy rõ ràng (H1 > H2 > H3 > body > caption).
- [ ] Body text size tối thiểu 14px (mobile), 16px (web).
- [ ] Line-height đạt 1.4–1.6 cho body text.
- [ ] Max line width 60–80 characters cho readability.
- [ ] Font weight tạo contrast đủ giữa heading và body.
- [ ] Text color đạt WCAG AA contrast ratio (4.5:1 cho normal, 3:1 cho large).
- [ ] Không quá 2–3 font families.
- [ ] Text alignment nhất quán (LTR: left-aligned cho body).
- [ ] Label text rõ ràng, ngắn gọn, actionable.

### Pass

- Type scale: H1=32, H2=24, H3=20, body=16, caption=12.
- Body text #333 trên nền #FFF → ratio 12.6:1.

### Fail

- Heading và body cùng size, chỉ khác bold.
- Body text 12px trên mobile.
- Paragraph width > 100 characters.

---

## 5. Layout & Spacing

**Nguồn**: HIG layout guides + Material grid/spacing.

Layout phải có cấu trúc rõ ràng với spacing system nhất quán, tạo visual rhythm và grouping logic.

### Tiêu chí

- [ ] Grid system rõ ràng (column grid cho web, margin/gutter cho mobile).
- [ ] Spacing dùng consistent scale (4px base: 4, 8, 12, 16, 24, 32, 48).
- [ ] Content grouping rõ ràng (related items gần nhau, khác group cách xa hơn).
- [ ] Touch targets tối thiểu 44×44pt (HIG) hoặc 48×48dp (Material).
- [ ] Padding nhất quán trong cùng loại container.
- [ ] Alignment chính xác (left edge, center, hoặc baseline alignment).
- [ ] Responsive behavior được định nghĩa (breakpoints, reflow strategy).
- [ ] Safe areas respected (notch, home indicator, status bar).

### Pass

- Card component: padding 16px, gap giữa elements 8px, margin between cards 12px.
- Button height 48dp, full-width trên mobile.

### Fail

- Spacing random: 13px ở đây, 17px ở kia, 22px chỗ khác.
- Touch target 30×30 cho icon button.
- Content tràn qua safe area trên iPhone notch.

---

## 6. Color & Contrast

**Nguồn**: HIG color guidelines + Material color system + WCAG contrast.

Color phải có semantic meaning rõ ràng, đạt contrast đủ cho accessibility, và hỗ trợ multi-mode (Light/Dark).

### Tiêu chí

- [ ] Primary, secondary, error, warning, success colors được định nghĩa rõ.
- [ ] Text-on-background đạt WCAG AA (4.5:1 normal text, 3:1 large text).
- [ ] Interactive elements đạt 3:1 contrast với surrounding.
- [ ] Không dùng chỉ color để convey information (thêm icon, text, hoặc pattern).
- [ ] Color palette hỗ trợ Dark mode (nếu applicable).
- [ ] Disabled states có visual distinction rõ ràng nhưng vẫn legible.
- [ ] Focus indicators visible (outline, ring) cho keyboard navigation.
- [ ] Không quá 5–7 distinct colors trong palette chính.

### Pass

- Error text #D32F2F trên #FFF → 6.8:1 + icon prefix.
- Disabled button: opacity 0.38 + cursor not-allowed.

### Fail

- Light gray text (#CCC) trên white background (#FFF) → ratio 1.6:1.
- Status chỉ dùng color dot (xanh/đỏ) không có label.
- Không có Dark mode consideration khi product yêu cầu.

---

## 7. Interactive States

**Nguồn**: HIG control states + Material state layer.

Mọi interactive element phải có đầy đủ visual states để user biết element đang ở trạng thái gì và có thể tương tác không.

### Tiêu chí

- [ ] **Default**: Trạng thái bình thường, rõ ràng là interactive.
- [ ] **Hover**: Visual change khi mouse hover (web) — color shift, elevation, underline.
- [ ] **Pressed/Active**: Feedback tức thì khi tap/click — scale, color darken, ripple.
- [ ] **Focused**: Focus ring/outline cho keyboard navigation — visible, consistent.
- [ ] **Disabled**: Visually muted nhưng vẫn legible — giải thích tại sao disabled nếu có thể.
- [ ] **Loading**: Spinner hoặc skeleton khi element đang process.
- [ ] **Error**: Visual indication khi input invalid — color + icon + message.
- [ ] **Selected/Active**: Rõ ràng element nào đang được chọn.

### Pass

- Button: default (blue) → hover (darker blue) → pressed (darkest + scale 0.98) → disabled (gray, 0.38 opacity).
- Input: default (border gray) → focused (border blue + ring) → error (border red + error icon + message).

### Fail

- Button chỉ có 1 state (default), không có hover/pressed/disabled.
- Text link không có underline hoặc color distinction.
- Dropdown selected item trông giống unselected.

---

## 8. Error Prevention & Recovery

**Nguồn**: Nielsen #5 (Error prevention) + Nielsen #9 (Help users recognize, diagnose, and recover) + Material error handling.

Design phải ngăn lỗi trước khi xảy ra. Khi lỗi xảy ra, phải giúp user nhận biết, hiểu, và khắc phục dễ dàng.

### Tiêu chí

- [ ] Destructive actions có confirmation dialog.
- [ ] Form validation hiển thị inline, real-time (không chỉ khi submit).
- [ ] Error messages cụ thể, nói rõ vấn đề và cách fix (không chỉ "Error occurred").
- [ ] Undo available cho các action reversible.
- [ ] Input constraints hiển thị trước khi user gặp lỗi (max length, format hint).
- [ ] Auto-save hoặc draft cho long-form input.
- [ ] Graceful degradation khi mất kết nối / timeout.
- [ ] Required fields được đánh dấu rõ trước khi user bắt đầu nhập.

### Pass

- Delete item: "Bạn có chắc muốn xóa 'Báo cáo Q4'? Hành động này không thể hoàn tác." [Hủy] [Xóa]
- Email input: hint "example@domain.com", inline error "Email không hợp lệ, vui lòng kiểm tra lại".

### Fail

- Delete không có confirmation.
- Error message: "Something went wrong" không có hướng dẫn.
- Required field không đánh dấu *, user chỉ biết khi submit thất bại.
