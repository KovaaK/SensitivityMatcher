### [ Download Current Binary Release.](https://github.com/KovaaK/SensitivityMatcher/releases/latest)
![Screenshot 1](https://i.redd.it/a65t3psme5p11.png)
# Sensitivity Matcher

This script lets you match your mouse sensitivity between any 3D games directly, and forego paywalled calculators. 

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
3) Test again. Repeat the process until the script always lands on the exact origin even after many turns.
4) Once you're done measuring, you can match it to any game you like with procedures outlined in the first section.\
Or, if the game is already listed, simply select it from the dropdown to convert immediately.

Press `Alt` `-` to correct overshoots.

Press `Alt` `+` to correct undershoots.

Press `Alt` `0` to start over if you made a wrong correction.

&nbsp;

With this script, sub-increment accuracy is preserved between rotations, rapidly quenching the uncertainty with each cycle. This means that the script can measure any base yaw to high degree of precision by monitoring for drifts over many cycles.

You no longer need to trust paywalled calculators that derive their measurement from single-rotation estimates approximated by integer counts, which amplifies their measurement error multiplicatively with each successive turn.
