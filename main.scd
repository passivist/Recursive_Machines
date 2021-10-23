(
s.waitForBoot{
	TempoClock.tempo = 120/60;
	~vrb = Bus.audio(s, 2);
	~dly = Bus.audio(s, 2);

	"functions.scd".loadRelative;
	"conductor.scd".loadRelative;
	//"stretcher.scd".loadRelative;
	"setup_internal.scd".loadRelative;
	//"setup_modular.scd".loadRelative;
};
)

Tdef(\seqA).play;
Tdef(\seqB).play;

Tdef(\conductor).play;

3.do { ~seqA = ~lengthen.(~seqA, ~scale) };
3.do { ~seqB = ~lengthen.(~seqB, ~scale) };

~seqA = [[0], [1]];
~seqB = [[0], [1]];

Tdef(\seqA).stop;
Tdef(\seqB).stop;

Tdef(\conductor).stop;
