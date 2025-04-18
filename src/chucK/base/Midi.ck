public class midi extends Object
{
    // midi message utilities
    0x90 => static int NOTE_ON_MASK;
    0x80 => static int NOTE_OFF_MASK;
    0xB0 => static int CONTROLLER_MASK;
    0xD0 => static int CHAN_PRESS_MASK;
    0xF0 => static int STATUS_MASK;
    0x0F => static int CHANNEL_MASK;
    
    fun static int isNoteOn(MidiMsg midiMsg)         { return (((midiMsg.data1 & STATUS_MASK) == NOTE_ON_MASK) && midiMsg.data3 > 0); } 
    fun static int isNoteOff(MidiMsg midiMsg)        { return ((midiMsg.data1 & STATUS_MASK) == NOTE_OFF_MASK) || (((midiMsg.data1 & STATUS_MASK) == NOTE_ON_MASK) && midiMsg.data3 == 0); }
    fun static int isChanPress(MidiMsg midiMsg)      { return (midiMsg.data1 & STATUS_MASK) == CHAN_PRESS_MASK; }
    fun static int isController(MidiMsg midiMsg)     { return (midiMsg.data1 & STATUS_MASK) == CONTROLLER_MASK; }
    
    fun static int getChannel(MidiMsg midiMsg)       { return midiMsg.data1 & CHANNEL_MASK; }
    fun static int getNotenum(MidiMsg midiMsg)       { return midiMsg.data2; }
    fun static int getVelocity(MidiMsg midiMsg)      { return midiMsg.data3; }
    fun static int getChanPress(MidiMsg midiMsg)     { return midiMsg.data2; }  
    fun static int getControllerNum(MidiMsg midiMsg) { return midiMsg.data2; }
    fun static int getControlValue(MidiMsg midiMsg)  { return midiMsg.data3; }
}