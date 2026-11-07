# Profession pane and UI addon compatibility

Status: source-based design and implementation review; must still be tested in game with the target Forever build and each UI configuration. The Forever UI-source mirror currently identifies build 1.60.1.70862; the project's last reported installed build is 1.60.1.70790, so exact 70790 runtime compatibility remains unverified.

## UI approach

WildProfessions keeps Forever's profession window as the primary place to browse and select crafts. A compact `WP` launcher is a separate `UIParent` sibling positioned beside the active pane. Clicking it opens the WildProfessions companion panel beside the pane; the panel follows the selected skill and displays profession progress, planning preference, and route-data confidence. `/wp` opens or closes the same dashboard, and opens it as a standalone panel when no profession window is active.

This avoids an unsupported takeover of the Blizzard recipe list, private mixin methods, or profession tabs. The pane's current list remains in charge of recipe browsing and crafting. WildProfessions does not execute crafting actions.

## Forever native pane

The Forever branch of Blizzard's UI source declares `ProfessionsFrame`, a crafting page, and profession tabs in `Blizzard_Professions/Camelot/Blizzard_ProfessionsFrame.xml`. `ProfessionsMixin` emits `ProfessionsFrame.Show` and `ProfessionsFrame.Hide`, and the profession selection flow emits `Professions.ProfessionSelected`. `TRADE_SKILL_SHOW`, `TRADE_SKILL_LIST_UPDATE`, `TRADE_SKILL_CLOSE`, and `SKILL_LINES_CHANGED` also appear in the native frame event set.

The Forever UI source also shows the Camelot pane using `GetProfessions()` / `GetProfessionInfo()` for its profession tabs, and `C_TradeSkillUI.GetBaseProfessionInfo()` through its shared profession layer. The addon therefore probes the current C API first and uses the legacy globals as a guarded fallback.

## NaowhForever

NaowhForever's current public profession module creates an addon-owned global frame named `NaowhForeverProfessions`. Its takeover module hooks the Blizzard window and can set the Blizzard pane alpha to zero while showing its own window. WildProfessions checks whether that public frame is visible and anchors to it when active; it does not alter Naowh's frame, call Naowh APIs, or declare a dependency. If the custom frame is absent/hidden, it falls back to the visible native pane. The NaowhForever source is licensed all rights reserved except separately licensed externals, so this addon includes no copied implementation, data, or artwork.

## EllesmereUI

EllesmereUI's Shifter source lists `ProfessionsFrame` among frames it supports and treats several Blizzard windows as protected. WildProfessions does not set the native frame's point, parent, scale, strata, or movable/resizable state. The launcher and panel are created under `UIParent` and positioned relative to the active window. EllesmereUI is not required and no private theme API is assumed.

The launcher and dashboard use standard Blizzard frame templates, which can be visually tested under both EUI presets. If a future EUI build skins or moves the pane differently, the addon can still be used standalone with `/wp`.

## Remaining live checks

1. With no UI overhaul, open each profession and verify that the WP button appears beside the native pane, shows the companion on click, and tracks profession switching.
2. With NaowhForever professions enabled, verify WildProfessions attaches to `NaowhForeverProfessions` rather than the transparent native frame and does not cover Naowh controls.
3. With EllesmereUI Forever enabled, verify its shifter still moves/scales the native pane without taint errors and the sibling launcher follows it.
4. Test NaowhForever plus EllesmereUI together; verify the companion follows the visible Naowh pane while the EUI shifter controls continue to work.
5. Close the host pane and confirm a docked companion closes, while a manually opened standalone `/wp` view remains usable.

## Source references

- Forever Blizzard UI source mirror, professions frame: https://github.com/Gethe/wow-ui-source/tree/forever/Interface/AddOns/Blizzard_Professions
- Forever professions pane XML: https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_Professions/Camelot/Blizzard_ProfessionsFrame.xml
- Forever professions API documentation: https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/TradeSkillUIDocumentation.lua
- NaowhForever profession takeover: https://github.com/naowh-gaming/NaowhForever/blob/main/NaowhForever_Professions/UI/Takeover.lua
- NaowhForever profession window: https://github.com/naowh-gaming/NaowhForever/blob/main/NaowhForever_Professions/UI/Window.lua
- EllesmereUI Shifter: https://github.com/EllesmereGaming/EllesmereUI/blob/main/EllesmereUIQoL/EllesmereUIQoL_Shifter.lua
- Forever UI-source mirror build marker: https://github.com/Gethe/wow-ui-source/blob/forever/version.txt

