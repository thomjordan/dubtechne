@import "globals" // as 'g'

SawOsc osc => LPF filter => dac;
0.0 => osc.gain;

96. => float bpm;
15000::ms / bpm => dur _16th; // 16th-note pulse @ 96 bpm
(_16th*8.0) - (now % (_16th*8.0)) => now;

// must explicitly generate the swing info
// based on the current tempo & pulse length (16th, 8th, etc.)
g.makeSwing(50., _16th); 

0 => filter.freq;
68.05 / 1 => float freq;
3.25 => filter.Q;
0.0618 => osc.gain;

[1.0, 1.5, 2.0, 1.6] @=> float scalars1[];
[1.0, 2.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0,
 1.0, 2.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0,
 1.0, 2.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0,
 1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 2.0, 3.0 ] @=> float scalars2[];

scalars2 @=> float scl[];
[1., 2., 1., 1., 2., 1., 2., 4.] @=> float octaves[];

[1,2,3,4] @=> int list[];

0 => int counter;

while(true) 
{
    scl[counter/1 % scl.size()] => float s;
    octaves[counter/1 % octaves.size()]$float * freq => osc.freq;
    
    for(2000 => int i; i > 0; i--) {
        (i * s) / 4.0 => filter.freq;
        g.swingValues[(counter%2)+1] / (2000$float) => now;
    }
    counter + 1 => counter;
}