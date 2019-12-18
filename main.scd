(
s.waitForBoot{
	TempoClock.tempo = 110/60;
	~vrb = Bus.audio(s, 2);
	~dly = Bus.audio(s, 2);

	"functions.scd".loadRelative;
	//"stretcher.scd".loadRelative;
	"setup_internal.scd".loadRelative;
	//"setup_modular.scd".loadRelative;
};
)

~seqA
~seqA = [[0, 2, 3, 5], [1, 1, 1, 1]];
~seqB = [[0], [1]];

~seqA = ~lengthen.(~seqA, ~scale);
~seqA = ~mutate.(~seqA, 0.1, ~scale);
~seqA = ~quantize.(~seqA, ~scale);

Tdef(\seqA).play;
Tdef(\seqB).play;

~scale = Scale.new([0, 2, 3, 5, 6, 8, 9, 11], 12, Tuning.et12, \halfwhole);
~scale = Scale.at(\minor);

Tdef(\seqA).stop;
Tdef(\seqB).stop;

padZero