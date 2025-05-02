1.6180339888  => float phi;
100 => float basetick;

basetick / 3 * pi / 4    +  basetick / 3 * 2  => float _pi6;
basetick / 3 / pi        +  basetick / 3 * 2  => float _pi5;
basetick / 3 * pi / 4    +  basetick / 3      => float _pi4;
basetick / 3 / pi        +  basetick / 3      => float _pi3;
basetick / 3 * pi / 4                         => float _pi2;
basetick / 3 / pi                             => float _pi1;

basetick / 2 * pi / 4    +  basetick / 2      => float pi6_;
basetick * pi / 4                             => float pi5_;     
basetick / 2 / pi        +  basetick / 2      => float pi4_;
basetick / 2 * pi / 4                         => float pi3_;
basetick / pi                                 => float pi2_;
basetick / 2 / pi                             => float pi1_;
       
basetick / 3 / phi       +  basetick / 3 * 2  => float _phi6;
basetick / 3 / phi / phi +  basetick / 3 * 2  => float _phi5;
basetick / 3 / phi       +  basetick / 3      => float _phi4;
basetick / 3 / phi / phi +  basetick / 3      => float _phi3;
basetick / 3 / phi                            => float _phi2;
basetick / 3 / phi / phi                      => float _phi1;
      
basetick / 2 * phi                            => float phi6_;
basetick / 2 / phi / phi +  basetick / 2      => float phi5_;
basetick     / phi                            => float phi4_;
basetick     / phi / phi                      => float phi3_;
basetick / 2 / phi                            => float phi2_;
basetick / 2 / phi / phi                      => float phi1_;
   
<<< "-----------------------------" >>>;
<<< "_pi6", _pi6, "pi6_", pi6_ >>>;
<<< "_pi5", _pi5, "pi5_", pi5_ >>>;
<<< "_pi4", _pi4, "pi4_", pi4_ >>>;
<<< "_pi3", _pi3, "pi3_", pi3_ >>>;
<<< "_pi2", _pi2, "pi2_", pi2_ >>>;
<<< "_pi1", _pi1, "pi1_", pi1_ >>>;
<<< "-----------------------------" >>>;
<<< "_phi6", _phi6, "phi6_", phi6_ >>>;
<<< "_phi5", _phi5, "phi5_", phi5_ >>>;
<<< "_phi4", _phi4, "phi4_", phi4_ >>>;
<<< "_phi3", _phi3, "phi3_", phi3_ >>>;
<<< "_phi2", _phi2, "phi2_", phi2_ >>>;
<<< "_phi1", _phi1, "phi1_", phi1_ >>>;
<<< "-----------------------------" >>>;

96. => global float bpm;
15000::ms / bpm => dur sixteenth; // 16th-note pulse @ 96 bpm
sixteenth * 4 => dur beat;
sixteenth * 2 => dur eighth;
beat * 8 => dur twoBars;
     
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

