MIDIClient.init;
// CHANGE THIS TO CONNECT
~midi = MIDIOut(1);

Ndef(\synthIn, {
	var sig = SoundIn.ar([0,1]).tanh;
	Out.ar(~vrb, sig*(-12.dbamp));
	sig;
}).play;

~seqA = [[0], [1]];
~seqB = [[0], [1]];
~scale = Scale.at(\dorian);
Tdef(\seqA, {
	var note;
	inf.do{|i|
		note = ~seqA[0][i % ~seqA[0].size] + (12 * 5);
		~midi.noteOn(0, note);
		~midi.noteOff(0, note);
		(~seqA[1][i % ~seqA[1].size] / 2).wait;
	};
});

Tdef(\seqB, {
	var note;
	inf.do{|i|
		note = ~seqB[0][i % ~seqB[0].size] + (12 * 5);
		~midi.noteOn(1, note);
		~midi.noteOff(1, note);
		(~seqB[1][i % ~seqB[1].size] / 2).wait;
	};
});

Tdef(\clock, {
	loop{
		~midi.noteOn(2, 60);
		~midi.noteOff(2, 60);
		0.5.wait;
	};
}).play;
