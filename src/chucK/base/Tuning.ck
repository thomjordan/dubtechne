
float params[0][0];
"notes" => string notes;
"durs" => string durs;


[0.0] @=> params[notes];
[100.0, 200.0] @=> params[durs];

params[durs] << 300.0;

<<< tun.ratioToSemitones(3, 2) >>>;
<<< tun.semitonesToRatio( ratioToSemitones(3, 2) ) >>>;

public class tun extends Object
{
    // Tuning ratios for the 22 Shrutis
      1.0/1   => static float s0;
    256.0/243 => static float s1;
     16.0/15  => static float s2;
     10.0/9   => static float s3;
      9.0/8   => static float s4;
     32.0/27  => static float s5;
      6.0/5   => static float s6;
      5.0/4   => static float s7;
     81.0/64  => static float s8;
      4.0/3   => static float s9;
     27.0/20  => static float s10;
     45.0/32  => static float s11;
     64.0/45  => static float s12;
      3.0/2   => static float s13;
    128.0/81  => static float s14;
      8.0/5   => static float s15;
      5.0/3   => static float s16;
     27.0/16  => static float s17;
     16.0/9   => static float s18;
      9.0/5   => static float s19;
     15.0/8   => static float s20;
    243.0/128 => static float s21;
    
      1.0/1   => static float _tonic_;
    256.0/243 => static float _min2nd;
     16.0/15  => static float min2nd_;
     10.0/9   => static float _maj2nd;
      9.0/8   => static float maj2nd_;
     32.0/27  => static float _min3rd;
      6.0/5   => static float min3rd_;
      5.0/4   => static float _maj3rd;
     81.0/64  => static float maj3rd_;
      4.0/3   => static float perf4th;
     27.0/20  => static float larg4th;
     45.0/32  => static float augm4th;
     64.0/45  => static float dimn5th;
      3.0/2   => static float perf5th;
    128.0/81  => static float _min6th;
      8.0/5   => static float min6th_;
      5.0/3   => static float _maj6th;
     27.0/16  => static float maj6th_;
     16.0/9   => static float _min7th;
      9.0/5   => static float min7th_;
     15.0/8   => static float _maj7th;
    243.0/128 => static float maj7th_;
    
    [s0, s2, s4, s6, s7,  s9, s11, s13, s15, s16, s19, s20] @=> static float chromatic1[];
    [s0, s1, s3, s5, s8, s10, s12, s13, s14, s17, s18, s21] @=> static float chromatic2[];
    
    fun static float ratioToSemitones(int num, int denom) {
        return (1200.0 * Math.log2(num$float/denom$float)) / 100.0;
    }
    
    fun static float semitonesToRatio(float semitones) {
        return Math.pow(2, semitones * 100.0 / 1200.0);
    }  
}


