import wx
import rtmidi
from wxVolumeControl import * 
from reactivex.subject import Subject
from reactivex import operators as ops
from typing import Protocol, TypeAlias
from collections import namedtuple

class Datasource(Protocol):
    """The Datasource type guarantees that the implementing object has a reactive 'subject' field"""
    subject: Subject

DatasourceDict: TypeAlias = dict[str, list[Datasource]] 

class MidiCCListenerService(Datasource):
    def __init__(self, device: int, cc_num: int):
        # Subject() is an object that is both an observable sequence as well as an observer,
        #   where each notification is broadcasted to all subscribed observers.
        self.subject = Subject()
        self.device  = device
        self.cc_num  = cc_num
        self.midi_in = rtmidi.MidiIn()
        self.devices = self.midi_in.get_ports()
        self.midi_in.set_callback(self.midi_callback)

    def start(self):
        if self.device >= len(self.devices):
            print(f"[ERROR] Invalid MIDI device number {self.device}. Available devices:")
            for i, name in enumerate(self.devices):
                print(f"  {i}: {name}")
            return
        self.midi_in.open_port(self.device)
        print(f"[INFO] Listening to MIDI port: {self.devices[self.device]}")
        
    def midi_callback(self, message_data, _):
        message, _timestamp = message_data
        if len(message) == 3:
            status, data1, data2 = message
            msg_type = status & 0xF0
            channel = status & 0x0F
            if msg_type == 0xB0 and data1 == self.cc_num:
                print(f"[RTMIDI] CC#{data1} on ch{channel+1} = {data2}")
                self.subject.on_next(data2) # notifies all subscribed observers with the value

class MidiNoteButtonListenerService(Datasource):
    def __init__(self, device: int, notenum: int, isToggle:int=False):
        self.toggle_on = 0 # only relevant when input arg isToggle=True
        # Subject() is an object that is both an observable sequence as well as an observer,
        #   where each notification is broadcasted to all subscribed observers.
        self.subject = Subject()
        self.device  = device
        self.notenum = notenum
        self.midi_in = rtmidi.MidiIn()
        self.devices = self.midi_in.get_ports()
        if isToggle:
            self.midi_in.set_callback(self.midi_callback_toggle)
        else:
            self.midi_in.set_callback(self.midi_callback_momentary)

    def start(self):
        if self.device >= len(self.devices):
            print(f"[ERROR] Invalid MIDI device number {self.device}. Available devices:")
            for i, name in enumerate(self.devices):
                print(f"  {i}: {name}")
            return
        self.midi_in.open_port(self.device)
        print(f"[INFO] Listening to MIDI port: {self.devices[self.device]}")
        
    def midi_callback_momentary(self, message_data, _):
        message, _timestamp = message_data
        if len(message) == 3:
            status, data1, data2 = message
            msg_type = status & 0xF0
            channel = status & 0x0F
            # if msg is a noteOn
            if msg_type == 0x90 and data1 == self.notenum:
                print(f"[RTMIDI] NoteOn received for note#{data1} on ch{channel+1}. ")
                self.subject.on_next(1) # notifies all subscribed observers with the value
            # else if msg is a noteOff
            elif msg_type == 0x80 and data1 == self.notenum:
                print(f"[RTMIDI] NoteOff received for note#{data1} on ch{channel+1}. ")
                self.subject.on_next(0) # notifies all subscribed observers with the value

    def midi_callback_toggle(self, message_data, _):
        message, _timestamp = message_data
        if len(message) == 3:
            status, data1, data2 = message
            msg_type = status & 0xF0
            channel = status & 0x0F
            # if msg is a noteOn, toggle local state and send out new state
            if msg_type == 0x90 and data1 == self.notenum:
                self.toggle_on = 0 if self.toggle_on else 1 
                local_state = "ON" if self.toggle_on else "OFF"
                print(f"[RTMIDI] NoteOn received for note#{data1} on ch{channel+1}. Toggling local state to {local_state}")
                self.subject.on_next(self.toggle_on) # notifies all subscribed observers with the value

    
UIWithReadout = namedtuple('UIWithReadout', ['UI', 'readout'])


class LaunchControlFrame(wx.Frame):
    def __init__(self, datasource: DatasourceDict, *args, **kw):
        super(LaunchControlFrame, self).__init__(*args, **kw)
        self.image_path = '/Users/artspace/Development/dubtechne/dubtechne/src/_py/z_lab/novationLaunchControlXLpic.jpg'
        #self.Bind(wx.EVT_PAINT, self.on_paint) 

        default_bgcolor = wx.Colour(42,40,37,255)
        self.SetBackgroundColour(default_bgcolor)
        
        self.datasource: DatasourceDict  = datasource
        self.controls = dict(knobs_top=[], knobs_mid=[], knobs_low=[], faders=[], buttons_top=[], buttons_low=[])

        font = wx.Font(wx.FontInfo(8).FaceName("Futura"))
        fader_height = 136

        def makeKnob(pos):
            size = 54
            knob = KnobCtrl(self,value=0.0,minValue=0.0,maxValue=127.0,size=(size,size),pos=pos,knobStyle=KNOB_DEPRESSION|KNOB_SHADOW)
            knob.SetThumbSize(18)
            knob.SetBackgroundColour(default_bgcolor)
            knob.SetPrimaryColour((33, 36, 60, 255))
            knob.SetSecondaryColour((225, 225, 225, 255))
            numbox = wx.StaticText(self, size=(20,10), pos=(pos[0]+16,pos[1]+37), label='0', style=wx.ALIGN_CENTRE_HORIZONTAL)
            numbox.SetFont(font)
            return UIWithReadout(knob, numbox)
        
        def makeFader(pos):
            fader = wx.Slider(self,value=0,minValue=0,maxValue=127,style= wx.SL_VERTICAL|wx.SL_INVERSE)
            fader.SetSize((5,fader_height))
            fader.SetPosition(pos)
            numbox = wx.StaticText(self, size=(20,10), pos=(pos[0]-7,pos[1]+144), label='0', style=wx.ALIGN_CENTRE_HORIZONTAL)
            numbox.SetFont(font)
            return UIWithReadout(fader, numbox)
        
        def makeButton(pos):
            button = wx.Button(self,label='0')
            button.SetSize((40,10))
            button.SetPosition(pos)
            button.SetFont(font)
            return button
        
        # for knobs and faders
        def subscribe_and_bind(rowname:str, colnum:int, event_type):
            on_gui_control_change_handler   = self.create__on_gui_control_change__handler(rowname, colnum)
            update_gui_control_from_subject = self.create__update_gui_control_from_subject(rowname, colnum)

            self.controls[rowname][colnum].UI.Bind(event_type, on_gui_control_change_handler)

            self.datasource[rowname][colnum].subject.pipe(
                ops.distinct_until_changed()
            ).subscribe( on_next=update_gui_control_from_subject )

        # for buttons
        def subscribe_and_bind_button(rowname:str, colnum:int):
            on_gui_button_down_handler     = self.create__on_gui_button_down__handler(rowname, colnum)
            on_gui_button_up_handler       = self.create__on_gui_button_up__handler(rowname, colnum)
            update_gui_button_from_subject = self.create__update_gui_button_from_subject(rowname, colnum)

            self.controls[rowname][colnum].Bind(wx.EVT_LEFT_DOWN, on_gui_button_down_handler)
            self.controls[rowname][colnum].Bind(wx.EVT_LEFT_UP, on_gui_button_up_handler)

            self.datasource[rowname][colnum].subject.pipe(
                ops.distinct_until_changed()
            ).subscribe( on_next=update_gui_button_from_subject )

        # create gui controls and add them to the controls dictionary
        x_offset = 15; y_offset = 14; x_spacer = 47; y_spacer = 56
        for index in range(0,8):
            top_knob   =   makeKnob(pos=(x_spacer*index+x_offset, y_offset))  
            mid_knob   =   makeKnob(pos=(x_spacer*index+x_offset, y_offset+y_spacer))  
            low_knob   =   makeKnob(pos=(x_spacer*index+x_offset, y_offset+y_spacer*2))  
            fader      =  makeFader(pos=(x_spacer*index+38,188))
            top_button = makeButton(pos=(x_spacer*index+21,188+fader_height+42))
            low_button = makeButton(pos=(x_spacer*index+21,188+fader_height+67))
            self.controls["knobs_top"]   += [top_knob]
            self.controls["knobs_mid"]   += [mid_knob]
            self.controls["knobs_low"]   += [low_knob]
            self.controls["faders"]      += [fader]  
            self.controls["buttons_top"] += [top_button] 
            self.controls["buttons_low"] += [low_button] 

        # bind items in controls dictionary to corresponding reactive-subjects in datasource dictionary
        for index in range(0,8):
            subscribe_and_bind("knobs_top", index, wx.EVT_SCROLL)
            subscribe_and_bind("knobs_mid", index, wx.EVT_SCROLL)
            subscribe_and_bind("knobs_low", index, wx.EVT_SCROLL)
            subscribe_and_bind(   "faders", index, wx.EVT_SLIDER)
            subscribe_and_bind_button("buttons_top", index)
            subscribe_and_bind_button("buttons_low", index)


    def on_paint(self, event):
        dc = wx.PaintDC(self)
        image = wx.Image(self.image_path, wx.BITMAP_TYPE_ANY)
        # Scale the image to fit the frame
        #image = image.Scale(self.GetSize().width, self.GetSize().height, wx.IMAGE_QUALITY_HIGH)
        bitmap = wx.Bitmap(image)
        dc.DrawBitmap(bitmap, 0, 0)

    # for knobs and faders
    def create__on_gui_control_change__handler(self, rowname:str, index):
        def on_gui_control_change(event):
            value = self.controls[rowname][index].UI.GetValue()
            self.datasource[rowname][index].subject.on_next(value)
            self.controls[rowname][index].readout.SetLabel(str(int(value)))
        return on_gui_control_change
    
    def create__update_gui_control_from_subject(self, rowname:str, index):
        def update_gui_control_from_subject(value):
            print(f"[GUI] RxPy pushed value {value}")
            wx.CallAfter(self.create__safe_update_gui_control(rowname, index), value)
        return update_gui_control_from_subject

    def create__safe_update_gui_control(self, rowname:str, index):
        def _safe_update_gui_control(value):
            print(f"[GUI] Setting {rowname}_{index+1} to {value}")
            if self.controls[rowname][index].UI.GetValue() != value:
                self.controls[rowname][index].UI.SetValue(value)
                self.controls[rowname][index].readout.SetLabel(str(value))
        return _safe_update_gui_control

    # for buttons
    def create__on_gui_button_down__handler(self, rowname:str, index):
        def on_gui_button_down(event):
            self.datasource[rowname][index].subject.on_next(1)
            self.controls[rowname][index].SetLabel('1')
        return on_gui_button_down
    
    def create__on_gui_button_up__handler(self, rowname:str, index):
        def on_gui_button_up(event):
            self.datasource[rowname][index].subject.on_next(0)
            self.controls[rowname][index].SetLabel('0')
        return on_gui_button_up
    
    def create__update_gui_button_from_subject(self, rowname:str, index):
        def update_gui_button_from_subject(value):
            print(f"[GUI] RxPy pushed value {value}")
            wx.CallAfter(self.create__safe_update_gui_button(rowname, index), value)
        return update_gui_button_from_subject

    def create__safe_update_gui_button(self, rowname:str, index):
        def _safe_update_gui_button(value):
            print(f"[GUI] Setting {rowname}_{index+1} to {value}")
            if self.controls[rowname][index].GetLabel() != str(value):
                self.controls[rowname][index].SetLabel(str(value))
        return _safe_update_gui_button


midi_in_device = 8


def setup_listeners() -> DatasourceDict:
    listeners: DatasourceDict = dict(knobs_top=[], knobs_mid=[], knobs_low=[], faders=[], buttons_top=[], buttons_low=[])
    for cc in range(13, 21): listeners["knobs_top"]   += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(29, 37): listeners["knobs_mid"]   += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(49, 57): listeners["knobs_low"]   += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(77, 85): listeners["faders"]      += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    for nn in range(41, 45): listeners["buttons_top"] += [ MidiNoteButtonListenerService(device=midi_in_device, notenum=nn) ]
    for nn in range(57, 61): listeners["buttons_top"] += [ MidiNoteButtonListenerService(device=midi_in_device, notenum=nn) ]
    for nn in range(73, 77): listeners["buttons_low"] += [ MidiNoteButtonListenerService(device=midi_in_device, notenum=nn) ]
    for nn in range(89, 93): listeners["buttons_low"] += [ MidiNoteButtonListenerService(device=midi_in_device, notenum=nn) ]
    [listener.start() for listener in listeners["knobs_top"]]
    [listener.start() for listener in listeners["knobs_mid"]]
    [listener.start() for listener in listeners["knobs_low"]]
    [listener.start() for listener in listeners["faders"]]
    [listener.start() for listener in listeners["buttons_top"]]
    [listener.start() for listener in listeners["buttons_low"]]
    return listeners


def main():
    listeners = setup_listeners()

    # Set up GUI
    app = wx.App()
    frame = LaunchControlFrame(listeners, None, title="Novation LAUNCH CONTROL XL", size=(411, 461), 
                               style=wx.DEFAULT_FRAME_STYLE & ~(wx.RESIZE_BORDER | wx.MAXIMIZE_BOX))
    frame.Show()
    app.MainLoop()


if __name__ == "__main__":
    main()
