// monitor how often the user is triggering new functions
// and start to trigger them on its own if the user becomes inactive

// approaches:
// run a timer which resets every time a function is triggered
// problem: how to differenciate between functions triggered by the user
// 			and by the conductor? Do one even needs to differenciate?
// 			also need to modify every function to trigger conductor and
// 			the system probably won't work without it, so it's less modular

// find some way of checking if the sequences haven't changed in a while
// 			more modular! probably won't complicate the function code much
//			much more and make it less readable

Tdef(\conductor, {
	var seqsOld, c;
	seqsOld = [[nil, nil], [nil, nil]];
	c = [0, 0];
	inf.do{
		// check both sequences if they are different from before
		[~seqA, ~seqB].do{|seq, i|
			if(seq != seqsOld[i]){
				// if the sequence has changed update the saved sequence
				// and reset the counter
				seqsOld[i] = seq;
				c[i] = 0;
			}{
				// if the sequence hasn't changed increment the counter
				c[i] = c[i] + 1;

				if(c[i] > rrand(7, 17).floor){
					[
						{ seq = ~mutate.(seq, 1.0.rand, ~scale); "mutating".postln; },
						{ seq = ~rotate.(seq, 1.0.rand.asInteger); "rotating".postln; },
						{ seq = ~reverse.(seq); "reversing".postln; },
						{ seq = ~lengthen.(seq, ~scale); "lenghtening".postln; },
						{ seq = ~shorten.(seq, 0.3.rand); "shortening".postln; },
						{ seq = ~addRythm.(seq, 0.5.rand); "rythmetizing".postln; },
						{ seq = ~removeRythm.(seq); "derythmetizing".postln; }
					].wchoose([0.6, 0.1, 0.1, 0.08, 0.08, 0.01, 0.01]).value;
					// reset the counter if the sequences now differ
					c[i] = 0;
				};
			};
		};
		4.wait;
	}
});