public class Transport extends Object
{
      0 => static int  isPlaying;   // set default state to stopped
    now => static time timeOfStart;
    static Event playStateChanged; 
    
    120.0 => static float tempo;         // set default tempo
    500::ms => static dur beatDuration;  // set beat duration to default tempo
    beatDuration/24.0 => static dur clockPulseDur; // set midi-clock pulse duration to default tempo
    
    beatsToDur(4.0) => static dur launchQuant; // beat resolution for starting new phrases (if the transport is already running)
    
    fun static void start() 
    {   
        if(!isPlaying) // if transport isn't already playing...
        {
            1 => isPlaying; 
            now => timeOfStart; 
            playStateChanged.broadcast(); 
            printTimeOfStart();
        }
    }
    fun static void stop() 
    {   
        if(isPlaying) // if transport isn't already stopped...
        {
            0 => isPlaying;                     
            playStateChanged.broadcast(); 
        }
    }
    
    fun static void setTempo(float bpm) {
        bpm => tempo;
        (60000.0 / bpm)::ms => beatDuration;
        beatDuration/24.0 => clockPulseDur;
    }
    
    fun static dur beatsToDur(float timeInBeats) { return timeInBeats * beatDuration; }
    
    fun static void printTimeOfStart() { 
        if(isPlaying) <<< "time of transport start:", timeOfStart >>>; 
        else <<< "transport not playing" >>>;
    }
}

public class T extends Transport { }

Transport.printTimeOfStart();

3::second => now;

Transport.start();

now - Transport.timeOfStart => dur timeElapsedSinceTransportStarted;
Transport.launchQuant => dur LQ;
LQ - (timeElapsedSinceTransportStarted % LQ) => dur syncOffset;
syncOffset => now;

<<< "timeElapsedSinceTransportStarted: ", timeElapsedSinceTransportStarted >>>;
<<< "launchQuant: ", LQ >>>;
<<< " syncOffset: ", syncOffset >>>; 

T.printTimeOfStart();
Transport.printTimeOfStart();