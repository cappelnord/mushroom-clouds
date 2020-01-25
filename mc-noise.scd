~nDiscretize = {|function, num=44100|
	var array = FloatArray.newClear(num);
	var fNum = num.asFloat;
	num.postln;
	num.do {|i|
		var value = function.value(i / fNum);
		array[i] = value;
	};
	array;
};

~nLinearize = {|function, xFunc, yFunc|
	{|t|
		function.value(xFunc.value(t), yFunc.value(t));
	};
};

~nGenerateBuffer = {|function, xFunc, yFunc, time, sampleRate|
	var numSamples, samples;
	sampleRate = sampleRate ? s.sampleRate;
	numSamples = (time * sampleRate).asInt;
	samples = ~nDiscretize.(~nToBipolar.(~nLinearize.(function, xFunc, yFunc)), numSamples);
	Buffer.loadCollection(s, samples, 1);
};

~nToBipolar = {|function|
	function * 2.0 - 1.0;
};