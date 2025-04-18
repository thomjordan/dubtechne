@import "sounds"
@import "midi"
@import "globals"        // as 'g'
@import "launchControl"  // as 'lc'

g.initGlobalLimiter();

fun void runRhythm()
{
    // initialize values
    g.controlToggles[0] == 0;
    
    "hihat_closed/SOM/[4 4]" => string closed_hats;
    "hihat_open/SOM/[3 1]"   => string open_hats;
    "tamb_shake/SOM/[0 0]"   => string tambs_shakes;
    
    133.3333333333 => float bpm;
    64 => int numSounds; // number of randomly-selected sounds to load
    
    // create buffers and connect
    SndBuffE snd[numSounds];
    for( SndBuffE s : snd  ) s => global Dyno dy; 
    
    // synchronize to a bar in 4/4
    (240.0 / bpm)::second => dur T;
    T - (now % T) => now;
    
    [0, 0, 1, 0]  @=> int trigPattern[];
    //[10, 5, 6, 5] @=> int innerGroove[];
    [0, 5, 4, 5] @=> int innerGroove[];
    //[5, 6, 5, 10] @=> int outerGroove[];
    [0, 5, 4, 5] @=> int outerGroove[];
    
    2 => int numberOfUniqueValuesInPattern;
    64 => int sectionLength;
    32 => int numberOfSectionChanges;
    
    // load random sounds from specified folders 
    // each 'sound group' has one sound slot for each unique value in pattern
    for(0 => int i; i < numberOfUniqueValuesInPattern*numberOfSectionChanges; i++) 
    {
        if(i % numberOfUniqueValuesInPattern == 0)
            snd[i].buf.read( sounds.get(closed_hats) );
        else
            snd[i].buf.read( sounds.get(open_hats) );
    }
    
    // if a note is played, this must be subtracted from the next time advance (to keep in sync)
    //0::ms => dur compensation; 
    
    for(0 => int i; i < sectionLength * numberOfSectionChanges; i++)
    {
        0::ms => dur compensation;
        
        // get number of sound to trigger for this step
        i % trigPattern.size() => int currentStepOfPattern;
        trigPattern[currentStepOfPattern] => int soundSlotToPlay;
        
        i / sectionLength => int numberOfCurrentSection;
        numberOfCurrentSection * numberOfUniqueValuesInPattern => int soundGroupOffset;
        
        soundGroupOffset + soundSlotToPlay => int selection;
        
        // compute microtime shift for this step
        i % innerGroove.size() => int currentStepOfInnerGroove;
        (i / outerGroove.size()) % outerGroove.size() => int currentStepOfOuterGroove;
        
        innerGroove[currentStepOfInnerGroove]$float => float currentInnerGrooveValue;
        outerGroove[currentStepOfOuterGroove]$float => float currentOuterGrooveValue;
        
        1.5 => float innerGrooveAmt;
        0.0 => float outerGrooveAmt;
        
        (currentInnerGrooveValue * innerGrooveAmt)::ms => dur microtimeShift;
        (currentOuterGrooveValue * outerGrooveAmt)::ms +=>    microtimeShift;
        
        // delay by computed shift
        microtimeShift => now; 
        
        // play sound
        if(i % 4 == 0 && !g.controlToggles[0]) {
            snd[selection].play(1, 61.8, 0.5); 
            1::ms => compensation;
        }
        if(i % 4 == 1 && !g.controlToggles[0]) {
            snd[selection].play(1, 100, 0.25); 
            1::ms => compensation;
        }
        if(i % 4 == 2) {
            snd[selection].play(1, 261.8, 0.618); 
            1::ms => compensation;
        }
        if(i % 4 == 3 && !g.controlToggles[0]) {
            snd[selection].play(1, 100, 0.25);
            1::ms => compensation; 
        }
        
        // advance time by a sixteenth-note, minus microtime shift
        // also, take 1 ms back since it is uniformly added within the SndBuffE play() function 
        // (...to get envelope to function correctly)
        (60.0 / bpm / 4.0)::second - microtimeShift - compensation => now;  // advance time according to tempo
    }

}

class SndBuff extends Chugraph
{   
    SndBuf buf => 
    // Envelope env => 
    outlet;
    
    fun SndBuff() {
        buf.samples() => buf.pos; // set playhead to the end, so that snd doesn't automatically play when we advance time
    }
    
    fun play(float waitTime, float releaseTime) {
        0 => buf.pos; // set playhead to start
    }
}


class SndBuffE extends Chugraph
{   
    SndBuf buf => 
    Envelope env =>    
    outlet;
    
    fun SndBuff() {
        0 => env.time;
        buf.samples() => buf.pos; // set playhead to the end, so that snd doesn't automatically play when we advance time
    }
    
    fun play(float waitTime, float releaseTime, float gain) 
    {
        0 => env.time;
        gain => buf.gain;
        env.keyOn(1); // start envelope with no attack
        0 => buf.pos; // set playhead to start
        
        1::ms => now;                 // wait before starting release
        env.time(releaseTime/1000.0); // set env time before use
        env.keyOff(1);                // start release segment of envelope
        
        //spork ~ shreduleRelease(waitTime, releaseTime);
    }
    
    fun shreduleRelease(float waitTime, float releaseTime) // both args in milliseconds
    {
        waitTime::ms => now;          // wait before starting release
        env.time(releaseTime/1000.0); // set env time before use
        env.keyOff(1);                // start release segment of envelope
        (releaseTime+1)::ms => now;
    }
}


// number of the local midi device to open (do: 'chuck --probe' on command-line for device-list)
8 => int device; // LaunchControl

MidiIn midiInput; // the midi input event listener
MidiMsg midiMsg;  // the message for retrieving data

// open the device
if( !midiInput.open( device ) ) me.exit();

// print out device that was opened
<<< "midi device:", midiInput.num(), " -> ", midiInput.name() >>>;

Shred shredsInPlay[0];

// main run loop
while( true )
{
    // wait on midiInput event 
    midiInput => now;
    
    // get the next incoming message
    while( midiInput.recv(midiMsg) )
    {
        // if button1B is on, play sixteenth-notes
        if ((midiMsg => midi.isNoteOn) && (midi.getNotenum(midiMsg) == lc.buttonB1))  {
            1 => g.controlToggles[0];
            continue;
        }
        
        // if it's off, don't play them, leaving just the eighths
        if ((midiMsg => midi.isNoteOff) && (midi.getNotenum(midiMsg) == lc.buttonB1))  {
            0 => g.controlToggles[0];
            continue;
        }
        
        // launch a shred and store a reference to it
        if ((midiMsg => midi.isNoteOn) && (midi.getNotenum(midiMsg) == lc.buttonB8))  {
            shredsInPlay << (spork ~ runRhythm()); 
            continue;
        }
        
        // release all playing shreds launched from above, in LIFO order
        if ((midiMsg => midi.isNoteOn) && (midi.getNotenum(midiMsg) == lc.buttonA8))  {
            shredsInPlay.size() => int size;
            if(size > 0) {
                for(1 => int i; i <= size; i++ ) {
                    shredsInPlay[size-i] @=> Shred shred;
                    shred.exit();
                }
            }
            continue;
        }
    }
}

