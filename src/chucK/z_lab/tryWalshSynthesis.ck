// Walsh function generator
fun float walsh(int sequency, float phase) {
    1 => int sign;
    for (0 => int i; i < 32; i++) {
        if ((sequency & (1 << i)) != 0) {
            (phase * (1 << i)) % 1.0 *=> sign
            sign *= ( (phase * (1 << i)) % 1.0 > 0.5 ) ? -1 : 1;
        }
    }
    return sign;
}

// Sine oscillator as phase generator
SinOsc phaseOsc => dac;

// Control frequency and amplitude
220 => phaseOsc.freq; 
0.3 => phaseOsc.gain;

// Period of the Walsh function
1.0 / 44100.0 => float dt;

// Global phase variable
0.0 => float phase;

// Walsh sequency index
4 => int sequency;

while (true) {
    // Increment phase
    phase + dt * phaseOsc.last() => phase;
    phase % 1.0 => phase; // Keep phase in [0, 1]
    
    // Output the Walsh function signal
    walsh(sequency, phase) * 0.3 => dac.left;
    walsh(sequency, phase) * 0.3 => dac.right;
    
    // Sampling rate control
    1::samp => now;
}