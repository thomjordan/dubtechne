declare name "SawDL";
declare author "Thom Jordan";
declare copyright "Copyright (C) 2025 Thom Jordan <thomjordan@gatech.edu>";
declare license "MIT license";
declare version "1.0";
declare about "SawDL is a single oscillator sawtooth wave with built-in diodeLadder LP filter. It requires an envelope-generator as input, or else no sound will be heard. This is made for working well with EnvGen as input.";

import("stdfaust.lib");

freq=nentry("freq",54.0,50.0,5000.0,0.000000001);
gain=nentry("gain",0.1,0,1,0.001);
cutoff=nentry("cutoff",0.78,0,1.5,0.00001);
reson=nentry("reson",0.52,0,1,0.001);
glide=nentry("glide",8.88,0,500,0.01); // in ms
Q = reson * 25;
synth(env) = os.sawtooth(freq : si.smooth(ba.tau2pole(glide/1000))) * gain * env : ve.diodeLadder(cutoff * env * 2, Q) <: _,_;
process = _ : synth; // takes an envelope input