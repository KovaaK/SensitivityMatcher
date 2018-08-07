![Screenshot 1](https://i.redd.it/z0avmc2lsfe11.png)

# Sensitivity Matcher

This is a script that lets you transfer your mouse sensitivity between any 3D games without requiring any calculation.

Run the script, then:

1) Select the preset/game that you are coming from.
2) Input your sensitivity value from your old game.
3) In your new game, adjust its sens until the test matches.

Press `Alt` `[` to perform one full revolution.

Press `Alt` `]` to perform multiple full revolutions.

Press `Alt` `\` to halt (and clear residuals).

Sub-increment accuracy is preserved between rotations. This means that you can use the script to measure any base yaw to high precision by observing drifts over many cycles (accurate to 16 significant digits). In other words, the more rotation you perform, the more accurate your test gets.

This eliminates the need to trust the accuracy of paywalled calculators, whose number typically come from rough estimates using just one rotation, since they're only able to approximate with integer counts, which gets more inaccurate the more rotation they perform.

To measure an unknown sensitivity (such as if you are coming from a game that is not listed), select "Measure any game" and enter your best guess for the unknown values, then:

1) Perform rotation(s) to determine if the guess undershoots or overshoots.
2) Depending on under/overshoot, use the hotkeys listed below to nudge upper/lower bounds.
3) Repeat the process until the script matches the unknown increment being measured.

Press `Alt` `-` to nudge bound if it overshoots.

Press `Alt` `+` to nudge bound if it undershoots.

Press `Alt` `0` to clear bounds if you made a wrong input and needs to start over.

The script will gradually converge to the exact solution. You can then convert the measured increment into any game you like using the initial procedures. Or, if the game is listed, you can immediately convert the increment in memory to the listed game's sensitivity by selecting it from the dropdown.
