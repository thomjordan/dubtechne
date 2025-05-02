import wx
import rtmidi
from wxVolumeControl import * 
from reactivex.subject import Subject
from reactivex import operators as ops
from typing import Protocol, TypeAlias

class Datasource(Protocol):
    """The Datasource type guarantees that the implementing object has a reactive 'subject' field"""
    subject: Subject

DatasourceDict: TypeAlias = dict[str, list[Datasource]] 

class MidiListenerService(Datasource):
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
    

class LaunchControlFrame(wx.Frame):
    def __init__(self, datasource: DatasourceDict, *args, **kw):
        super(LaunchControlFrame, self).__init__(*args, **kw)
        default_bgcolor = wx.Colour(42,40,37,255)
        self.SetBackgroundColour(default_bgcolor)
        
        self.datasource: DatasourceDict  = datasource
        self.controls = dict(knobs_top=[], knobs_mid=[], knobs_low=[], faders=[], buttons_top=[], buttons_low=[])
        
        def makeKnob(pos):
            knob = KnobCtrl(self,value=0.0,minValue=0.0,maxValue=127.0,size=(42,42),pos=pos,knobStyle=KNOB_DEPRESSION|KNOB_SHADOW)
            knob.SetThumbSize(18)
            knob.SetBackgroundColour(default_bgcolor)
            knob.SetPrimaryColour((33, 36, 60, 255))
            knob.SetSecondaryColour((225, 225, 225, 255))
            return knob
        
        def makeFader(pos):
            fader = wx.Slider(self,value=0,minValue=0,maxValue=127,style= wx.SL_VERTICAL|wx.SL_INVERSE|wx.SL_VALUE_LABEL)
            fader.SetSize((5,200))
            fader.SetPosition(pos)
            return fader
        
        def subscribe_and_bind(rowname:str, colnum:int):
            on_gui_control_change_handler   = self.create__on_gui_control_change__handler(rowname, colnum)
            update_gui_control_from_subject = self.create__update_gui_control_from_subject(rowname, colnum)

            self.controls[rowname][colnum].Bind(wx.EVT_SLIDER, on_gui_control_change_handler)

            self.datasource[rowname][colnum].subject.pipe(
                ops.distinct_until_changed()
            ).subscribe( on_next=update_gui_control_from_subject )

        # create gui controls and add them to the controls dictionary
        for index in range(0,8):
            top_knob =  makeKnob(pos=(60*index+17, 20))  
            mid_knob =  makeKnob(pos=(60*index+17, 78))  
            low_knob =  makeKnob(pos=(60*index+17,136))  
            fader    = makeFader(pos=(60*index+35,200))
            self.controls["knobs_top"] += [top_knob]
            self.controls["knobs_mid"] += [mid_knob]
            self.controls["knobs_low"] += [low_knob]
            self.controls["faders"]    += [fader]  
            
        # bind items in controls dictionary to corresponding reactive-subjects in datasource dictionary
        for index in range(0,8):
            subscribe_and_bind("knobs_top", index)
            subscribe_and_bind("knobs_mid", index)
            subscribe_and_bind("knobs_low", index)
            subscribe_and_bind("faders",    index)


    def create__on_gui_control_change__handler(self, rowname:str, index):
        def on_gui_control_change(event):
            value = self.controls[rowname][index].GetValue()
            self.datasource[rowname][index].subject.on_next(value)
        return on_gui_control_change
    
    def create__update_gui_control_from_subject(self, rowname:str, index):
        def update_gui_control_from_subject(value):
            print(f"[GUI] RxPy pushed value {value}")
            wx.CallAfter(self.create__safe_update_gui_control(rowname, index), value)
        return update_gui_control_from_subject

    def create__safe_update_gui_control(self, rowname:str, index):
        def _safe_update_gui_control(value):
            print(f"[GUI] Setting {rowname}_{index+1} to {value}")
            if self.controls[rowname][index].GetValue() != value:
                self.controls[rowname][index].SetValue(value)
        return _safe_update_gui_control


midi_in_device = 8

def setup_listeners() -> DatasourceDict:
    listeners: DatasourceDict = dict(knobs_top=[], knobs_mid=[], knobs_low=[], faders=[], buttons_top=[], buttons_low=[])
    for cc in range(13, 21): listeners["knobs_top"] += [ MidiListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(29, 37): listeners["knobs_mid"] += [ MidiListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(49, 57): listeners["knobs_low"] += [ MidiListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(77, 85): listeners["faders"]    += [ MidiListenerService(device=midi_in_device, cc_num=cc) ]
    [listener.start() for listener in listeners["knobs_top"]]
    [listener.start() for listener in listeners["knobs_mid"]]
    [listener.start() for listener in listeners["knobs_low"]]
    [listener.start() for listener in listeners["faders"]]
    return listeners


def main():
    listeners = setup_listeners()

    # Set up GUI
    app = wx.App()
    frame = LaunchControlFrame(listeners, None, title="Novation LAUNCH CONTROL XL", size=(500, 500))
    frame.Show()
    app.MainLoop()


if __name__ == "__main__":
    main()
