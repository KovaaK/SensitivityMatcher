## Release Notes

[version 1.4]

_New Feature: Measurement Report_

* To facilitate crowdsourced measurement of yaw scales, measurement reports (.csv) are now produced automatically to better enable rigorous verification of shared results.

_Enhancement (active only in measurement mode): Measurement Cycle Autoscale and Nudge hotkeys_

* Number of cycle bumps up to match the (best-case) minimum needed to possibly drift by one increment. \
(Only kicks-in when you get very precise with convergence)
* Use nudge hotkeys (move one count left/right) to verify whether suspected drift exceeds margin of error. \
(Residual artifact can drift up to half count both ways)

_New: Added button to save current inputs to startup values._ \
_New: Saved custom yaw now includes uncertainty if obtained from measurement. Info dialogue also shows uncertainty._ \
_New: Asks whether user would like to use default binds if specific hotkeys are markedly unbound._ \
_Fix:  Measurement hotkeys now unbinds properly if keybind is tweaked while still in measurement mode._ \
_Fix:  Measurement bounds are no longer lost when swapping yaw and sens; cancelling Save now restores swap options._

## Download

[**SensitivityMatcher_exe.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_exe.zip) \
[**SensitivityMatcher_a3x.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_a3x.zip) (Use this instead if .exe is triggering false positives)

[_Go to newest release_](https://github.com/KovaaK/SensitivityMatcher/releases/latest)
