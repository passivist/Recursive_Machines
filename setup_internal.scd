Ndef(\vrb, {
	var sig;
	sig = In.ar(~vrb, 2);
	sig = JPverb.ar(sig,
		t60: 1.8, damp: 0.6, size: 0.7,
		earlyDiff: 0.618, modDepth: 0.3, modFreq: 1,
		low: 0.8, mid: 1.2, high: 1,
		lowcut: 500, highcut: 7000,
	);
	sig;
}).play;

SynthDef(\s0, {|out, freq, pan=0, amp=0.1|
	var env, mod, sig;
	env = Env.perc(0, ExpRand(0.1, 0.7)).ar(2);
	mod = (BrownNoise.ar * Rand(1, 10)) + (Pulse.ar(Rand(4000, 9000)) * ExpRand(0.01, 100));
	sig = LFTri.ar(freq + mod);
	sig = (sig + (sig * PinkNoise.ar(Rand(0, 0.35)))).tan.tanh;
	sig = Pan2.ar(sig, pan) * env;
	Out.ar(~vrb, sig * -28.dbamp);
	Out.ar(out, sig.tanh * amp);
}).add;

SynthDef(\s1, {|out, freq, pan=0, amp=0.1|
	var env, mod, sig;
	env = Env.perc(0, ExpRand(0.1, 0.7)).ar(2);
	mod = (BrownNoise.ar * Rand(1, 10)) + (Pulse.ar(Rand(4000, 9000)) * ExpRand(0.01, 100));
	sig = LFTri.ar(freq + mod);
	sig = (sig + (sig * PinkNoise.ar(Rand(0, 0.35)))).tan.tanh;
	sig = Pan2.ar(sig, pan) * env;
	Out.ar(~vrb, sig * -28.dbamp);
	Out.ar(out, sig.tanh * amp);
}).add;

~seqA = [[0], [1]];
~seqB = [[0], [1]];
~scale = Scale.at(\dorian);
Tdef(\seqA, {
	inf.do{|i|
		if((~seqA[0][i % ~seqA[0].size] == \rest).not){
			Synth(\s0, [
				\freq, (~seqA[0][i % ~seqA[0].size] + (12 * 5) + 2.7).midicps,
				\pan, -0.5,
			]);
		};
		(~seqA[1][i % ~seqA[1].size] / 2).wait;
	};
});

Tdef(\seqB, {
	inf.do{|i|
		if((~seqB[0][i % ~seqB[0].size] == \rest).not){
			Synth(\s1, [
				\freq, (~seqB[0][i % ~seqB[0].size] + (12 * 5) + 2.7).midicps,
				\pan, 0.5

			]);
		};
		(~seqB[1][i % ~seqB[1].size] / 2).wait;
	};
});

3.do{
	~seqA = ~lengthen.(~seqA, ~scale);
	~seqB = ~lengthen.(~seqB, ~scale);
};