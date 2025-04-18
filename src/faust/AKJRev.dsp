declare name "AKJRev";
declare author "Aaron Krister Johnson";
declare about "AKJRev is a reverb modeled after reverbsc in csound by Sean Costello. It utilizes his approach of mixing several delays whose lengths are some prime number of samples.";

import("stdfaust.lib");

smear_delay(del,modfactor) =
  _ : de.sdelay(MAXDELAY,IT,del_len)
with {
  MAXDELAY =  4096;
  IT       =  1024;
  del_len  =  del + del_mod;
  del_mod  =  no.noise : ba.sAndH(ba.pulse(14000)) : ba.line(14000)
              : _*(del*modfactor);
};
     
akjrev(cutoff,feedback)
  = (si.bus(2*N) :> si.bus(N) : delaylines(N)) ~
    (delayfilters(N,cutoff,feedback) : feedbackmatrix(N))
with {
  N = 16;
  MAXDELAY = 4096;
  delays = (1949,2081,2209,2339,2447,2617,2719,2843,2999,3163,3301,3433,3547,3677,3823,3967);
  delayval(i) = ba.take(i+1,delays);
  delaylines(N) = par(i,N,(smear_delay(delayval(i),0.000)));  // 0.0004
  delayfilters(N,cutoff,feedback) = par(i,N,filter(i,cutoff,feedback));
  feedbackmatrix(N) = bhadamard(N);
  bhadamard(2) = si.bus(2) <: +,-;
  bhadamard(n) = si.bus(n) <: (si.bus(n):>si.bus(n/2)) , ((si.bus(n/2),(si.bus(n/2):par(i,n/2,*(-1)))) :> si.bus(n/2))
                 : (bhadamard(n/2) , bhadamard(n/2));
  filter(i,cutoff,feedback) = fi.lowpass(1,cutoff) : *(feedback)
                              :> /(sqrt(N)) : _;
};

cutoff   = nentry("cutoff",5000,500,12000,0.01);
feedback = nentry("feedback",0.7,0,1,0.01);
wet      = nentry("wet",0.5,0,1,0.01);

process = _,_ <: ef.dryWetMixerConstantPower(wet*0.9, akjrev(cutoff,feedback)) :> _,_;
