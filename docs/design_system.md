# Kopa interface foundations

The source brand is `../kopa_brand/Kopa_Brandguideline.pdf`. Preserve its
Rethink Sans typography, mint/green palette, Jord text, and supplied artwork.

## Shared rules

- Off White page canvas, white content surfaces, Jord text. Ordinary cards are
  flat; shadows are reserved for floating navigation and overlays.
- Use `AppTextStyles` or the global `TextTheme`. Page titles are 28, section
  headings 20, body text 16, supporting text 14, and metadata at least 12.
  Display scores can use 32–40. Let text grow with the user's text scale.
- Use 16px page gutters and card padding, 12px item gaps, and 24px section gaps.
- Controls use 12px corners, standard cards 16px, and hero panels/sheets 28px.
  Avatars stay circular and status/filter chips use pill shapes.
- Use `Button` with primary, secondary, tertiary, or destructive roles.
  Primary is mint/Jord; secondary is white/Jord. Loading and disabled actions
  cannot be activated. Buttons wrap long labels and have a 48px minimum height.
  `FullWidthButton` and `ButtonSmall` delegate to the same implementation.
- `KopaCard` owns the standard content surface and tap feedback;
  `HomeBentoCard` delegates to it. Avoid adding local borders and shadows.
- Use semantic foreground/surface pairs from `AppColors` for status text.
  Brand swatches are not interchangeable with readable small-text colors.
- Keep routine statistics neutral; communicate state through labels as well as
  color. Preserve team identity, provider names, and platform navigation behavior.
- Localize new user-facing copy through the paired ARB files.

## Review and verification

`lib/theme/design_system_preview.dart` provides an isolated Flutter widget
preview. `test/goldens/design_system.png` is its reference rendering.
`test/design_system_test.dart` covers long actions at 2x text scale, action
availability, card taps, semantic contrast, and the reference rendering.

Run `flutter analyze`, `flutter test`, and an appropriate platform build after
shared visual changes. Refresh the golden intentionally with
`flutter test --update-goldens test/design_system_test.dart` and inspect it.
Golden changes require the same Flutter/font environment for comparison.
The isolated preview is not verification of full screens on a physical device.
