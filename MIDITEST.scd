MIDIClient.init;
MIDIClient.destinations;
MIDIClient.destinations[1];
m = MIDIOut(1);
m.noteOn(0, 60);
m.noteOn(1, 60);
m.noteOff(0, 60);
m.noteOff(1, 60);