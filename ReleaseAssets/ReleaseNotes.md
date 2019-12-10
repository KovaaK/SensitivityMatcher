## Release Highlights
[version 1.5]

[![Screenshot](https://i.redd.it/324p9wyf3i241.png)](https://github.com/KovaaK/SensitivityMatcher/releases/latest)

_New Feature: Rawinput recording_

* In Measurement Mode, you can now set up initial guesses more quickly using your mouse instead (default hotkey is `[Alt][/]` to toggle recording). 
* Just record rotations with slight over- or undershoots and mark them accordingly. This immediately narrows down the range, from then on you can further converge the measurement using the repeater.
* This feature is also great for helping new FPS players quickly find a comfortable initial sensitivity. Just record two 180° swipes that you can do comfortably, and the corresponding setting is given for you to set in game.
* The physical sensitivity calculator now also includes a CPI calibration feature to take advantage of the rawinput capability. This lets you get a more accurate calculation of your physical sensitivity accounting for variances in mouse.

_New Feature: Chatbot command generator_

* Copy your newly measured sens into your Nightbot !sens commands with the click of a button! 
* Just click on "Share" in the physical stats calculator, and it will generate the text string summarizing all your current settings, including your game-specific sensitivity, your mouse cpi, and the corresponding physical sensitivity values.

_Usability Change: Default hotkeys of some commands have been changed_
* Turn once: ~~`Alt [`~~ changed to `Alt` `Backspace`
* Turn a lot: ~~`Alt ]`~~ changed to `Alt` `Shift` `Backspace`
* Jog right: ~~`Alt '`~~ changed to `Alt` `>`
* Jog left: ~~`Alt ;`~~ changed to `Alt` `<`

_Enhancement: Convergence Log window during Measurement Mode_

* Graph showing convergence progress of your estimate tuning.
* GUI buttons for the fine-tuner function, for those who prefer them over hotkeys.
* Display the convergence history as a table (in addition to the detailed log file output).

## Download

[**SensitivityMatcher_exe.zip** (64bit)](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.5/SensitivityMatcher_exe.zip) \
[**SensitivityMatcher_a3x.zip** (32bit)](https://github.com/KovaaK/SensitivityMatcher/releases/download/1.5/SensitivityMatcher_a3x.zip) (Use this instead if .exe is triggering false positives)

[_Go to newest release_](https://github.com/KovaaK/SensitivityMatcher/releases/latest)

## Changelog
_Revert: removed the autocycle scaling that was added in 1.4 -- too hidden of a mechanic_ \
_New: changed default hotkeys for tuning and jogging counts. See helptext._ \
_New: changing the cpi field will now immediately save to ini._ \
_New: script will make distinct beeps when activating/deactivating rawinput recording with hotkeys. Activating with GUI button will show a confirmation dialog instead._ 
