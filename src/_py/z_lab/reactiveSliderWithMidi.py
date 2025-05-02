import wx
from reactivex.subject import Subject
from reactivex import operators as ops
from pyo import Server
import rtmidi

MIDI_CC_NUMBER = 56  # The MIDI CC to listen for
MIDI_DEVICE    =  8  # '8' is often the Novation LaunchControl

class SliderFrame(wx.Frame):
    def __init__(self, subject, *args, **kw):
        super(SliderFrame, self).__init__(*args, **kw)

        self.slider_subject = subject

        self.slider = wx.Slider(self, value=50, minValue=0, maxValue=127,
                                style=wx.SL_HORIZONTAL | wx.SL_LABELS)

        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.slider, flag=wx.ALL | wx.EXPAND, border=10, proportion=1)
        self.SetSizer(sizer)

        self.slider.Bind(wx.EVT_SLIDER, self.on_slider_change)

        self.slider_subject.pipe(
            ops.distinct_until_changed()
        ).subscribe(
            on_next=self.update_slider_from_subject
        )

    def on_slider_change(self, event):
        value = self.slider.GetValue()
        self.slider_subject.on_next(value)

    def update_slider_from_subject(self, value):
        print(f"[GUI] RxPy pushed new value: {value}")
        wx.CallAfter(self._safe_update_slider, value)

    def _safe_update_slider(self, value):
        print(f"[GUI] Actually setting slider to {value}")
        if self.slider.GetValue() != value:
            self.slider.SetValue(value)

def start_rtmidi_listener(subject, midi_port_number, controller_number):
    midi_in = rtmidi.MidiIn()
    ports = midi_in.get_ports()

    if midi_port_number >= len(ports):
        print(f"[ERROR] Invalid MIDI port number {midi_port_number}. Available ports:")
        for i, name in enumerate(ports):
            print(f"  {i}: {name}")
        return

    midi_in.open_port(midi_port_number)
    print(f"[INFO] Listening to MIDI port: {ports[midi_port_number]}")

    def midi_callback(message_data, _):
        message, _timestamp = message_data
        if len(message) == 3:
            status, data1, data2 = message
            msg_type = status & 0xF0
            channel = status & 0x0F
            if msg_type == 0xB0 and data1 == controller_number:
                print(f"[RTMIDI] CC#{data1} on ch{channel+1} = {data2}")
                subject.on_next(data2)

    midi_in.set_callback(midi_callback)

    # Keep reference alive
    return midi_in

def main():
    # Create the subject
    midi_subject = Subject()

    # Boot Pyo server
    s = Server().boot()
    s.start()

    midi_in = start_rtmidi_listener(
        midi_subject, 
        midi_port_number=MIDI_DEVICE, 
        controller_number=MIDI_CC_NUMBER
    )

    # Set up GUI
    app = wx.App()
    frame = SliderFrame(midi_subject, None, title="MIDI Reactive Slider", size=(400, 100))
    frame.Show()
    app.MainLoop()

    # Cleanup
    s.stop()
    s.shutdown()

if __name__ == "__main__":
    main()

