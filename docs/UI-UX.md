# UI/UX Requirements — Kids Drawing App

**Status:** Initial interaction specification

## 1. UX objectives
Make starting a drawing obvious; keep canvas large; simplify brush/color/size changes; prevent accidental navigation or loss; explain region and free-draw modes; support children who may not read fluently.

## 2. Information architecture
- **Home/Gallery:** browse pages, create blank canvas, resume recent work.
- **Drawing workspace:** canvas, tools, palette, editing actions and completion.
- **Export preview:** preview, save/share and clear permission/error feedback.
- **Settings/Parent area:** optional future area for app preferences and guardian controls.

## 3. Drawing workspace
The supplied Figma reference shows a landscape workspace: central canvas, left navigation/edit controls, right color/tool controls, completion action near upper-right and an extra lower-right control. Extract exact visual tokens and inspect all relevant frames before final UI implementation.

## 4. Primary controls
**Brush picker:** active brush is obvious and labeled; selection affects new strokes only.  
**Palette:** current color is visible; preset colors are easy to tap; selection is indicated by outline/checkmark/shape, not color alone.  
**Brush size:** the left density slider drives stroke width for new strokes (`12 + density * 44` via `DrawingViewModel.setDensity`). Affects subsequent strokes only.  
**Undo/redo:** undo is easy to reach; redo is disabled when unavailable; ordinary undo needs no confirmation.  
**Eraser control (current):** opens a full-screen confirm. YES clears all paint on the page (`clearAll`); NO dismisses. Not a stroke eraser brush yet. A dedicated paint-only eraser tool remains later.  
**Region coloring:** no mode selector and no selection step. The part under the first touch clips the whole stroke. The finger-lift burst is the feedback that a stroke landed.

## 5. Canvas gestures
- Single-pointer drag draws, clipped to the part under the first touch. A first touch on an outline or just beside the art picks the nearest part within a fingertip radius (22 points on screen at any zoom); only blank paper farther away paints nothing.
- Two pointers zoom and pan the page; the second pointer cancels the in-progress stroke without an undo entry.
- No drawing while a navigation gesture is active.
- Pinching back out animates to the fitted page.

## 6. Feedback
Show active tool/color immediately. Provide subtle region-selection feedback. Save/export progress must be non-blocking. Explain denied permissions plainly. Show success only after the platform confirms success. Preserve work on failure.

## 7. Accessibility and child usability
Aim for 44–48 logical-pixel primary targets. Use simple labels/familiar icons, readable contrast, accessible labels and screen-reader semantics. Respect text scaling where practical. Avoid flashing and rapid motion. Make destructive actions reversible or guarded.

## 8. Responsive layouts
Support the orientations selected for release. Preserve canvas proportions. Avoid covering artwork. On narrow screens collapse secondary tools into compact panels while retaining undo/redo. Respect safe areas and system navigation.

## 9. UX acceptance checklist
- [ ] First-time user can start without instructions.
- [ ] Active brush and color are obvious.
- [ ] Brush size is adjustable without obscuring canvas.
- [ ] Undo is easy to find and predictable.
- [ ] A slip outside the part where the stroke started never paints the neighbor.
- [ ] Every finger lift after a painted stroke produces the burst.
- [ ] Selected orientations work on phones and tablets.
- [ ] Save/export success and failure feedback is truthful.
- [ ] Essential controls have accessible labels and adequate targets.

## 10. Decisions required
Confirm target age, supported orientations, default mode, drawing-vs-navigation gesture policy, full Figma tokens/states and whether guardian controls are in the first release.
