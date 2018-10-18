## Release Notes

[version 1.4 highlights]

_New Feature: Measurement Report_

* To facilitate crowdsourced measurement of yaw scales, measurement reports (.csv) are now produced automatically to better enable rigorous verification of shared results.

_Enhancement (active only in measurement mode): Measurement Cycle Autoscale and Nudge hotkeys_

* Number of cycles gets bumped up automatically as you gets more and more precision during measurement mode. \
(Only starts to kicks-in when you get _really_ precise)
* Nudge hotkeys (move one count left/right) to verify whether suspected drift exceeds margin of error. \
(Residual artifact can drift up to half increment both ways)

## Download

[**SensitivityMatcher_exe.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_exe.zip) \
[**SensitivityMatcher_a3x.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_a3x.zip) (Use this instead if .exe is triggering false positives)

[_Go to newest release_](https://github.com/KovaaK/SensitivityMatcher/releases/latest)

## Changelog
_New: In measurement mode, # of cycles bumps up to match the (best-case) minimum needed to possibly drift by one increment._ \
_New: Added Nudge hotkeys that lets you send individual counts to check if deviation is at least one count._ \
_New: Added button to save current inputs to startup values._ \
_New: Added back the "Custom" item, upon selection it makes your yaw equal the increment (useful for testing multipliers)_ \
_New: Saved custom yaw now includes uncertainty if obtained from measurement. Info dialogue also shows uncertainty._ \
_New: Asks whether user would like to use default binds if specific hotkeys are markedly unbound._ \
_New: "Info" button shows contexual instructions depending on selected mode._ \
_Fix:  Measurement hotkeys now unbinds properly if ini is tweaked while still in measurement mode._ \
_Fix:  Measurement bounds are no longer lost when swapping yaw and sens; cancelling Save now restores swap options._ \
_Fix:  Minor optimization for floating point precision for multi-cycle turns._
