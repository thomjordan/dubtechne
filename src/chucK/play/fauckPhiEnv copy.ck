96. => float bpm;
15000::ms / bpm => dur sixteenth; // 16th-note pulse @ 96 bpm
sixteenth * 4 => dur beat;
sixteenth * 2 => dur eighth;
beat * 8 => dur twoBars;

<<< "twoBars: ", twoBars >>>;

//Faust sawEnvFilt => blackhole;
//Faust envln => blackhole;
     
EnvGen envlnGen => SawDL saw => AKJRev rev => dac; // SawDL needs to be recompiled with a "filterModAmt" parameter
    
fun dur th(int durtype) {
    beat * 4 => dur wholeNote;
    wholeNote / (durtype$float) => dur result;
    return result;
}
fun dur th(float durtype) {
    beat * 4 => dur wholeNote;
    wholeNote / durtype => dur result;
    return result;
}

[1., 1.066666666666667, 1.2, 1.333333333333333, 1.5, 1.6, 1.8, 2.] @=> float scl1[];
[1., 1.053497942386831, 1.185185185185185, 1.333333333333333, 1.5, 1.580246913580247, 1.8, 2.] @=> float scl2[];
[scl1, scl2] @=> auto scales[][];



//54.=> float baseFreq;
68.05 => float baseFreq;
 1 => int scaleChoice;
 1 => int octave;
4 => th => dur pulse;

// when multiple shreds of this file are playing simultaneously, this is a way to differentiate them
//   by supplying it from Python when launching the file_shred
 1 => int shred_voice_num; 

// process optional command-line args
for( int i; i < me.args(); i++ ) {
    me.arg(i) => string arg;
    if(i==0) Std.atoi(arg) => shred_voice_num;
    if(i==1) Std.atoi(arg) => octave;
    if(i==2) Std.atof(arg) => th => pulse;
    if(i==3) Std.atoi(arg) => scaleChoice;
    //<<< "command-line arg", i, ":", me.arg( i ) >>>;
}

fun foo() {
    while(true) {
        <<< "shred_voice_num", shred_voice_num, " says: foo!" >>>;
        2::second => now;
    }
}
// spork ~ foo();

3.1   => float maxAttack;  // the percentage of pulse that should be used for the maximum duration of attack
132.0 => float maxRelease; // the percentage of pulse that should be used for the maximum duration of release

38.2 => float attackVariance;  // the percentage of "maxAttack" above that individual notes may shorten by
30.0 => float releaseVariance; // the percentage of "maxRelease" above that individual notes may shorten by

// octave, pulse: 0, 1.25 | 2, 4 |  3, 8  // all on same scale (1)

//scales[(scaleChoice-1) % scales.size()] @=> float scale[];
//[1., 1.2, 1.5, 1.8, 2., 1.8, 1.5, 1.2] @=> float scale[];
[1., 2.] @=> float scale[];

3::samp => dur gateHold;

0.618 => saw.glide;
0.5   => rev.feedback;
2000  => rev.cutoff;
0.382 => rev.wet;
0.01  => saw.gain;

maxAttack*pulse/100.  => dur maxAttackTime;
maxRelease*pulse/100. => dur maxReleaseTime;

// for sync'ing to other shreds
// The standard approach is then shifted back by attackTime, so the perceived-point-of-onset sounds completely in sync, ensuring the envelope has time to fully open before "the standard sync point"
// TODO: add attack variation/articulation, so that the longest possible attackTime is used for the sync calculation, while the attack of some subsequent notes may be shorter...
//  ...in which case the sounding of that particular note is delayed by { maxAttackTime - pnAttackTime } where 'pn' means 'particular-note'
//twoBars - ((now + maxAttackTime) % twoBars) => now;  

//twoBars - (now % twoBars) => now;  

// secondsToWaitBeforeNextTwoBarDownbeat = (480.0/bpm) - ((localSystemTimeInSeconds - chuckStartInRedis) % (480.0/bpm))

// 
// bpm = 96.0
// numbeats_in_sync_period = 8

// sync_period = 60.0 * numbeats_in_sync_period / bpm
// seconds_to_wait_before_next_sync_boundary = sync_period - ((local_system_time - chuck_start_time_in_redis) % sync_period)

0 => int counter;

while( true )
{
    (1.- Math.randomf()*attackVariance /100.) * maxAttackTime  => dur currentNoteAttackTime;  // shorten the attack time by some random amount from 'nothing' up to the attackVariance (percentage-of-maxAttackTime)
    (1.- Math.randomf()*releaseVariance/100.) * maxReleaseTime => dur currentNoteReleaseTime; // similarly, shorten the release time by another random amount
    
    maxAttackTime - currentNoteAttackTime => dur offsetDelayForCurrentNote; // the difference between maxAttackTime & currentNoteAttackTime provides the relative location for starting the current note with a potentially shorter attack-time
    offsetDelayForCurrentNote => now; // advance time (i.e. "delay note") by the offset
    
    //scale[Math.random2(0, scale.size()-1)]*baseFreq*Math.pow(2,octave) => float noteFreq;
    scale[counter%scale.size()] * baseFreq*Math.pow(2,octave) => float noteFreq;
    counter + 1 => counter;
    
    noteFreq => saw.freq;
    
    // convert AR durations into float values for input into EnvGen
    currentNoteAttackTime/1::second  => envlnGen.attack;  
    currentNoteReleaseTime/1::second => envlnGen.release;
     
    1 => envlnGen.gate; // trigger envelope to start note
    
    //sawEnvFilt.v("freq", noteFreq);
    //sawEnvFilt.v("gate", 1);
    
    gateHold => now;
    0 => envlnGen.gate; //  
    //sawEnvFilt.v("gate", 0);
    
    // advance time by the period given by "pulse" minus the two offsets
    pulse - gateHold - offsetDelayForCurrentNote => now;
    //pulse - gateHold => now;
    
    <<< "pulse", pulse >>>;
}

/*
saw.eval(`
freq=nentry("freq",54.0,50.0,5000.0,0.000000001);
gain=nentry("gain",0.1,0,1,0.001);
cutoff=nentry("cutoff",0.78,0,1.5,0.00001);
reson=nentry("reson",0.52,0,1,0.001);
glide=nentry("glide",8.88,0,500,0.01); // in ms
Q = reson * 25;
synth(env) = os.sawtooth(freq : si.smooth(ba.tau2pole(glide/1000))) * gain * env : ve.diodeLadder(cutoff * env * 2, Q) <: _,_;
process = _ : synth; // takes an envelope input
`);

sawEnvFilt.eval(`
freq=nentry("freq",440,50,2000,0.01);
gate=nentry("gate",0,0,1,1);
Q = 10;
normFreq = 0.618;

ar(a, r, g) = v
letrec {
    'n = (n + 1)* (g <= g');
    'v = (n < a) * attack_curve(n) * (g <= g') + (n >= a) * release_curve(n) * (g <= g') * 0.5;
    where
    k_a = log(2) / a;  // Scaling factor for attack
    k_r = log(2) / r;  // Scaling factor for release
    attack_curve(n)  = 1 - exp(-k_a * n); // Increasing concave curve
    release_curve(n) = exp(-k_r * (n - a)); // Decreasing convex curve
};

env = ar(3000, 30000, gate);
mod = 2;

process = os.sawtooth(freq) * env : ve.diodeLadder(normFreq * env * mod, Q) <: _,_;
`);

envln.eval(`
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
process = _,_ :> *(env) <: _,_;
`);

envlnGen.eval(`
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
`);
*/