## Release Notes

[version 1.4]

_New Feature: Measurement Report_

To facilitate crowdsourced efforts for stringent measurement and independent verification of yaw scales, measurement reports are now produced automatically to better enable rigorous peer review of shared results.

_Enhancement: Measurement Cycle Autoscale and Nudge hotkeys (active only in measurement mode)_

Number of cycles in measurement mode now scales to match the (best-case) minimum required to produce a deviation of one count (only kicks-in when you get very, very precise). This in conjunction with the nudge hotkeys lets you verify whether observed deviations exceed margin of error (residual angle artifact can deviate up to half count).

_New: Added button to save current inputs to startup values._ \
_New: Saved custom yaw now includes uncertainty if obtained from measurement. Info dialogue also shows uncertainty._ \
_Fix:  Measurement hotkeys now unbinds properly if keybind is tweaked while still in measurement mode._ \
_Fix:  Measurement bounds are no longer lost when swapping yaw and sens; cancelling Save now restores swap options._

## Download

[**SensitivityMatcher_exe.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_exe.zip) \
[**SensitivityMatcher_a3x.zip**](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.4/SensitivityMatcher_a3x.zip) (Use this instead if .exe is triggering false positives)

[_Go to newest release_](https://github.com/KovaaK/SensitivityMatcher/releases/latest)
