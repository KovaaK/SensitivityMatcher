## Release Highlights

[version 1.5]

_New Feature: Rawinput recording_

* In Measurement Mode, you can now set up upper/lower initial guesses more quickly using your mouse instead (default hotkey is `[Alt][/]` to toggle recording). 
* Just record rotations with slight over- or undershoots and mark them accordingly. This immediately narrows down the range, from then on you can further converge the measurement using the repeater.
* This feature is also great for quickly helping new FPS players find a comfortable initial sensitivity, just record two 180° swipes that you can do comfortably, and the corresponding setting is calculated.
* The physical sensitivity calculator now also includes a CPI calibration feature to take advantage of the rawinput capability.

_Enhancement: Convergence Log window during Measurement Mode_

* Graph showing convergence progress of your Turn-Capture function.
* GUI button for the fine-tuner function, for those who prefer them over hotkeys.
* Button to display the convergence history as a table (in addition to the detailed log file output).

_Usability Change: Default hotkeys of some commands have been changed_
* Turn once: ~~`Alt [`~~ changed to `Alt` `'` (single quote)
* Turn a lot: ~~`Alt ]`~~ cahnged to `Alt` `;`
* Jog right: ~~`Alt '`~~ changed to `Alt` `>`
* Jog left: ~~`Alt ;`~~ changed to `Alt` `<`

## Download

[**SensitivityMatcher_exe.zip** (64bit)](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.5/SensitivityMatcher_exe.zip) \
[**SensitivityMatcher_a3x.zip** (32bit)](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.5/SensitivityMatcher_a3x.zip) (Use this instead if .exe is triggering false positives)

[_Go to newest release_](https://github.com/KovaaK/SensitivityMatcher/releases/latest)

## Changelog
_Revert: removed the autocycle scaling that was added in 1.4 -- too hidden of a mechanic_ \
_New: changed default hotkeys for tuning and jogging counts. See helptext._ \
_New: changing the cpi field will now immediately save to ini._ \
_New: script will make distinct beeps when activating/deactivating rawinput recording with hotkeys. Activating with GUI button will show a confirmation dialog instead._ 
