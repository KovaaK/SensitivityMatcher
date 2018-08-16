![Screenshot 1](https://i.redd.it/zt2a1a1yzyf11.png) 
# Sensitivity Matcher

Match your mouse sensitivity between any 3D games directly, no paywall calculator involved. [Download link.](https://github.com/KovaaK/SensitivityMatcher/releases/latest)

Run the script, then:

1) Select the preset/game that you are coming from.
2) Input your sensitivity value from your old game.
3) In your new game, adjust its sens until the test matches.

Press `Alt` `[` to perform one full revolution.

Press `Alt` `]` to perform multiple full revolutions.

Press `Alt` `\` to halt (and clear residuals).

&nbsp;

If the game that you are coming from is not listed, the script can also measure your old sensitivity.\
Select "Measure any game" and enter your best guess, then:

1) Perform rotation(s) to see if the estimate under- or overshoots.
2) Make corrections using the hotkeys below.
3) Test again. Repeat the process until the script converges to full revolutions precisely.
4) Once you've finished measuring, you can match it to any game you like with first section's procedure.\
Or, if the game is already listed, simply select it from the dropdown to convert immediately.

Press `Alt` `-` to correct overshoots.

Press `Alt` `+` to correct undershoots.

Press `Alt` `0` to start over if you made a wrong correction.

&nbsp;

With this script, sub-increment accuracy is preserved between rotations. This means that you can use the script to measure any base yaw to high precision by observing drifts over many cycles. In other words, you gets more accurate the more rotations you perform (accurate to 16 significant digits).

This eliminates the need to trust the accuracy of paywalled calculators, whose number typically come from rough estimates using just one rotation, since they're only able to approximate with integer counts. They get more inaccurate the more rotations they perform.
