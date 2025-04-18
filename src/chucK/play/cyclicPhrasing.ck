@import "Transport.ck" 
@import "Globals.ck"

[0, 0, 0] @=> int phraseMutes[]; // a '1' disables note triggering for the corresponding running phrase. A '0' starts it again. 

OscIn oscInput; // create OSC receiver
OscMsg msg;     // create OSC message
4320 => oscInput.port; // specify receive port

// specify addresses to receive from
oscInput.addAddress( "/phrase" );
oscInput.addAddress( "/tempo" );
oscInput.addAddress( "/transport" );    
oscInput.addAddress( "/mute" );  


class PhraseLooper extends Object
{
    static Event LaunchQuantPulse; // global event for all phraseLoopers 
    
    4 => static int EVENT_WIDTH;
    3 => static int HEADER_SIZE;  
    
     -1 => int trackID;          // looper slot to play on, default of -1 means that
     -1 => int shredID;          // holds the shred ID num when shred is executing 
      0 => int phraseWasUpdated; // flag set to true (1) each time phrase data is updated via OSC
      0 => int phraseMute;       // flag that determines whether the eventList-scheduled shreds get sporked or skipped (0=sporked, 1=skipped)
      0 => int numEvents;        // provided in header of new phrase data received via OSC
    2.0 => float loopDuration;   // provided in header of new phrase data received via OSC
    
    float eventList[];
    
    fun void printEventList() { eventList @=> float e[]; for( 0 => int i; i < numEvents; i++ ) { <<< e[i*EVENT_WIDTH+0], e[i*EVENT_WIDTH+1], e[i*EVENT_WIDTH+2], e[i*EVENT_WIDTH+3] >>>; } }
    
    fun int getEventIndexForNextScheduledOnsetTime(float mostRecentlyPlayedOnsetTime)
    {   
        for( 0 => int eventNum; eventNum < numEvents; eventNum++ )
        {
            eventList[eventNum*EVENT_WIDTH] => float onsetTime; // get onset-time of next event in for loop (onset is the 0th entry in EVENT_WIDTH, so no additive offset is required here)
            
            // if this onsetTime is later-than or equal-to the most-recently played onset-time, 
            // return eventNum as index of where to start playing the new phrase data from 
            if(onsetTime > mostRecentlyPlayedOnsetTime) 
                return eventNum; 
        }
        
        // if there are no onset-times scheduled later than the mostRecentlyPlayedOnsetTime,
        return numEvents;  // then return 'numEvents' as an out-of-bounds eventNum
        // this will fail the condition of the caller's for-loop and break out of it, playing no new events until the phrase loops around
    }
}

// number of the local midi device to open (do: 'chuck --probe' on command-line for device-list)
8 => int device;  // LaunchControl

MidiIn midiInput; // the midi input event listener
MidiMsg midiMsg;  // the message for retrieving data

// open the device
if( !midiInput.open( device ) ) me.exit();

// print out device that was opened
<<< "midi device:", midiInput.num(), " -> ", midiInput.name() >>>;

// midi message utilities
0x90 => int NOTE_ON_MASK;
0x80 => int NOTE_OFF_MASK;
0xB0 => int CONTROLLER_MASK;
0xD0 => int CHAN_PRESS_MASK;
0xF0 => int STATUS_MASK;
0x0F => int CHANNEL_MASK;

fun int isNoteOn(MidiMsg midiMsg)        { return (((midiMsg.data1 & STATUS_MASK) == NOTE_ON_MASK) && midiMsg.data3 > 0); } 
fun int isNoteOff(MidiMsg midiMsg)       { return ((midiMsg.data1 & STATUS_MASK) == NOTE_OFF_MASK) || (((midiMsg.data1 & STATUS_MASK) == NOTE_ON_MASK) && midiMsg.data3 == 0); }
fun int isController(MidiMsg midiMsg)    { return (midiMsg.data1 & STATUS_MASK) == CONTROLLER_MASK; }
fun int isChanPress(MidiMsg midiMsg)     { return (midiMsg.data1 & STATUS_MASK) == CHAN_PRESS_MASK; }

fun int getMidiChannel(MidiMsg midiMsg)  { return midiMsg.data1 & CHANNEL_MASK; }
fun int getNotenum(MidiMsg midiMsg)      { return midiMsg.data2; }
fun int getVelocity(MidiMsg midiMsg)     { return midiMsg.data3; }
fun int getControlNum(MidiMsg midiMsg)   { return midiMsg.data2; }
fun int getControlValue(MidiMsg midiMsg) { return midiMsg.data3; }
fun int getChanPress(MidiMsg midiMsg)    { return midiMsg.data2; }

36 => int p1_basenote;
0  => int p1_modalTranspose; // for scale-stepwise real-time transposing via midi controller 
2  => int numTracks;
PhraseLooper looperTracks[numTracks];

spork ~ oscReceive();
spork ~ midiReceive();
spork ~ masterLooper(); 

fun void midiReceive()
{
    while( true )
    {
        // wait on midiInput event 
        midiInput => now;
        
        // get the next incoming message
        while (midiInput.recv(midiMsg))
        {   
            // when a control change message is received 
            if (midiMsg => isController)   
            {
                if (getControlNum(midiMsg) == 49)
                    getControlValue(midiMsg)/4 => p1_modalTranspose;    
            }
        }
    }  
}


fun void keepTracksInSync()
{
    now - Transport.timeOfStart => dur timeElapsedSinceTransportStarted;
    Transport.launchQuant => dur LQ;
    LQ - (timeElapsedSinceTransportStarted % LQ) => dur syncOffset;
    
    <<< "~ keepTracksInSync() ~ timeElapsedSinceTransportStarted: ", timeElapsedSinceTransportStarted >>>;
    <<< "~ keepTracksInSync() ~ syncOffset: ", syncOffset >>>; 
    
    while( true )
    {   // if no time has elapsed since the transport started (highly possible since the language is so strongly-timed)
        // ...don't wait until the next LQ grid boundary to broadcast the event, as we're already there
        //if(timeElapsedSinceTransportStarted == 0.0::samp) 
        //    PhraseLooper.LaunchQuantPulse.broadcast();
        //else syncOffset => now; // else wait until next LQ grid boundary 
        
        Transport.launchQuant => now;  
        PhraseLooper.LaunchQuantPulse.broadcast();
    }  
}

fun void masterLooper()
{
    Shred @ loopMasterSyncShred;
    
    while( true )
    {
        Transport.playStateChanged => now; // wait on change of transport state 
        
        if(Transport.isPlaying) // if transport state changed to playing
        {
            spork ~ keepTracksInSync() @=> loopMasterSyncShred; // start sync routine
            
            for(0 => int i; i < numTracks; i++)
            {
                spork ~ loopPhrase(looperTracks[i]) @=> Shred @ s;
                s.id() => looperTracks[i].shredID;
            }
        }
        
        else // if transport state changed to stopped
        {
            for(0 => int i; i < numTracks; i++)
            {
                if (looperTracks[i].shredID >= 0) // if shredID exists, shred is playing
                {
                    Machine.remove( looperTracks[i].shredID ); // stop shred
                    -1 => looperTracks[i].shredID;             // reset shredID to empty value
                }
            }
            
            Machine.remove(loopMasterSyncShred.id());
        }   
    }  
}

fun void oscReceive() 
{
    // main loop
    while( true )
    {   
        // wait on oscInput event
        oscInput => now;
        
        // grab the next message from the queue
        while( oscInput.recv(msg) )
        {     
            // check for address
            if( msg.address == "/phrase")
            {
                <<< "osc msg received at address:", msg.address >>>;
                <<< "osc msg numArgs:", msg.numArgs() >>>;
                
                msg.getInt(0) => int trackID;
                
                looperTracks[trackID] @=> PhraseLooper @ p; // assign reference of selected PhraseLooper to p
                
                // store metadata 
                trackID         => p.trackID; // only ever set the trackID here; this means that the track is now populated with phrase data and it should start scheduling the events in its eventList
                msg.getFloat(1) => p.loopDuration;
                msg.getInt(2)   => p.numEvents;
                
                p.numEvents * p.EVENT_WIDTH => int eventListSize;
                float evList[eventListSize];
                
                for( 0 => int i; i < eventListSize; i++ )
                    msg.getFloat(i + p.HEADER_SIZE) => evList[i]; // extract args for eventList by skipping over header
                
                evList @=> p.eventList;
                1 => p.phraseWasUpdated; 
                
                <<< "loopDuration:", p.loopDuration, "numEvents:", p.numEvents >>>;
                <<< "eventList:" >>>;
                
                p.printEventList();
                continue;
            }
            
            if( msg.address == "/tempo") 
            { 
                msg.getFloat(0) => Transport.setTempo; 
                continue;
            }
            
            if( msg.address == "/transport") 
            { 
                msg.getInt(0) => int transportShouldStart; 
                
                if(transportShouldStart) Transport.start();
                else Transport.stop();
                
                continue;
            }
            
            if( msg.address == "/mute") { 
                msg.getInt(0) => int trackID;                       // get which track to mute or unmute
                msg.getInt(1) => looperTracks[trackID].phraseMute;  // get the mute-state value and set the track's phraseMute field to it
                continue;
            }
            
            
        }
    }    
}

fun void loopPhrase(PhraseLooper p)
{
    <<< "loopPhrase() function called." >>>;
    
    float previousOnset;
    
    // this first loop ensures all tracks launching for the first time will do so at the next launch grid quantization boundary (besides the first one which starts immediately)
 //   while( true )
 //   { 
   //     if(p.trackID >= 0) // if the PhraseLooper on this track becomes populated with phrase data (if it has a valid trackID)
   //         break;         // then break out of this launch-grid-quantization pulse-loop and continue on to the event-scheduler loop below

        // if the PhraseLooper on this track doesn't have phrase data to schedule (if its trackID is the empty value (-1))...
        //  then wait on the next LaunchQuantPulse event
     //   PhraseLooper.LaunchQuantPulse => now;
               
   // } // end launchQuantPulse while loop
    
    //  when the PhraseLooper on this track has valid data to schedule, this second loop schedules the events
    while( true )
    {
        0.0 => previousOnset; // reset to zero before starting new loop of phrase
        
        for( 0 => int eventNum; eventNum < p.numEvents; eventNum++)
        {
            if(p.phraseWasUpdated && eventNum != 0) // eventNum = 0 at beginning of next pass; in this case any newly-updated phrase data will get scheduled correctly on its own
            {   // find first 'event-index' (array-index/p.EVENT_WIDTH) that is greater than 'previousOnset'
                // manually set eventNum to this value, so that it 'punches-in' to the newly received eventList at the correct place, chronologically speaking
                previousOnset => p.getEventIndexForNextScheduledOnsetTime => eventNum; // if eventNum <  p.numEvents, the for-loop will continue on from the soonest event whose onsetTime has yet to be reached
                0 => p.phraseWasUpdated; // reset flag                                    
                if( !(eventNum < p.numEvents) ) break;  // if eventNum >= p.numEvents, 'break' means that no further events will be played until phraseCycle loops around again
            }
        
            p.eventList[eventNum * p.EVENT_WIDTH + 0] => float onset;
            p.eventList[eventNum * p.EVENT_WIDTH + 1] => float notenum;
            p.eventList[eventNum * p.EVENT_WIDTH + 2] => float amplitude;
            p.eventList[eventNum * p.EVENT_WIDTH + 3] => float duration;
        
            onset - previousOnset => Transport.beatsToDur => dur durationToWait; // this equals 0.0 when the first event's onset value is 0.0
        
            durationToWait => now; // advance time before playing next event
        
            if(p.phraseMute == 0)  // if mute is off
                spork ~ playSineNote(notenum, amplitude, duration);
        
            onset => previousOnset; 
        }
    
        // now that all events in phrase have been played,
        //   advance time until end of phrase loop 
        p.loopDuration - previousOnset => Transport.beatsToDur => now;  
        
    }  // end event-scheduler while loop
} 


fun void playSineNote(float noteNum, float noteAmp, float noteDuration) 
{
    SinOsc s => Envelope env => JCRev r => dac;
    
    .5 => s.gain;  // set default gain value
    .1 => r.mix;
    
    env.time(0.01); // set time for attack segment
    env.keyOn();    // start the attack segment of note envelope
    
    [0, 2, 3, 7, 8, 10] @=> int majorNo4th[];
    noteNum $ int + p1_modalTranspose => int transposedNoteNum;
    transposedNoteNum/majorNo4th.size() $ int => int octave; // get octave
    majorNo4th[transposedNoteNum % majorNo4th.size()] + (12*octave) + p1_basenote + g.masterTranspose => int mappedNoteNum;
    
    mappedNoteNum => Std.mtof => s.freq;  // set freq of sine
    s.gain() * noteAmp => s.gain;         // scale default gain value by noteAmp (0.0 ... 1.0)
    
    noteDuration => Transport.beatsToDur => now;   // advance time by note-duration
    
    0.0618 => float releaseTime;
    
    env.time(releaseTime); // set time for release segment
    env.keyOff();          // start the release segment of note envelope
    
    releaseTime * 1.08 => Transport.beatsToDur => now; // advance time until after note is fully released 
}


21600::second => now; 