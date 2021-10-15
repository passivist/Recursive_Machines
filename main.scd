(
s.waitForBoot{
	TempoClock.tempo = 120/60;
	~vrb = Bus.audio(s, 2);
	~dly = Bus.audio(s, 2);

	"functions.scd".loadRelative;
	//"stretcher.scd".loadRelative;
	"setup_internal.scd".loadRelative;
	//"setup_modular.scd".loadRelative;
};
)

Tdef(\seqA).play;
Tdef(\seqB).play;

3.do { ~seqA = ~lengthen.(~seqA, ~scale) };
3.do { ~seqB = ~lengthen.(~seqB, ~scale) };

~seqA = ~mutate.(~seqA, 1, ~scale);

~seqA = ~quantize.(~seqA, ~scale);

~seqA = ~transpose.(~seqA, 4, true, ~scale);

~seqA = ~invert.(~seqA, true, ~scale);

~scale = Scale.new([0, 2, 3, 5, 6, 8, 9, 11], 12, Tuning.et12, \halfwhole);

~seqA;
~seqB;

~seqA = ~imitate.(~seqA, ~seqB, 0.5, true, ~scale)
~seqB = ~match.(~seqB, ~seqA, 1, true, ~scale)

~seqA = ~sequence.(~seqA, ~seqB, 0.5, true, ~scale);
~seqB = ~sequence.(~seqB, ~seqA, 0.5, true, ~scale);

~seqA = ~addRythm.(~seqA, 0.6)
~seqB = ~addRythm.(~seqB, 0.6)

Tdef(\seqA).stop;
Tdef(\seqB).stop;

~seqA = [[0], [1]];
~seqB = [[0], [1]];