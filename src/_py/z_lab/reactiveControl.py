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
            fader.SetSize((5,136))
            fader.SetPosition(pos)
            numbox = wx.StaticText(self, size=(20,10), pos=(pos[0]-7,pos[1]+144), label='0', style=wx.ALIGN_CENTRE_HORIZONTAL)
            numbox.SetFont(font)
            return UIWithReadout(fader, numbox)
        
        def subscribe_and_bind(rowname:str, colnum:int, event_type):
            on_gui_control_change_handler   = self.create__on_gui_control_change__handler(rowname, colnum)
            update_gui_control_from_subject = self.create__update_gui_control_from_subject(rowname, colnum)

            self.controls[rowname][colnum].UI.Bind(event_type, on_gui_control_change_handler)

            self.datasource[rowname][colnum].subject.pipe(
                ops.distinct_until_changed()
            ).subscribe( on_next=update_gui_control_from_subject )

        # create gui controls and add them to the controls dictionary
        x_offset = 15; y_offset = 14; x_spacer = 47; y_spacer = 56
        for index in range(0,8):
            top_knob =  makeKnob(pos=(x_spacer*index+x_offset, y_offset))  
            mid_knob =  makeKnob(pos=(x_spacer*index+x_offset, y_offset+y_spacer))  
            low_knob =  makeKnob(pos=(x_spacer*index+x_offset, y_offset+y_spacer*2))  
            fader    = makeFader(pos=(x_spacer*index+38,188))
            self.controls["knobs_top"] += [top_knob]
            self.controls["knobs_mid"] += [mid_knob]
            self.controls["knobs_low"] += [low_knob]
            self.controls["faders"]    += [fader]  

        # bind items in controls dictionary to corresponding reactive-subjects in datasource dictionary
        for index in range(0,8):
            subscribe_and_bind("knobs_top", index, wx.EVT_SCROLL)
            subscribe_and_bind("knobs_mid", index, wx.EVT_SCROLL)
            subscribe_and_bind("knobs_low", index, wx.EVT_SCROLL)
            subscribe_and_bind(   "faders", index, wx.EVT_SLIDER)


    def on_paint(self, event):
        dc = wx.PaintDC(self)
        image = wx.Image(self.image_path, wx.BITMAP_TYPE_ANY)
        # Scale the image to fit the frame
        #image = image.Scale(self.GetSize().width, self.GetSize().height, wx.IMAGE_QUALITY_HIGH)
        bitmap = wx.Bitmap(image)
        dc.DrawBitmap(bitmap, 0, 0)

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


midi_in_device = 8

def setup_listeners() -> DatasourceDict:
    listeners: DatasourceDict = dict(knobs_top=[], knobs_mid=[], knobs_low=[], faders=[], buttons_top=[], buttons_low=[])
    for cc in range(13, 21): listeners["knobs_top"] += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(29, 37): listeners["knobs_mid"] += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(49, 57): listeners["knobs_low"] += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    for cc in range(77, 85): listeners["faders"]    += [ MidiCCListenerService(device=midi_in_device, cc_num=cc) ]
    [listener.start() for listener in listeners["knobs_top"]]
    [listener.start() for listener in listeners["knobs_mid"]]
    [listener.start() for listener in listeners["knobs_low"]]
    [listener.start() for listener in listeners["faders"]]
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
