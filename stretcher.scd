~b =[
	Buffer.readChannel(s, "_samples/esk_chord_one_shot_rhodes_Cm.wav".resolveRelative, channels: 0),
	Buffer.readChannel(s, "_samples/esk_chord_one_shot_rhodes_Cm.wav".resolveRelative, channels: 1)
];

SynthDef(\str, {|out, dur=900, amp=0.8|
	var pH, p, t, env;
	env = Env([0, 1, 1, 0], [5, dur-10, 5]).ar(2);
	t = Impulse.ar(12) + Dust.ar(3);
	p = 2.collect{|i|
		pH = Line.ar(0, BufDur.kr(~b[i]) * TRand.ar(0.95, 1.05, t), dur);
		TGrains.ar(1, t, ~b[i], BufRateScale.kr(~b[i]) * 0.25, pH, 0.4);
	};
	p = BPeakEQ.ar(p, 200, 0.5, -12);
	p = BPeakEQ.ar(p, 500, 0.7, -12);
	p = XFade2.ar(p, JPverb.ar(p, 3, 0.3, 3, 0.707), 0.2);
	Out.ar(out, p * amp * env);
}).add;

fork{ 2.wait; ~s = Synth(\str, [\dur, 900, \amp, -6.dbamp]); };