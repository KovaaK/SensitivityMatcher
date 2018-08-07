![Screenshot 1](https://i.redd.it/z0avmc2lsfe11.png)

# Sensitivity Matcher

This is a script that lets you transfer your mouse sensitivity between any 3D games without requiring calculation.

Run the script, then:

1) Select the preset/game that you are coming from.
2) Input your sensitivity value from your old game.
3) In your new game, adjust its sens until the test matches.

Press `Alt` `[` to perform one full revolution.

Press `Alt` `]` to perform multiple full revolutions.

Press `Alt` `\` to halt (and clear residuals).

Sub-increment accuracy is preserved between rotations. This means that you can use the script to measure any base yaw to high precision (16 significant digits) by observing drifts over many cycles.

This eliminates the need to trust the accuracy of paywalled calculators, which typically use rough estimates from just one rotation, causing sub-increment errors to bulid up as they keep rounding to integer counts.

To measure an unknown sensitivity (such as if you are coming from a game that is not listed), select "Measure any game" and enter your best guess for the unknown value, then:

1) Spin once to determine if the guess undershoots or overshoots
2) Depending on under/overshoot, use the hotkeys listed below to nudge upper/lower bounds
3) Repeat the process until the script matches the unknown sensitivity you are measuring

Press `Alt` `-` to nudge bound if it overshoots.

Press `Alt` `+` to nudge bound if it undershoots.

Press `Alt` `0` to clear bound if you made a wrong input and needs to start over.
