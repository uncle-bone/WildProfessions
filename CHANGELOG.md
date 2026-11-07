# Changelog

## 1.0.0 - Testing foundation

- Added standalone per-character profession tracking and bounded skill progress history.
- Added the initial profession dashboard, compact progress tracker, strategy preference controls, and diagnostics.
- Added a contextual launcher and companion panel for the Forever profession window.
- Added optional host detection for the native Forever profession pane and NaowhForever's profession window.
- Kept the addon independent of NaowhForever and EllesmereUI; no addon source, artwork, or datasets are copied.
- Added guarded C_TradeSkillUI scanning with a legacy profession API fallback.
- Fixed dashboard initialization to use Forever's `SetResizeBounds` API and safely disable resizing if unavailable.
- Clearly mark recipe routes, costs, materials, gathering routes, and client runtime behavior as unverified or not yet implemented.

This is an early testing build, not a claim that every requested leveling, recipe, gathering, or Forever-specific feature is complete.

