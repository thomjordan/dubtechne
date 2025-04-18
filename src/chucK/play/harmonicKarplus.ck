// karplus + strong plucked string filter

/*
public class HarmonicKarplus
{  
    Noise imp => OneZero lowpass => dac;  // feedforward
    lowpass => Delay delay => lowpass;    // feedback
    
    [720, 675, 648, 600, 576, 540, 509, 480, 450, 432, 400, 384, 360] @=> int chromaticScale[];
    
    float L;                        // delay order
    .99999 => float R;              // radius

    Math.pow( R, L ) => delay.gain; // set dissipation factor
    -1 => lowpass.zero;             // place zero
    
    fun HarmonicKarplus(int nn) {
        chromaticScale[nn%12] => L; // set delay order 
        L::samp => delay.delay;     // set delay
        1 => imp.gain;              // fire excitation
        L::samp => now;             // for one delay round trip
        0 => imp.gain;              // cease fire
        
        (Math.log(.0001) / Math.log(R))::samp => now;  // advance time    
    }
}
*/

fun void hKarplus(int nn) 
{
    Noise imp => OneZero lowpass => dac;  // feedforward
    lowpass => Delay delay => lowpass;    // feedback
    
    [720, 675, 648, 600, 576, 540, 509, 480, 450, 432, 400, 384, 360] @=> int chromaticScale[];
    
    float L;                        // delay order
    .99999 => float R;              // radius
    
    Math.pow( R, L ) => delay.gain; // set dissipation factor
    -1 => lowpass.zero;             // place zero
    
    chromaticScale[nn%12] => L; // set delay order 
    L::samp => delay.delay;     // set delay
    1 => imp.gain;              // fire excitation
    L::samp => now;             // for one delay round trip
    0 => imp.gain;              // cease fire
    
    (Math.log(.0001) / Math.log(R))::samp => now;  // advance time       
}