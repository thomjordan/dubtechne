// by Thom Jordan 3/10/25

// Plays Karplus-Strong synthesized notes for incoming midi notes
// based on example at: https://chuck.stanford.edu/doc/examples/deep/plu.ck

@import "midi"

// randomizes input value by percentage amount (+- percentAmt/2)
fun float jitterize(float inval, float percentAmt) 
{
    Math.randomize(); // reseed RNG to an unpredictable value
    percentAmt/100.0 => float randAmt;
    inval + (Math.randomf() * randAmt - (randAmt/2.0)) => float result;
    return result;
}

// maxJitterize() returns the maximum possible value of jitterize() for the same inputs
// useful for knowing when to terminate shreds: after the maximum value of a jitterize(releaseTime, p) operation
fun float maxJitterize(float inval, float percentAmt) { return inval + (inval * (percentAmt/200.0)); }
fun float minJitterize(float inval, float percentAmt) { return inval - (inval * (percentAmt/200.0)); }  // for testing

// calculates a random delay value between 0 and input-arg maxDelay (in milliseconds)
fun float getRandomDelay(float maxDelay) { Math.randomize(); return Math.randomf() * maxDelay; }

// basic event for providing ubiquitous access to a single value that changes over time, mapped over a range
class MappedValueEvent extends Event
{
    float inputValue; // value should be from 0 to 1;
    float range[];
    
    // constructor
    fun MappedValueEvent(float r[]) { r @=> range; } 
    
    // for setting value from a midi message
    fun setNormalizedInput(int midiValue) { midiValue / 127.0 => inputValue; }  
    
    // returns inputValue mapped over range
    fun float mapValueToRangeOf(string parameterName) { 
        param[parameterName] @=> Parameter param;
        return (param.attr["max"] - param.attr["min"]) * inputValue + param.attr["min"]; 
    }
}

// setup associative array to hold parameter objects (sets of attributes for parameters made with makeNewParameter() )
// example: "min" & "max" attributes are accessed to transform incoming control values into the correct range
// TODO: create attributes for alternate approach: "center" and "width"
// TODO: provide a way to set attribute values via midi controllers
Parameter param[0];
class Parameter extends Object { float attr[0]; }
fun void makeNewParameter(string parameterName)  { new Parameter @=> param[parameterName]; } 
fun float get(string parameterName, string attributeName) { return param[parameterName].attr[attributeName]; }

// make parameter for filter cutoff and set its attributes
makeNewParameter("lowpassFilterCutoff");
2000.0 => param["lowpassFilterCutoff"].attr["max"];
 800.0 => param["lowpassFilterCutoff"].attr["min"]; 
 
// make parameter for AR envelope release and set its attributes
makeNewParameter("release");
1.25 => param["release"].attr["time"]; 
20.0 => param["release"].attr["jitter"]; // percentage of randomization for each note

// instantiate dynamics processor on the "master bus" (i.e. making it 'global')
global Dyno dy => dac; 
dy.limit();       // set dynamics processor to default values for limiter functionality
dy.ratio(10);     // sets slopeAbove to 1/arg
dy.thresh(0.5);   // for all input-values above arg-value, slopeAbove kicks in to determine output-gain vs input-gain
0.8 => dy.gain;   // compensate for the limiter's gain reduction

48000.0  => float fs;    // sample rate
1.2 / fs => float alpha; // non-linear correction coefficient

// calculate an adjusted delay length in samples, to correct progressively out-of-tune notes in the higher registers
// set the correction coefficient alpha above to any value that makes the higher notes sound most in tune
fun float correctedDelay(float freq) {
    return fs / (freq + alpha * (freq * freq));
}

// Tuning ratios for the 22 Shrutis
  1.0/1   => float s0;
256.0/243 => float s1;
 16.0/15  => float s2;
 10.0/9   => float s3;
  9.0/8   => float s4;
 32.0/27  => float s5;
  6.0/5   => float s6;
  5.0/4   => float s7;
 81.0/64  => float s8;
  4.0/3   => float s9;
 27.0/20  => float s10;
 45.0/32  => float s11;
 64.0/45  => float s12;
  3.0/2   => float s13;
128.0/81  => float s14;
  8.0/5   => float s15;
  5.0/3   => float s16;
 27.0/16  => float s17;
 16.0/9   => float s18;
  9.0/5   => float s19;
 15.0/8   => float s20;
243.0/128 => float s21;

[s0, s2, s4, s6, s7,  s9, s11, s13, s15, s16, s19, s20] @=> float chromatic1[];
[s0, s1, s3, s5, s8, s10, s12, s13, s14, s17, s18, s21] @=> float chromatic2[];

261.63 => float baseFreq; // commonly set to the frequency of middle-C

// for sporking from midi receive loop (main loop), plays a note until noteOff is received and release envelope ends
fun void harmonicKarplus(Event noteOffListener, MappedValueEvent chPressListener, MidiMsg midiMsg, float tuning[], float panAmt) 
{
    Noise imp => OneZero lowpass => Envelope env => LPF lpf => Pan2 panner => global Dyno dy; // feedforward
    lowpass => Delay delay => lowpass;   // feedback
    
    panAmt => panner.pan; // set L/R pan location (-1..1)
    
    4    => lpf.Q;
    0.12 => lpf.gain;
    
    midiMsg => midi.getVelocity => chPressListener.setNormalizedInput; // set chPressListener inputValue to note velocity (as initial value, before channelPressure msgs start)
    chPressListener.mapValueToRangeOf("lowpassFilterCutoff") => lpf.freq; // set cutoff to above inputValue, mapped over the range for lpFilterCutoff provided in the param dict
    
    env.time(0.001); // attack time
    env.keyOn();     // start attack portion of note envelope
    
    // get notenum
    midiMsg => midi.getNotenum => int notenum;
    
    // get octave
    notenum/12 $ int => int octave;
    
    // compute frequency 
    (tuning[notenum%12]*baseFreq)*Math.pow(2, octave-3) => float freq;
    
    // compute corrected delay length and corresponding duration
    correctedDelay(freq) => float delayLength;   // in samples
    (delayLength / fs)::second => dur delayTime; // in seconds
    
    .999993 => float radius;  // radius
    
    Math.pow(radius, delayLength) => delay.gain; // set dissipation factor
    -1 => lowpass.zero;       // place zero
    
    delayTime => delay.delay; // set the KS delay period
    1 => imp.gain;            // fire excitation at particular gain value
    delayTime => now;         // for one delay round trip
    0 => imp.gain;            // cease fire
    
    <<< "notenum:", notenum, " ratio:", tuning[notenum%12], " freq:", freq >>>;
    //<<< "gain: ", tuning[12] >>>;
    
    spork ~ beginReleaseForNoteOff(noteOffListener, env); // spork a shred waiting on a noteOff event to release envelope
    spork ~ updateFilterCutoff(chPressListener, lpf);     // spork a shred monitoring a stream of incoming channelPressure messages to adjust filter cutoff
    
    noteOffListener => now; // wait on noteOff event before continuing the rest of this routine
    
    maxJitterize(get("release","time"), get("release","jitter")) => float maxJitReleaseTime; // get maximum releaseTime of any jitterize() operation
    
    (maxJitReleaseTime+0.010)::second => now; // advance time until after the note envelope is sure to be fully released
}

fun void playSineNote(Event noteOffListener, MidiMsg midiMsg, float tuning[]) 
{
    SinOsc s => Envelope env => JCRev r => dac;
    
    .5 => s.gain;  // set default gain value
    .1 => r.mix;
    
    midiMsg => midi.getNotenum => int noteNum;
    midiMsg => midi.getVelocity => int velocity;
    0.8 => float noteAmpMax;
    0.4 => float noteAmpMin;
    (noteAmpMax - noteAmpMin) + (velocity / 127.0) - noteAmpMin => float noteAmp; // compute noteAmp by mapping note velocity over min,max range
    
    noteNum/12 $ int => int octave; // get octave 
    (tuning[noteNum%12]*baseFreq)*Math.pow(2, octave-3) => float freq; // compute frequency from noteNum by mapping it to tuning
    
    env.time(0.01); // set time for attack segment
    env.keyOn();    // start the attack segment of note envelope
    
    freq => s.freq;               // set freq of sine
    s.gain() * noteAmp => s.gain; // scale default gain value by noteAmp (0.0 ... 1.0)
    
    noteOffListener => now;   // wait on noteOff event before continuing the rest of this routine
    
    0.0618 => float releaseTime;
    
    env.time(releaseTime); // set time for release segment
    env.keyOff();          // start the release segment of note envelope
    
    (releaseTime * 1.08)::second => now; // advance time until after note is fully released 
}


// for sporking from harmonicKarplus() shreds (i.e. currently playing notes), triggers release envelope when noteOff is received
fun void beginReleaseForNoteOff(Event noteOffListener, Envelope env) 
{
    noteOffListener => now; // wait on a noteOff event before continuing the rest of this routine
    
    jitterize(get("release","time"), get("release","jitter")) => float jitReleaseTime; // randomize releaseTime by releaseTimeJitter percent
    
    env.time(jitReleaseTime);  // set envelope time
    env.keyOff();              // begin releasing the envelope
    
    <<< "releaseTime:", get("release","time"), jitReleaseTime >>>;
    
    (jitReleaseTime+0.010)::second => now; // advance time until after the note envelope is fully released    
}

// for sporking from harmonicKarplus() shreds (i.e. currently playing notes), updates filter cutoff whenever a new channelPressure midiMsg is received
fun void updateFilterCutoff(MappedValueEvent chPressListener, LPF filter) 
{
    while (true) 
    {
        chPressListener => now; // wait on the next channelPressure midiMsg 
        
        if (chPressListener.inputValue > 0)
        {
            chPressListener.mapValueToRangeOf("lowpassFilterCutoff") => float cutoffFreq; // get cutoff freq value from transformed value of channelPressure midiMsg 
            cutoffFreq => filter.freq;                                                    // set filter cutoff 
            //<<< "chPress mapped to LPF freq:", cutoffFreq >>>; 
        } 
    }
}
// end funs for sporking
 
 
// number of the local midi device to open (do: 'chuck --probe' on command-line for device-list)
6 => int device;
// if used from command line with arg, then arg-value opens midi device instead
if( me.args() ) me.arg(0) => Std.atoi => device;

MidiIn midiInput; // the midi input event listener
MidiMsg midiMsg;  // the message for retrieving data

// open the device
if( !midiInput.open( device ) ) me.exit();

// print out device that was opened
<<< "midi device:", midiInput.num(), " -> ", midiInput.name() >>>;

// arrays of event-listeners
Event noteOffListeners[16];            // for automatically triggering the release stage of any sounding note when a noteOff is received on corresponding 'array-index' channel
MappedValueEvent chPressListeners[16]; // for tracking continuous velocity changes, via channelPressure messages received on corresponding 'array-index' channel

// main run loop
while( true )
{
    // wait on midiInput event 
    midiInput => now;
    
    // get the next incoming message
    while( midiInput.recv(midiMsg) )
    {
        // <<< midiMsg.data1, midiMsg.data2, midiMsg.data3 >>>;             // print raw midi message
        
        // when a noteOn is received 
        if (midiMsg => midi.isNoteOn)   
        {
            midiMsg => midi.getChannel => int noteOnChannel;                 // get midi-channel of the noteOn msg
            
            new Event() @=> Event newNoteOffListener;                       // create new listener for responding to noteOff events
            newNoteOffListener @=> noteOffListeners[noteOnChannel];         // store new noteOff listener at index given by the channel of this noteOn message
            
            new MappedValueEvent() @=> MappedValueEvent newChPressListener; // create new listener for responding to channelPressure events
            newChPressListener @=> chPressListeners[noteOnChannel];         // store new chPress listener at index given by the channel of this noteOn message         
                                                                
            0.0 => float panAmt; // set L/R pan amount (-1.0 ... 1.0)
            
            spork ~ harmonicKarplus(newNoteOffListener, newChPressListener, midiMsg, chromatic1, -panAmt); // play main note on its own thread
            spork ~ harmonicKarplus(newNoteOffListener, newChPressListener, midiMsg, chromatic2,  panAmt); // play doubled note on its own thread, with a slightly different tuning
            spork ~ playSineNote(newNoteOffListener, midiMsg, chromatic1);
            
            continue;
        }
        
        // when a noteOff is received
        if (midiMsg => midi.isNoteOff)
        {
            midiMsg => midi.getChannel => int noteOffChannel; // get midi-channel of the noteOff msg
            noteOffListeners[noteOffChannel].broadcast();    // notify all shreds listening for a noteOff event on this channel to release their currently-sounding note
            
            continue;
        }
        
        // when a channelPressure is received
        if (midiMsg => midi.isChanPress)
        {
            midiMsg => midi.getChannel => int pressureChannel;                                // get midi-channel of the ChannelPressure msg
            midiMsg => midi.getChanPress => chPressListeners[pressureChannel].setNormalizedInput; // update value within channelPressure listener for this channel
            chPressListeners[pressureChannel].broadcast();                                   // notify shreds waiting for channelPressure events on this channel, to read new value
            
            continue;
        }
        
    }
}