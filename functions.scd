// expects the sequence to be operated on and a scale object
~lengthen = {|sequence, scale|
	var weightsPitch, lastPitch, newPitch;
	scale ?? {"no valid scale provided!".error };
	// create an array of all the degrees in the scale and extend it
	// one octave down
	scale = scale.degrees;
	scale = (scale - 12) ++ scale;
	// get the last note in the pitch array
	lastPitch = sequence[0].last;
	// calculate the weights on the basis of all the pitches in the scale
	weightsPitch = (scale-lastPitch).abs;
	weightsPitch = weightsPitch.collect{|item| if(item == 0){ 3 }{ item }};
	// das ist seltsam!
	weightsPitch = (weightsPitch.maxItem - weightsPitch).normalizeSum;
	// choose a new pitch to add
	newPitch = wchoose(scale, weightsPitch);
	sequence[0] = sequence[0].add(newPitch);
	sequence[1] = sequence[1].add(1);
	sequence;
};

// change some amount of pitches in the sequence
~mutate = {|sequence, amount=0.1, scale|
	var weightsPitch, prevPitch, newPitch, newSequence;
	newSequence = [[], sequence[1]];
	scale ?? {"no valid scale provided!".error; };
	// create an array of all the degrees in the scale and extend it
	// one octave down
	scale = scale.degrees;
	scale = (scale - 12) ++ scale;
	newSequence[0] = sequence[0].collect{|item, i|
		if(amount.coin){
			// get the last note in the pitch array
			prevPitch = sequence[0][(i - 1).wrap(0, (sequence[0].size - 1))];
			prevPitch;
			// calculate the weights on the basis of all the pitches in the scale
			weightsPitch = (scale-prevPitch).abs;
			weightsPitch = weightsPitch.collect{|item| if(item == 0){ 3 }{ item }};
			weightsPitch = (weightsPitch.maxItem - weightsPitch).normalizeSum;
			// choose a new pitch to add
			newPitch = wchoose(scale, weightsPitch)
		}{
			item
		}
	};
};

// expects the sequence and an amount between 0.001 and 1
~shorten = {|sequence, amount=0.1|
	var length;
	amount = amount.clip(0.001, 1);
	length = (sequence[0].size / (1/amount)).ceil.postln;
	length.do{
		if(sequence[0].size > 1){
			sequence.do{|item, i| item.removeAt(sequence[i].size - 1); }
		};
	};
	sequence;
};

// expects  the sequence and a valid scale object
~quantize = {|sequence, scale|
	scale !? (
		sequence[0] = sequence[0].collect{|item, i|
			item.nearestInScale(scale, 12);
		};
		sequence;
	) ?? "scale is nil, pass valid scale object as argument";
};

// expects the sequence, an amount of positive or negative integers,
// a bool for the quantize flag and a valid scale object
~transpose = { |sequence, amount=0, quantize=false, scale|
	sequence[0] = sequence[0] + amount;
	if(quantize){ ~quantize.(sequence, scale) }{ sequence };
};

// invert all the intervals in a sequence
// expects the sequence, a quantize flag and a valid scale object
~invert = {|sequence, quantize=false, scale|
	var interval, lastItem=0, newSequence;
	newSequence = [[0], sequence[1]];
	interval = sequence[0].collect{|item, i|
		if((i-1) >= 0){
			(sequence[0][i] - sequence[0][i - 1]) * -1;
		};
	};
	newSequence[0] = interval.collect{|item, i|
		if(i == 0){
			sequence[0][0];
		}{
			lastItem = lastItem + interval[i];
		};
	};
	if(quantize){ ~quantize.(newSequence, scale) }{ newSequence };
};

// reverse the sequence
~reverse = {|sequence|
	sequence.do{|item, i|
		sequence[i] = item.reverse;
	}
};

// rotate the sequence
~rotate = {|sequence, amount|
	sequence.do{|item, i|
		sequence[i] = item.rotate(amount);
	};
};

~quantizeLength = {|sequence, roundAmt = 1|
	var newSequence;
	newSequence = sequence;
	newSequence[1] = newSequence[1].collect{ |item, i|
		// round the length values
		item = item.round(roundAmt);
		// replace durations with value 0 with something more sensible
		if(item == 0){ item = 0.125 }{ item };
	};
	newSequence
};

// change the overall timing of the sequence
~augment = {|sequence, amount, roundAmt = 0.5|
	var newSequence;
	newSequence = sequence;
	newSequence[1] = newSequence[1] * amount;
	~quantizeLength.(newSequence, roundAmt);
};

// match the length of sequenceA to the lenght of sequenceB
~matchLength = {|sA, sB|
	var sequenceA, sequenceB;
	sequenceA = Array.newFrom(sA);
	sequenceB = Array.newFrom(sB);
	2.do{|i|
		if( sequenceB[i].size > sequenceA[i].size){ sequenceA[i] = sequenceA[i].wrapExtend(sequenceB[i].size)};
		if( sequenceB[i].size < sequenceA[i].size){ sequenceA[i] = sequenceB[i].collect{|item, j| sequenceA[i][j] }};
	};
	sequenceA;
};

// crossfade between two sequences
~fade = {|sequenceA, sequenceB, amount, quantize=false, scale, quantizeLength=true|
	var newSequence;
	newSequence = Array.newClear(2);
	// make the sequences the same length if they are different, by either repeating or truncating the
	// second sequence
	sequenceB = ~matchLength.(sequenceB, sequenceA);
	2.do{|i|
		newSequence[i] = amount.linlin(0, 1, sequenceA[i], sequenceB[i]);
	};
	// round the pitch values
	newSequence[0] = newSequence[0].collect{|item, i| item.round(1).asInt };
	if(quantizeLength){ newSequence = ~quantizeLength.(newSequence) };
	if(quantize){ ~quantize.(newSequence, scale) }{ newSequence };
};

// crossfade between two sequences
~fadeFlat = {|aA, aB, amount, roundAmt=1|
	var newSequence, arrayA, arrayB;
	arrayA = Array.newFrom(aA);
	arrayB = Array.newFrom(aB);
	// make the sequences the same length if they are different, by either repeating or truncating the
	// second sequence
	if( arrayA.size > arrayB.size){ arrayB.wrapExtend(arrayA.size)};
	if( arrayA.size < arrayB.size){ arrayB = arrayA.collect{|item, i| arrayB[i] }};
	newSequence = amount.linlin(0, 1, arrayA, arrayB).round(roundAmt);
};

// have the intervals of one sequence imitate the intervals in another
~imitate = {|sA, sB, amount=1, quantize=false, scale|
	var intervalsA, intervalsB, difference, intervals, newSequence, lastItem, sequenceA, sequenceB;
	newSequence = Array.newClear(2);
	// make the sequences the same length if they are different, by either repeating or truncating the
	// second sequence
	sequenceA = Array.newFrom(sA);
	sequenceB = Array.newFrom(sB);
	sequenceB = ~matchLength.(sequenceB, sequenceA);
	// calculate the intervals of both sequences
	intervalsA = sequenceA[0].collect{|item, i|
		if((i-1) >= 0){
			(sequenceA[0][i] - sequenceA[0][i - 1]);
		};
	};
	intervalsB = sequenceB[0].collect{|item, i|
		if((i-1) >= 0){
			(sequenceB[0][i] - sequenceB[0][i - 1]);
		};
	};
	// remove the first element because it is nil and causes problems
	intervalsA.removeAt(0);
	intervalsB.removeAt(0);
	// crossfade between the intervals
	intervals = ~fadeFlat.(intervalsA, intervalsB, amount, 1).asInt;
	// construct the new sequence from the faded intervals
	newSequence[0] = sequenceA[0].size.collect{|i|
		if(i==0){
			lastItem = sequenceA[0][0];
		}{
			lastItem = lastItem + intervals[i-1];
		}
	};
	newSequence[1] = ~fadeFlat.(sequenceA[1], sequenceB[1], amount, 1);
	if(quantize){ ~quantize.(newSequence, scale) }{ newSequence };
};

// increase consonance between sequences
~match = {|sA, sB, amount=1, quantize=false, scale|
	var newSequence, distance, consonance, sequenceA, sequenceB;
	newSequence = Array.newClear(2);
	sequenceA = Array.newFrom(sA);
	sequenceB = Array.newFrom(sB);
	// make the sequences the same length if they are different, by either repeating or truncating the
	// second sequence
	sequenceB = ~matchLength.(sequenceB, sequenceA);
	// the intervals are rated as:
	//            0   1   2   3   4   5   6   7   8   9   10  11
	consonance = [12, 1,  2,  6,  7, 10,  5, 11,  8,  9,  4,  3];
	amount = amount.linlin(0, 1, 0, 11).floor;
	newSequence[0] = sequenceA[0].collect{|item, i|
		var int, oldCon, try, tryCon, oldTryCon, newNote;
		oldCon = consonance[(sequenceB[0][i] - item).wrap(0, 11)];
		try = sequenceA[0][i];
		amount.do{|j|
			if(j == 0){ oldTryCon = 0 }{ oldTryCon = tryCon };
			j = (j - ((amount/2).floor)).asInt;
			tryCon = consonance[(sequenceB[0][i] - try).wrap(0, 11)];
			if(tryCon > oldTryCon) { try = sequenceA[0][i] + j};
			// postf("oldNote: %, try: %, oldCon: %, tryCon: %, interval: %\n", sequenceA[i], try, oldCon, tryCon, (sequenceB[i] - item).wrap(0, 11));
			if((tryCon > oldCon)){ newNote = try }{ newNote = sequenceA[0][i]};
		};
		newNote;
	};
	newSequence[1] = sequenceA[1];
	if(quantize){ ~quantize.(newSequence, scale) }{ newSequence };
};

// take the first few notes of sequenceA and construct a new sequence where sequenceA is
// transposed accordings to the notes in sequenceB. If a rythm is supplied have the resulting
// sequence imitate that rythm
~sequence = {|sequenceA, sequenceB, amount=1, quantize=false, scale|
	var newSequence, copyLength;
	newSequence = [[], []];
	sequenceB[0].size.do{|i|
		copyLength = amount.linlin(0, 1, 2, sequenceA[1].size).round.asInt;
		copyLength.do{|j|
			var note;
			note = sequenceB[0][i] + sequenceA[0][j];
			newSequence[0] = newSequence[0].add(note);
			newSequence[1] = newSequence[1].add(sequenceB[1][i]);
		};
	};
	if(quantize){ ~quantize.(newSequence, scale) }{ newSequence };
};

~addRythm = {|seq, amount=1|
	var lengths, weights, newLengths;
	lengths = [1, 2, 3, 4, 5, 7, 8];
	// for every note we got a different set of weights for the lengths
	//			   1,    2,   3,    4,    5,    7,    8
	weights = [ 0.45,  0.2, 0.15, 0.1, 0.07, 0.03, 0.02].normalizeSum;

	seq[1] = seq[0].collect{|pitch, i|
		if(amount.coin){
			wchoose(lengths, weights);
		}{
			seq[1][i]
		}
	};
};

~removeRythm = { |seq|
	seq[1] = seq[1].do{|item, i|
		seq[1][i] = 1;
	}
};