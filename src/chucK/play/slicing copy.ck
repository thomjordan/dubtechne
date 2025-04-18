@import "globals"       // as 'g'
@import "tuning"        // as 'tun'
@import "launchControl" // as 'lc'
@import "midi"

[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1 ] @=> int creativeSky[];
[ 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0 ] @=> int abysmalMoon[];
[ 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0 ] @=> int stillMountain[];
[ 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1 ] @=> int arousingThunder[];
[ 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0 ] @=> int gentleWind[];
[ 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1 ] @=> int clingingSun[];
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0 ] @=> int receptiveEarth[];
[ 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1 ] @=> int joyousLake[];

// weaves a new list by alternating between successive values from onbeats[] and offbeats[]
//   like: flatten(zip2(onbeats, offbeats))
fun int[] weave(int onbeats[], int offbeats[]) {
    int weaved[0];
    onbeats.size() => int length;
    if(offbeats.size() > length) offbeats.size() => length; // set length to the size of the largest list
    for(0 => int i; i < length; i++) 
       weaved << onbeats[i % onbeats.size()] << offbeats[i % offbeats.size()];
    return weaved;
}

// weaves a new list by alternating between successive values from onbeats[] and a reverse traversal of offbeats[]
//   like: flatten(zip2(onbeats, reversed(offbeats)))
fun int[] weaveFR(int onbeats[], int offbeats[]) {
    int weaved[0];
    onbeats.size() => int length;
    if(offbeats.size() > length) offbeats.size() => length; // set length to the size of the largest list
    for(0 => int i; i < length; i++) 
        weaved << onbeats[i % onbeats.size()] << offbeats[offbeats.size() - (i % offbeats.size()) - 1];
    return weaved;
}

// weaves a new list by alternating between successive values from onbeats[] and offbeats[], with offbeats[] starting from the midpoint of the list
//   like: flatten(zip2(onbeats, rotate(offbeats, offbeats.size()/2)))
fun int[] weave180(int onbeats[], int offbeats[]) {
    int weaved[0];
    onbeats.size() => int length;
    if(offbeats.size() > length) offbeats.size() => length; // set length to the size of the largest list
    for(0 => int i; i < length; i++) 
        weaved << onbeats[i % onbeats.size()] << offbeats[(i + offbeats.size()/2) % offbeats.size()]; // for offbeats[], start accessing elements from midpoint of list
    return weaved;
}

// weaves a new list by alternating between successive values from onbeats[] and offbeats[], with offbeats[] starting from the second-quarter of the list
//   like: flatten(zip2(onbeats, rotate(offbeats, offbeats.size()/4)))
fun int[] weave90(int onbeats[], int offbeats[]) {
    int weaved[0];
    onbeats.size() => int length;
    if(offbeats.size() > length) offbeats.size() => length; // set length to the size of the largest list
    for(0 => int i; i < length; i++) 
        weaved << onbeats[i % onbeats.size()] << offbeats[(i + offbeats.size()/4) % offbeats.size()]; // for offbeats[], start accessing elements from second-quarter of the list
    return weaved;
}

// weaves a new list by alternating between successive values from onbeats[] and offbeats[], with offbeats[] starting from the fourth-quarter of the list
//   like: flatten(zip2(onbeats, rotate(offbeats, 3*offbeats.size()/4)))
fun int[] weave270(int onbeats[], int offbeats[]) {
    int weaved[0];
    onbeats.size() => int length;
    if(offbeats.size() > length) offbeats.size() => length; // set length to the size of the largest list
    for(0 => int i; i < length; i++) 
        weaved << onbeats[i % onbeats.size()] << offbeats[(i + 3*offbeats.size()/4) % offbeats.size()]; // for offbeats[], start accessing elements from fourth-quarter of the list
    return weaved;
}

fun int[] makeSliceRepeaterList(int prefix[], int pattern[], int repeatsPerPatternStep, int suffix[]) {
    int result[0];
    for(int e: prefix) result << e;
    for(int step: pattern) repeat(repeatsPerPatternStep) result << step;
    for(int e: suffix) result << e;
    return result;
}

fun int[] makeSliceRepeaterList(int prefix[], int pattern[], int repeatsPerPatternStep, int truncateN) {
    int result[0];
    for(int e: prefix) result << e;
    for(int step: pattern) repeat(repeatsPerPatternStep) result << step;
    repeat(truncateN) result.popBack();
    return result;
}

fun int[] makeSliceRepeaterList(int prefix[], int pattern[], int repeatsPerPatternStep) {
    int result[0];
    for(int e: prefix) result << e;
    for(int step: pattern) repeat(repeatsPerPatternStep) result << step;
    return result;
}

fun int[] makeSliceRepeaterList(int pattern[], int repeatsPerPatternStep, int truncateN) {
    int result[0];
    for(int step: pattern) repeat(repeatsPerPatternStep) result << step;
    repeat(truncateN) result.popBack();
    return result;
}

fun int[] makeSliceRepeaterList(int pattern[], int repeatsPerPatternStep) {
    int result[0];
    for(int step: pattern) repeat(repeatsPerPatternStep) result << step;
    return result;
}

makeSliceRepeaterList([0], Std.range(1, 6), 3)    @=> int pattern16[];
makeSliceRepeaterList([0, 0], Std.range(1,11), 3) @=> int pattern32[];
makeSliceRepeaterList([0], Std.range(1,17), 3, 1) @=> int pattern48[];

fun int[] iterativeTranspose(int pattern[], int transposeAmt, int times) {
    int result[0];
    for(0 => int i; i < times; i++)
        for(int step: pattern) 
            { result << step + transposeAmt*i; }
    return result;
}

//<<< "pattern16:" >>>; for(int p: pattern16) <<< p >>>; <<< pattern16.size() >>>;
//<<< "pattern32:" >>>; for(int p: pattern32) <<< p >>>; <<< pattern32.size() >>>;
//<<< "pattern48:" >>>; for(int p: pattern48) <<< p >>>; <<< pattern48.size() >>>;

iterativeTranspose(pattern16, 8, 3) @=> int it3Pattern16[];
iterativeTranspose(pattern16, 8, 6) @=> int it6Pattern16[];

//<<< "it3Pattern16:" >>>; for(int p: it3Pattern16) <<< p >>>; <<< it3Pattern16.size() >>>;
//<<< "it6Pattern16:" >>>; for(int p: it6Pattern16) <<< p >>>; <<< it6Pattern16.size() >>>;

53.934466291663162 => float copperMeanish;
56.903559372884931 => float silverMeanish;
55.046260628866678 => float bronzeMeanish;
60.300566478845942 => float goldenMeanish;
57.2924            => float squarishGoldenMean;

me.dir() + "soundscapes/NGC_3982.wav" => string filename;

<<< filename >>>;

SndBuf2 NGC3925 
    => ADSR env 
    => Echo echoA[2] 
    => Echo echoB[2] 
    => AKJRev reverb
    => dac;
    
    
class EnvBuf extends Chugraph { 

    


}
    
filename => NGC3925.read;
stopCut();

12.0 => float startPosInSec;
44100.0 => float srate;
startPosInSec * srate => float startPosition;

96.0 => float sourceBPM;
30.0 / sourceBPM => float sourcePulse8; // 312.5 ms

// 'resolution' denotes the number of pulses (in this case 16th-notes) between consecutively-indexed slices
// this is effectively the smallest resolution used in calculating the sound buffer position, from the interaction of the slice-index pattern and realtime midi controller knob
//  i.e. 'slice 6' jumps to '6 * resolution' 16th-notes into the source material
5  => int resolution;

2048 => int totalNumberOf16thNotesInClipPlaybackArea;
 128 => int numberOfControllerValues;
totalNumberOf16thNotesInClipPlaybackArea / numberOfControllerValues => int maxControlStepWidth;
maxControlStepWidth / resolution => int effectiveControlStepWidth; 

totalNumberOf16thNotesInClipPlaybackArea / resolution => int totalNumberOfSlices;
320.0 * srate / totalNumberOfSlices$float => float sliceWidth; // slices are 312.5 ms each (8th-note @ 96 bpm), though 'slice' is in samples

0 => int sliceOffset; // this is changed by the midi controller lc.knobC8 ( [0..127] * 8

96.0 => float playBPM;
15.0::second / playBPM => dur _16th_;

g.makeSwing(copperMeanish, _16th_);

<<< "_16th_:", _16th_ >>>;

0.763970968 => float fullPercentMinusPhiN3;

<<< "tun._min6th", tun._min6th/2 >>>;
<<< "tun.min6th_", tun.min6th_/2 >>>;
<<< "tun._maj6th", tun._maj6th/2 >>>;
<<< "tun.maj6th_", tun.maj6th_/2 >>>;
<<< "tun._min7th", tun._min7th/2 >>>;

spork ~ handleMidi();

12.36 => float envDecayRandomizationPercentage;
(100.0 - (envDecayRandomizationPercentage / 2.0)) / 100.0 => float envDecayRandomMin;
(100.0 + (envDecayRandomizationPercentage / 2.0)) / 100.0 => float envDecayRandomMax;

<<< "envDecayRandomMin:", envDecayRandomMin >>>;
<<< "envDecayRandomMax:", envDecayRandomMax >>>;


0.618::ms => env.attackTime;
_16th_ * 1.618/2 => dur decayTime;
decayTime => env.decayTime;
0 => env.sustainLevel;
0 => env.releaseRate;

216.8 => float decayAmt; // percentage of duration of current step

<<< "decayTime:", decayTime / _16th_ >>>;

_16th_ * 2 => echoA[0].delay; 
_16th_ + g.swingValues[0] => echoA[1].delay; 

_16th_ * 2 => echoB[0].delay; 
_16th_ + g.swingValues[1] => echoB[1].delay;

0.382 => echoA[0].mix => echoA[1].mix;
0.5   => echoB[0].mix => echoB[1].mix;

1576. => reverb.cutoff;
0.490 => reverb.wet;
0.618 => reverb.feedback;
0.618 => NGC3925.gain;

fun void cueCut(int sliceChoice, int swingIndex) {
    g.swingValues[swingIndex] => dur duration;
    sliceWidth * (sliceChoice + sliceOffset)$float => float cuePosition;
    (startPosition + cuePosition)$int => NGC3925.pos;
    duration * decayAmt / 100.0 => dur durationOfDecay;
    durationOfDecay * Math.random2f(envDecayRandomMin, envDecayRandomMax) => env.decayTime;
    env.keyOn(1);
    duration * 0.996 => now;
    stopCut();
    duration * 0.004 => now;
    env.keyOff(1);
}

fun void cueRest(int swingIndex) {
    g.swingValues[swingIndex] => dur duration;
    stopCut(); 
    duration => now;
}

fun void stopCut() { NGC3925.samples() => NGC3925.pos; } // cue to end so sample doesn't immediately play

weaveFR(joyousLake, gentleWind) @=> int innerPeace[];
//<<< "innerPeace size:", innerPeace.size() >>>;
weave90(arousingThunder, stillMountain) @=> int nourishment[];
weave180(arousingThunder, arousingThunder) @=> int thunder[];

// returns a 90-degree rotated list.. analogous to the input list starting at its second-quarter
// inlist.size() should be evenly divisible by 4
fun int[] rotate90(int inlist[]) {
    int rotated[0];
    for(0 => int i; i < inlist.size(); i++)
        rotated << inlist[(i + inlist.size()/4) % inlist.size()];
    return rotated;
}

// returns a 180-degree rotated list.. analogous to the input list starting at its midpoint
// inlist.size() should be evenly divisible by 2
fun int[] rotate180(int inlist[]) {
    int rotated[0];
    for(0 => int i; i < inlist.size(); i++) 
        rotated << inlist[(i + inlist.size()/2) % inlist.size()];
    return rotated;
}

// returns a 270-degree rotated list.. analogous to the input list starting at its fourth-quarter
// inlist.size() should be evenly divisible by 4
fun int[] rotate270(int inlist[]) {
    int rotated[0];
    for(0 => int i; i < inlist.size(); i++) 
        rotated << inlist[(i + 3*inlist.size()/4) % inlist.size()];
    return rotated;
}

// returns a copy of the input list, with no rotation operation
// useful for "fully symmetric" labeling of operations
fun int[] rotate0(int inlist[]) {
    int result[0];
    for(0 => int i; i < inlist.size(); i++)
        result << inlist[i];
    return result;
}

// returns a copy of the input list, with no operation
// useful for "fully symmetric" labeling of operations
fun int[] forwards(int inlist[]) {
    int result[0];
    for(0 => int i; i < inlist.size(); i++)
        result << inlist[i];
    return result;
}

fun int[] reversed(int inlist[]) {
    int reversedList[0];
    for(0 => int i; i < inlist.size(); i++)
        reversedList << inlist[inlist.size() - i - 1];
    return reversedList;     
}

// three-bit binary numbers written in reverse 
// after listening to these, consider if rotate270 and rotate90 should be switched:
// [0] : 0 0 0 : forwards, rotate0
// [1] : 1 0 0 : forwards, rotate270
// [2] : 0 1 0 : reversed, rotate0
// [3] : 1 1 0 : reversed, rotate270
// [4] : 0 0 1 : forwards, rotate90
// [5] : 1 0 1 : forwards, rotate180
// [6] : 0 1 1 : reversed, rotate90
// [7] : 1 1 1 : reversed, rotate180

fun int[] transform8(int inlist[], int type) {
    if(type % 8 == 0) { inlist => forwards => rotate0   @=> int outlist[];  return outlist; }
    if(type % 8 == 1) { inlist => forwards => rotate270 @=> int outlist[];  return outlist; }
    if(type % 8 == 2) { inlist => reversed => rotate0   @=> int outlist[];  return outlist; }
    if(type % 8 == 3) { inlist => reversed => rotate270 @=> int outlist[];  return outlist; }
    if(type % 8 == 4) { inlist => forwards => rotate90  @=> int outlist[];  return outlist; }
    if(type % 8 == 5) { inlist => forwards => rotate180 @=> int outlist[];  return outlist; }
    if(type % 8 == 6) { inlist => reversed => rotate90  @=> int outlist[];  return outlist; }
    if(type % 8 == 7) { inlist => reversed => rotate180 @=> int outlist[];  return outlist; }
    return inlist; // this would only ever get called if type somehow was a negative value
}

fun int[] genGuaPattern(int lower[], int upper[], int lowerTransformType, int upperTransformType) {
    (lower, lowerTransformType) => transform8 @=> int lowerTransformed[];
    (upper, upperTransformType) => transform8 @=> int upperTransformed[];
    (lowerTransformed, upperTransformed) => weave @=> int result[];
    return result;
}

fun int randomOct() { 
    Math.random2(0,7) => int oct;
    <<< "randomOct:", oct >>>; 
    return oct; 
}

7 => int type1;
5 => int type2;
([1,2,3,4,5,6,7,8], [10,20,30,40,50,60,70,80], type1, type2) => genGuaPattern @=> int result[];
<<< "genGuaPattern() result for types", type1, type2, ":" >>>;
for( int r: result ) <<< r >>>;

//genGuaPattern(arousingThunder, stillMountain, randomOct(), randomOct()) @=> int nourishment1[];
//<<< "nourishment1.size():", nourishment1.size() >>>;
(joyousLake, gentleWind, randomOct(), randomOct()) => genGuaPattern @=> int joyousLakes[];
<<< "joyousLakes.size():", joyousLakes.size() >>>;


it6Pattern16 @=> int p1[]; // sequence of slice #'s (96 steps)
joyousLakes  @=> int m1[]; // stepwise mute pattern (96 steps)

625.0::ms / 4.0 => dur T;
(T*8.0) - (now % (T*8.0)) => now;

while(true) {
    for(0 => int i; i < p1.size(); i++) 
        if(m1[i]) cueCut(p1[i], (i%2)+1); // if current step isn't muted, play slice # at corresponding step
    else cueRest((i%2)+1);
}

fun void handleMidi() 
{
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
            if ((midiMsg => midi.isController) && (midi.getControllerNum(midiMsg) == lc.knobC8))  {
                midi.getControlValue(midiMsg) * effectiveControlStepWidth => sliceOffset;
                  <<< "sliceOffset:", sliceOffset >>>;
           }
       }
   }
}















