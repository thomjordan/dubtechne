// global parameters

public class g extends Object
{
    0 => static int masterTranspose;
    
    "samples" => static string soundsFolder;
    
    50. => static float swingAmount;
    
    [125::ms, 125::ms, 125::ms] @=> static dur swingValues[];
    
    static int controlToggles[8];
    
    fun static void initGlobalLimiter() {
        global Dyno dy => dac;
        dy.limit();       // set dynamics processor to default values for limiter functionality
        dy.ratio(10);     // sets slopeAbove to 1/arg
        dy.thresh(0.5);   // for all input-values above arg-value, slopeAbove kicks in to determine output-gain vs input-gain
        0.8 => dy.gain;   // compensate for the limiter's gain reduction
    }
    
    // generates an array a, where:
    //   a[0] is a duration with no swing (i.e. the input duration), 
    //   a[1] is the first value of a swing pair, and
    //   a[2] is the second value of the pair, where: a[1] + a[2] = a[0] + a[0]
    fun static void makeSwing(float percent, dur duration) {
        dur swingVals[0];
        swingVals << duration;
        swingVals << (percent / 100) * (duration * 2);
        swingVals << (1 - (percent / 100)) * (duration * 2);
        swingVals @=> swingValues;
        percent => swingAmount;
    }
}

public class t extends Object
{
    120.0 => static float tempo;              // set default tempo
    0.500::second => static dur beatDuration; // set beat duration to default tempo
    4 => static int launchQ; // the launch_quantize window size in beats
    launchQ => beatsToDur => static dur syncPeriod; // the launch_quantize window size in ms

    // VM start time in number_of_samples_since_1/1/1970
    // ...gets filled in by chucKShell.py
    0.0 => static float startTime; 

    fun static void setTempo(float bpm) {
        bpm => tempo;
        (60.0 / bpm)::second => beatDuration; // update for new tempo
        launchQ => beatsToDur => syncPeriod;  //
    }

    // for setting both tempo & LQ window size in one call
    fun static void setTempo(float bpm, int numbeats) {
        bpm => tempo;
        numbeats => launchQ;
        (60.0 / bpm)::second => beatDuration; // update for new tempo
        launchQ => beatsToDur => syncPeriod;  // update for new tempo & LQ window size
    }

    // setTempo() for when bpm is supplied as an int
    fun static void setTempo(int bpm) { setTempo(bpm$float); }
    fun static void setTempo(int bpm, int numbeats) { setTempo(bpm$float, numbeats); }

    // sets launchQ (launch quantization window size) to new value in number of beats
    fun static void setLaunchQ(int numbeats) {
        numbeats => launchQ;
        launchQ => beatsToDur => syncPeriod; // update for new LQ window size
    }
    
    // calculates a duration in seconds for number_of_beats input value
    fun static dur beatsToDur(float numbeats) { return numbeats * beatDuration; }
    fun static dur beatsToDur(int numbeats) { return numbeats$float * beatDuration; }

    // returns 'now' in terms of the number of samples since 1/1/1970
    fun static time getEpicNow() {
        return startTime::samp + now; 
    }

    // calculates the time duration until the next launch_quantize sync boundary
    fun static dur timeUntilNextSync() {
        return syncPeriod - (getEpicNow() % syncPeriod);
    }

    // calculates duration for input value divisor:
    // th(8): eighth note
    // th(16): sixteenth note
    // th(12): eight note triplet, etc.
    fun static dur th(int durtype) {
        beatDuration * 4 => dur wholeNote;
        wholeNote / (durtype$float) => dur result;
        return result;
    }
    // ... in case input value is a float
    fun static dur th(float durtype) {
        beatDuration * 4 => dur wholeNote;
        wholeNote / durtype => dur result;
        return result;
    }
}