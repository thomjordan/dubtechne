@import "sounds.ck"

SndBuf buf( sounds.get("vox", 0) ) => FFT fft => blackhole;
IFFT ifft => blackhole;
Impulse imp => dac;

5 => float factor;

Math.pow(2,13)$int => int fftSize;
fftSize => int winSize;
fftSize => fft.size;

winSize/4 => int sHop;
(sHop$float/factor) $ int => int aHop;

Windowing.hann(winSize) @=> float window[];
//Windowing.hamming(winSize) @=> float window[];
//Windowing.blackmanHarris(winSize) @=> float window[];
//Windowing.rectangle(winSize) @=> float window[];
//Windowing.triangle(winSize) @=> float window[];
//window =>  fft.window;

window => ifft.window;

buf.samples() / aHop  => int numWin;
numWin*sHop + winSize => int outLen;

fftSize/2 => int numBins;

float signalOut[outLen]; // init an array of outLen number of zeros

2*Math.pi => float TWO_PI;

makeCenterFreqArray(numBins, (TWO_PI*aHop)/fftSize) @=> float CENTERFREQ[];
//<<< "CENTERFREQ[] :" >>>;
//for( float x : CENTERFREQ) <<< x >>>; 

1 => int first;
0 => int posIn => int posOut;

// for storing calculated results
float mag[numBins], pha[numBins], phaSy[numBins], oldPha[numBins], oldPhaSy[numBins], dphi[numBins], freq[numBins], yOut[winSize];
complex X[numBins], Y[numBins];

for(0 => int winNum; winNum < numWin; winNum++)
{
    if(first)
    {
        getAudioSegment(buf, 0, winSize) @=> float framebuf[]; 
        for(0 => int i; i < winSize; i++) framebuf[i] * window[i] => framebuf[i]; // apply window
        fft.transform(framebuf); 
        fft.spectrum(X);
        
        for(0 => int i; i < numBins; i++)
        {
            (X[i]$polar).mag   =>   mag[i];
            (X[i]$polar).phase =>   pha[i];
            (X[i]$polar).phase => phaSy[i]; // phaSy equals pha here, to start
        }
        
        0 => first;
    }
    
    else 
    {
        getAudioSegment(buf, posIn, posIn+winSize) @=> float framebuf[];
        for(0 => int i; i < winSize; i++) framebuf[i] * window[i] => framebuf[i]; // apply window
        fft.transform(framebuf);
        fft.spectrum(X);
        
        float phaseDiff[numBins];
        
        for(0 => int i; i < numBins; i++)
        {
            (X[i]$polar).mag   => mag[i];
            (X[i]$polar).phase => pha[i];
            
            pha[i] - oldPha[i] => phaseDiff[i];                                 // difference between the current & previous phase
            phaseDiff[i] - CENTERFREQ[i] => phaseDiff[i];                       // expected phase (unwrapped phase)
            phaseDiff[i] - TWO_PI * Math.round(phaseDiff[i]/TWO_PI) => dphi[i]; // principal argument, map phase to +/- pi
            (CENTERFREQ[i] + dphi[i]) / (aHop$float) => freq[i];                // true frequency
            oldPhaSy[i] + (sHop$float) * freq[i] => phaSy[i];                   // phase synthesis
        }  
    }
    
    for(0 => int i; i < Y.size(); i++)
        mag[i] * #( Math.cos(phaSy[i]), Math.sin(phaSy[i]) ) => Y[i];  // resynthesis
    
    ifft.transform(Y);  // manually perform the ifft
    ifft.samples(yOut); // get resulting time-domain signal segment for this window-frame
    
    posIn + aHop => posIn;
    
    for(0 => int i; i < winSize; i++) 
        signalOut[posOut+i] + yOut[i] => signalOut[posOut+i];  // overlap and add
  
    for(0 => int i; i < numBins; i++) 
    {
          pha[i] => oldPha[i];
        phaSy[i] => oldPhaSy[i];
    }
    
    // for(0 => int i; i < signalOut.size(); i++) Math.random2f(-0.5, 0.5) => signalOut[i]; 
    
     posIn + aHop => posIn;
    posOut + sHop => posOut; 
    
    ((sHop$float)/Math.pow(2,10))::samp => now;
}

spork ~ playSignalAsImptrain2(signalOut);
10::second => now;

//for( complex bin : X ) <<< bin >>>;

fun void playSignalAsImptrain(float signal[])
{
    for(0 => int i; i < signal.size(); i++) 
    {
        signal[i] => imp.next;
        0.5::samp => now;
    }
    
    SndBuf buf( sounds.get("vox", 0) ) => dac;
    5::second => now;
}

fun void playSignalAsImptrain2(float signal[])
{
    for(0 => int i; i < signal.size()/2; i++) 
    {
        signal[i*2] => imp.next;
        1::samp => now;
    }
    
    SndBuf buf( sounds.get("vox", 0) ) => dac;
    5::second => now;
}


fun float[] makeCenterFreqArray(int size, float scalar)
{
    float result[0];
    
    
    0 => int offset;
    
    //for(size => int i; i < (size*2); i++)
    for(offset => int i; i < size+offset; i++) 
        result << (i$float * scalar);
    
    return result;
}


fun float[] getAudioSegment(SndBuf sndbuf, int startPos, int size)
{
    float segment[size]; // init array with all zeros
    
    if(startPos > sndbuf.samples()) // if we're trying to start past the end of the buffer..
        return segment;             // ..then return an array of all zeros
    
    // if there's not enough left in buffer to read <size> values without going past the end of the buffer..
    if(startPos+size > sndbuf.samples())   
        size - (startPos+size - sndbuf.samples()) => size;  // ..then make <size> be just long enough to get the rest
        
    // get sample values; if <size> here is less than the original size (passed in as an arg)..
    // ..then the remainder of the segment contains zeros
    for(0 => int i; i < size; i++)               
        sndbuf.valueAt(startPos+i) => segment[i];
    
    return segment; 
}
