@import "globals"

[50.0, 53.9333333333, 55.9, 57.8666666666667, 61.8] @=> float swingSet[];
Math.random2(0,4) => int randomIndex;

625.0::ms / 4.0 => dur T;
(T*16.0) - (now % (T*16.0)) => now;

53.934466291663162 => float copperMeanish;
56.903559372884931 => float silverMeanish;
55.046260628866678 => float bronzeMeanish;
60.300566478845942 => float goldenMeanish;
57.2924            => float squarishGoldenMean;

// make sure we update swing on a downbeat only (here on the next half-note, to sound better)
// swingSet[randomIndex] => float swingAmount;
goldenMeanish => float swingAmount; 

g.makeSwing(swingAmount, T);

<<< "randomIndex:", randomIndex, "swingValue:", swingAmount >>>;
