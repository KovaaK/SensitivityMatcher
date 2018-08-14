![Screenshot 1](https://i.redd.it/zt2a1a1yzyf11.png)

# Sensitivity Matcher

This is a script that lets you transfer your mouse sensitivity between any 3D games without requiring any calculation.

Run the script, then:

1) Select the preset/game that you are coming from.
2) Input your sensitivity value from your old game.
3) In your new game, adjust its sens until the test matches.

Press `Alt` `[` to perform one full revolution.

Press `Alt` `]` to perform multiple full revolutions.

Press `Alt` `\` to halt (and clear residuals).

&nbsp;

If the game that you are coming from is not listed, you can export your old sensitivity with the script.\
Select "Measure any game" and enter your best guess, then:

1) Perform rotation(s) to see if the guess undershoots or overshoots.
2) Nudge the estimation upper/lower bounds using the hotkeys below.
3) Test rotations again. Adjust the bounds again. Repeat the process until the script converges to a value.
4) Once you've finished measuring, you can match it to any game you like using the procedure in the previous section.\
Or, if the game is already listed, you can simply select it to convert the value immediately.

Press `Alt` `-` to nudge bound to correct overshoots.

Press `Alt` `+` to nudge bound to correct undershoots.

Press `Alt` `0` to clear bounds to reset and start over if you made a wrong input.

&nbsp;

With this script, sub-increment accuracy is preserved between rotations. This means that you can use the script to measure any base yaw to high precision by observing drifts over many cycles. In other words, you gets more accurate the more rotations you perform (accurate to 16 significant digits).

This eliminates the need to trust the accuracy of paywalled calculators, whose number typically come from rough estimates using just one rotation, since they're only able to approximate with integer counts. They get more inaccurate the more rotations they perform.
