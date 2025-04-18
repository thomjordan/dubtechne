declare name "EnvGen";
declare author "Thom Jordan";
declare copyright "Copyright (C) 2025 Thom Jordan <thomjordan@gatech.edu>";
declare license "MIT license";
declare about "EnvGen generates a one-shot gate-triggered AR envelope with a concave logarithmic attack phase and convex logarithmic release. It is for use as an input to any sound generator that takes an envelope as input. The gate needs to be closed manually, but it happen anytime after 2 samples duration. Once triggered, the envelope will always last for the duration of attack + release.";

import("stdfaust.lib");

gate=nentry("gate",0,0,1,1);
attack=nentry( "attack", 0,0,5,0.0001); // in seconds
release=nentry("release",0,0,5,0.0001); // in seconds

ar(a, r, g) = v
letrec {
    'n = (n + 1)* (g <= g');
    'v = (n < a) * attack_curve(n) * (g <= g') + (n >= a) * release_curve(n) * (g <= g') * 0.5;
    where
        k_a = log(2) / a;  // Scaling factor for attack
        k_r = log(2) / r;  // Scaling factor for release
        attack_curve(n)  = 1 - exp(-k_a * n);   // Increasing concave curve
        release_curve(n) = exp(-k_r * (n - a)); // Decreasing convex curve
};
env = ar(attack * ma.SR, release * ma.SR, gate); // input to ar() is in number of samples
process = env; // this env has no input; it simply generates a control signal
