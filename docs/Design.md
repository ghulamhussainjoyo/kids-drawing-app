# Design — Kids Drawing App

**Status:** Initial design baseline  
**Figma reference:** `kids-drawing-app`, node `11:154`. Only the referenced drawing screen has been inspected; this is not a complete Figma audit.

## 1. Design intent
A welcoming, child-friendly drawing experience where the canvas is the hero. Controls should be discoverable, forgiving and comfortable with fingers or stylus, while the painting tools remain expressive and high quality.

## 2. Principles
- Canvas first; maximize usable drawing area.
- Immediate visual response to touch.
- Clear selected brush, color and size.
- Large, forgiving controls and prominent undo.
- Accessible states that do not rely on color alone.
- Consistent behavior across iOS and Android.

## 3. Observed drawing workspace
The inspected Figma frame is landscape-oriented and shows:
- Large central white artwork canvas.
- Left-side navigation/editing controls, including undo/redo.
- Right-side color/tool area.
- Completion action near the upper-right.
- Additional drawing control near the lower-right.
- Apple and books artwork, with sample freehand marks around it.

Those sample marks suggest the product may need both region-constrained coloring and free-draw mode. Confirm this against the full design before locking behavior.

## 4. Screen hierarchy
**Drawing:** navigation/completion actions, main canvas, primary tools, color selection, brush size/opacity, secondary actions. Keep the canvas dominant.
**Home/library:** artwork thumbnails, categories, recent work and resume action.
**Export:** preview, save/export actions and clear permission/error feedback.

## 5. Interaction states
Every control defines default, selected, pressed, disabled and (where relevant) loading/error states. Brush/color/size changes apply to subsequent strokes; they must not mutate completed strokes.

## 6. Canvas behavior (confirmed from the reference recording)
- **Region coloring:** there is no selection step. Each stroke is clipped to the closed part under its first touch until the finger lifts. A first touch on an outline or just beside the art picks the nearest part within a fingertip radius, so small parts like the stem and leaf color on the first try. Only a touch on blank paper farther than that paints nothing. The next stroke picks its own part.
- **Apple-and-books page parts:** apple body, leaf, stem, top book cover, top book spine, top book pages, bottom book spine, bottom book pages, bookmark. The apple is in front of the book.
- **Repainting:** later strokes cover earlier paint in the same part.
- **Finger-lift burst:** butterflies, stars, hearts, flowers, dots or snowflakes burst near the stroke and fade in about 1.5 s. They may cross outlines and are not saved.
- **Pan/zoom:** two fingers zoom and pan the page only; tools stay fixed. A second finger cancels the in-progress stroke. Pinching back out animates to the fitted page.
- **Free drawing:** a blank canvas has no parts, so strokes draw anywhere. No mode toggle is needed on coloring pages.

## 7. Child-friendly UX
Use large targets (aim for 44–48 logical pixels or larger for primary controls), simple labels/icons, clear undo, safe exit, short confirmations and readable contrast. Avoid flashing and distracting effects.

## 8. Responsive behavior
Support the agreed portrait/landscape layouts. Preserve artwork aspect ratio. On narrow screens, move secondary controls into a compact panel while keeping undo/redo accessible. Respect safe areas and avoid covering important artwork.

## 9. Visual tokens
Extract exact brand colors, typography, spacing, radii, shadows and icon styles from Figma variables/styles. Do not invent final brand values from one partial screenshot.

## 10. Screen states (confirmed)
- Full-screen landscape, no status bar, system edge gestures deferred.
- Backgrounds run edge to edge. The notch is mid-edge, on the left or right depending on rotation. On the right, the tool column moves inward to clear it. On the left, the corner buttons stay in the corners and only the badge and slider keep clear of it. Buttons and tool tiles never shrink below 48 px, and scrolling lists keep 24 px end padding so their first and last items clear the rounded screen corners. The color rail shares the page cream; only the tool column is lavender.
- Undo and the green done check appear only after the first completed stroke. Redo is grey until an undo. Enabled buttons are purple; disabled are grey.
- The left indicator mirrors the active tool. The selected tool tab and color stick slide out to the left. The color rail scrolls and its sticks match the active tool.

## 11. Open design questions
- Resolved: coloring pages use region coloring; the scribbles in Figma node `11:154` are only a painted example.
- Which controls remain visible in portrait?
- What does the completion action do?
- What age range and accessibility needs should be prioritized?
