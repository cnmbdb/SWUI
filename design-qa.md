# SWUI Liquid Glass design QA

## Comparison target

- Source visual truth: `/tmp/codex-remote-attachments/01a0af67-717b-7783-93b3-019e0b30daa5/4846D588-5DFE-469B-BC13-88E92C229268/1-照片-1.jpg`
- Source pixels: 591 x 1280, including Safari chrome. The app-owned region was compared after excluding the browser chrome and normalizing the screenshot to an inferred 393pt mobile viewport.
- Implementation: `https://cnmbdb.github.io/SWUI/?v=469ac1a-mobile`
- Implementation capture: CUA browser screenshot clip at 393 x 670 CSS px, device scale factor 1. The browser capture is retained in the verification session; this browser capability does not expose a filesystem screenshot path.
- State: initial My QR state, with `Close`, `Contact`, and `My QR` visible.

## Full-view comparison evidence

- Implementation card: x 9, y 172.5, width 375, height 325.
- Implementation inner canvas: x 20, y 183.5, width 353, height 303.
- The source and implementation share the same centered, compact panel composition, approximately 1.16:1 panel ratio, neutral gray page field, soft green upper-left glow, blue lower-right glow, and a centered three-control rail.
- No navigation, headings, sections, footer, explanatory copy, or unrelated blocks remain in the implementation.

## Focused action-rail comparison evidence

- Source-normalized control order and proportions: close control, Contact, My QR.
- Implementation control order and dimensions: Close 46 x 44, Contact 101.1 x 44, My QR 90.0 x 44, with 7pt gaps.
- The implementation uses real Phosphor icon assets for the web prototype and SF Symbols in the native SwiftUI layer; no placeholder or handcrafted icon art is used.
- The panel, canvas, and controls use layered translucent fills, bright upper edges, inset lower edges, blur, saturation, and restrained elevation. Computed button filter: `blur(22px) saturate(1.85)`.

## Required fidelity surfaces

- Fonts and typography: system UI font stack, semibold control labels, compact single-line labels matching the source density.
- Spacing and layout: mobile width, panel ratio, inner inset, button height, order, and control gaps were tuned against the normalized source.
- Colors and tokens: cool gray background, frosted white surfaces, soft green/blue ambient light, and semantic green/blue payment accents are preserved.
- Image quality and asset fidelity: the source contains no app-owned raster imagery. Icons use icon-library/SF Symbol assets.
- Copy and content: only `Contact`, `Scan QR`, `My QR`, `Pay`, `Request`, and `Close` are exposed through the state machine.
- States and interactions: verified `My QR -> Pay/Request`, `Pay -> Discover`, and `Scan QR -> My QR` on the deployed page.
- Accessibility: semantic buttons, accessible labels, focus-visible styling, reduced-motion and reduced-transparency handling are present. The live browser console returned no warning or error entries.

## Comparison history

1. Initial pass: P1 visual mismatch. The panel was too wide/tall at the mobile breakpoint, controls were oversized, the default state differed from the source, and the material read as a generic translucent card.
2. Fix: switched the mobile panel to a width-driven 1.165 aspect ratio, tuned the 393pt control geometry, set the default state to My QR, strengthened layered glass edges and backdrop treatment, and applied native `.glassEffect(.regular)` to the SwiftUI panel.
3. Final pass: no actionable P0/P1/P2 findings. The online page was captured at the target mobile viewport and the primary interaction path was re-tested.

## Implementation checklist

- [x] Match the source mobile composition and centered panel.
- [x] Match the initial control order and compact proportions.
- [x] Apply layered glass depth and iOS 27 native Liquid Glass APIs.
- [x] Verify responsive mobile geometry.
- [x] Verify primary click transitions and return path.
- [x] Check the deployed page for console errors.

## Follow-up polish

- P3: compare the native iOS Simulator capture on a device running the iOS 27 SDK once full Xcode is available. The current host has Swift command-line tools but not the full Xcode Simulator toolchain.

final result: passed
