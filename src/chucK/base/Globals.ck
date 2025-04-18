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
