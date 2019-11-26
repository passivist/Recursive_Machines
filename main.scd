(
s.waitForBoot{
	TempoClock.tempo = 150/60;
	~vrb = Bus.audio(s, 2);
	~dly = Bus.audio(s, 2);

	"functions.scd".loadRelative;
	//"stretcher.scd".loadRelative;
	"setup_internal.scd".loadRelative;
	//"setup_modular.scd".loadRelative;

	3.do{
		~seqA = ~lengthen.(~seqA, ~scale);
		~seqB = ~lengthen.(~seqB, ~scale);
	};
};
)

Tdef(\seqA).play;
Tdef(\seqB).play;

~scale = Scale.new([0, 2, 3, 5, 6, 8, 9, 11], 12, Tuning.et12, \halfwhole);

Tdef(\seqA).stop;
Tdef(\seqB).stop;
