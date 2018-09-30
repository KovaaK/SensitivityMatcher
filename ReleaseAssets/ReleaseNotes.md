## Release Notes

[version 1.4]

_New Feature: Measurement Report_

To facilitate crowdsourced efforts for stringent measurement and independent verification of yaw scales, measurement reports are now produced automatically to better enable rigorous peer review of shared results.

_Enhancement: Measurement Cycle Autoscale and Nudge hotkey_

During measurement mode, as your upper/lower bounds converges, the number of cycles now increases to match the minimum required to produce deviation of at least one count, given the best-case scenario for the uncertainty (worse cases require more, so there really is no reason to use anything less than the auto-adjusted value). This in conjunction with the nudge hotkeys (move left or right by single counts, active only during measurement mode) enables you to quickly verify if the observed deviation exceeds margin of error (the residual angle artifact can have deviations of up to half count even if the increment is dead-on), by nudging one count to see if it is far enough off the mark.

_New: Added button to save current inputs to startup values._ \
_New: Saved custom yaw now includes uncertainty if obtained from measurement. Info dialogue also shows uncertainty._ \
_Fix:  Measurement hotkeys now unbinds properly if keybind is tweaked while still in measurement mode._ \
_Fix:  Measurement bounds are no longer lost when swapping yaw and sens; cancelling Save now restores swap options._

## Download

[**SensitivityMatcher_exe.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_exe.zip) \
[**SensitivityMatcher_a3x.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_a3x.zip) (Use this instead if .exe is triggering false positives)

[_Go to newest release_](https://github.com/KovaaK/SensitivityMatcher/releases/latest)
