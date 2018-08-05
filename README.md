![Screenshot 1](https://i.redd.it/9mz7qsymx3e11.png)

# Sensitivity Matcher

This is a script that can be used to convert your mouse sensitivity between any 3D games without preemptive calculation.

Run the script, then:

1) Select the Preset/game that you are coming from.
2) Input your sensitivity value from your old game.
3) In your new game, adjust its sens until the test matches.

Press `Alt+[` to perform one full revolution.

Press `Alt+]` to perform multiple full revolutions.

Press `Alt+\` to halt.

Angle residuals are handled by a floating point accumulator. By observing gradual view drifts over many cycles, the script can be used to accurately measure any game's base yaw to 16 significant digits.

This eliminates the need to trust paywalled calculators that may or may not have accurate numbers.
