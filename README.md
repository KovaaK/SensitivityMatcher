# [ Download Sensitivity Matcher here (NOT the green button).](https://github.com/KovaaK/SensitivityMatcher/releases/latest)
[![Screenshot 1](https://i.redd.it/3vmnm6ne3i241.png)](https://github.com/KovaaK/SensitivityMatcher/releases/latest)


This script lets you match your mouse sensitivity between any 3D games directly and much more precisely than any paywalled calculators.

Run the script, then:

1) Select the preset/game that you are coming from.
2) Input your sensitivity value from your old game.
3) In your new game, adjust its setting until the repeater make exact turns in game with no drift.

Press `Alt` `"` to perform one full revolution.

Press `Alt` `Shift` `"` to perform multiple full revolutions.

Press `Alt` `\` to halt (also clears the residual angles).

&nbsp;

If the game that you are coming from is not listed, the script can also capture your old sensitivity.\
Select "Measure any game" and go into the game from which you wish to export your sensitivity, then:

1) Aim at a precise marker in game, then press the Record hotkey to record your mouse movement
2) Use your mouse to turn 360 degrees aiming back to marker, and press the hotkey again to stop recording.
3) Use the Repeater hotkeys to check its accuracy, correct over/undershoots with the fine tuner hotkeys
4) You can now match the captured sensitivity to any game. Select the game from the dropdown to see its corresponding in-game number.

Press `Alt` `/` to start/finish recording.

Press `Alt` `+` to correct overshoots.

Press `Alt` `-` to correct undershoots.

Press `Alt` `0` to restart if you made a wrong correction.    

&nbsp;

With this script, sub-increment accuracy is preserved between rotations, rapidly quenching the uncertainty with each cycle. This means that the script can measure any base yaw to high degree of precision by monitoring for drifts over many cycles.

You no longer need to trust paywalled calculators that derive their measurement from single-rotation estimates approximated by integer counts, which amplifies their measurement error multiplicatively with each successive turn.
