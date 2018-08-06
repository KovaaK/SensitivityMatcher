![Screenshot 1](https://i.redd.it/z0avmc2lsfe11.png)

# Sensitivity Matcher

This is a script that lets you transfer your mouse sensitivity between any 3D games with no calculation required.

Run the script, then:

1) Select the preset/game that you are coming from.
2) Input your sensitivity value from your old game.
3) In your new game, adjust its sens until the test matches.

Press `Alt+[` to perform one full revolution.

Press `Alt+]` to perform multiple full revolutions.

Press `Alt+\` to halt (and clear residuals).

The script can also be used to accurately measure any base yaw, by observing gradual drifts over many cycles. Because angle residuals are handled by a floating point accumulator, the measurement is accurate to 16 significant digits.

This eliminates the need to trust the accuracy of paywalled calculators, which typically use only one rotation for a rough esitmate approximated by integer counts.
