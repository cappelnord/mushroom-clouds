var midiInConnections = Dictionary();

var loadImage = {|file|
	var image = Image.open(file);

	var pixels = image.pixels;
	var array = Array.newClear(pixels.size);

	// uses bitshifting to extract color channels from integers representing the color
	// calculates the average of the 3 color channels and stores it as a normalized float

	pixels.do {|c, i|
		var blue = c &  0x000000FF;
		var green = c & 0x0000FF00 >> 8;
		var red = c & 0x00FF0000 >> 16;
		var value = red + green + blue / 3.0 / 256.0;
		array[i] = value;
	};

	(array: array, width: image.width, height: image.height);
};


var createMIDIFunction = {|destination, channel=0, retrigger=true|

	var table = Array.fill(128, nil);

	{|num, vel=64, dur=1|

		var routine = table[num];
		routine.isNil.if ({
			destination.noteOn(channel, num, vel);
		}, {
			routine.stop;
			retrigger.if {
				destination.noteOff(channel, num, 64);
				destination.noteOn(channel, num, vel);
			};
		});

		table[num] = {
			dur.wait;
			destination.noteOff(channel, num, 64);
			table[num] = nil;
		}.fork(clock: TempoClock.default);
		dur;
	};
};

var doMonteCarlo;

~initMIDIOut = {|deviceName, portName, channel|
	var destination;

	portName = portName ? deviceName;
	channel = channel ? 0;


	MIDIClient.initialized.not.if {MIDIClient.init;};
	destination = MIDIOut.newByName(deviceName, portName);

	CmdPeriod.add({
		fork {
			128.do {|n|
				destination.noteOff(channel, n, 64);
				0.001.wait;
			};
		}
	});

	createMIDIFunction.value(destination, channel, true);
};

// THIS COULD MAKE ISSUES

~initMIDICC = {|ccs, deviceName, portName, channel|
	var in;
	portName = portName ? deviceName;

	midiInConnections[deviceName].isNil.if {
		MIDIClient.initialized.not.if {MIDIClient.init;};

		in = MIDIIn.findPort(deviceName, portName);
		MIDIIn.connect(0, in);

		midiInConnections[deviceName] = in;
	};

	ccs.do {|cc|
		var key = ("cc" ++ cc).asSymbol;
		var value = 0.0;
		MIDIdef.cc(("mccc" ++ cc).asSymbol, {|val|
			value = val.linlin(0, 127, 0, 1.0);
			value.postln;
		}, cc, channel);

		currentEnvironment[key] = {value};
	};
};

~initLoadFungi = {|path|
	var files = PathName(Document.current.dir ++ "/fungi").files;
	files.do {|file|
		var key = file.fileNameWithoutExtension;
		~wFungi[key] = loadImage.value(file.absolutePath);
	};
};

~initWorld = {
	// ... init basic structures
	~wFungi = Dictionary();
	~wNotes = ((21)..(108));
	~wAgents = List();
};

~defaultNoteMap = {|x, y, p, agent|
	~wNotes[(y * ~wNotes.size).floor]
};

~defaultVelMap = {|x, y, p, agent|
	(48 + ((x * (agent[\index] * 0.1)).sin * 6) + 0.gauss(8).abs + (6 * p));
};


~initAgent = {
	var agent = ();

	agent[\quant] = nil;

	agent[\noteMap] = ~defaultNoteMap;
	agent[\velMap] = ~defaultVelMap;

	agent[\lenMap] = {|x, y, p, agent|
		10
	};

	agent[\durMap] = {|x, y, p, agent|
		1.0;
	};

	agent[\reverseNoteMap] = {|note|
		(note - ~wNotes[0]) / ~wNotes.size.asFloat
	};


	agent[\pRetry] = {|x, y, agent| 0.55};

	agent[\pPlay] = {|x, y, agent| 0.1};

	agent[\durs] = Pseq([1], inf);

	agent[\maxRetries] = {|t| 100 };

	agent[\xFunc] = {|t| t};

	agent[\yFunc] = {|t| 1.0.rand};

	agent[\act] = {|note, vel, len, x, y, p, agent|
		("Agent: " ++ agent[\index]).postln;
		[note, vel, len].postln;
	};

	agent;
};

~pScale = {|scale, root=0|
	var stepsPerOctave;
	var degrees;

	(scale.class == Scale).if ({
		stepsPerOctave = scale.stepsPerOctave;
		degrees = scale.degrees + root % stepsPerOctave;
	}, {
		stepsPerOctave = 12;
		degrees = scale;
	});

	{|x, y, agent|
		var note = agent[\noteMap].value(x, y) % stepsPerOctave;
		degrees.indexOf(note).isNil.not.if(1.0, 0.0);
	};
};


// fundamental Freq


~pClosestFreqRatio = {|fundamentalFreqFunction, fundamentalFreqSections|

	fundamentalFreqFunction = fundamentalFreqFunction ? {|x, y, agent| x.linexp(0, 1, 27.5, 27.5 * 4)};
	fundamentalFreqSections = fundamentalFreqSections ? [0.25, 1, 8];

	{|x, y, agent|
		var freq = agent[\noteMap].value(x, y).midicps;
		var fund = fundamentalFreqFunction.value(x, y);
		var targets = fundamentalFreqSections * fund;
		var harmonics;
		var deviation;

		// look in which section we are and set as fundamental frequency
		targets.do {|target|
			(freq >= target).if {
				fund = target;
			};
		};

		harmonics = (1..8) * fund;
		deviation = harmonics.collect({|h| (h-freq).abs / h}).sort.first;

		// shaping the final probability (according to my likings)
		(1.0 - deviation.sqrt.sqrt - 0.2).max(0) * (1.0/0.8);
	};
};


~pFungus = {|key|
	var i = ~wFungi[key];
	i.isNil.not.if({
		{|x, y, agent|
			var ret;
			x = (x * i[\width]).floor;
			y = (y * i[\height]).floor;
			ret = i[\array][y * i.width + x];
			// shaping the final probability with sqrt (according to my likings)
			(1.0 - ret.sqrt.sqrt.sqrt);
		};
	}, {
		("Could not find fungus: " ++ key).postln;
		{1.0};
	});
};


~initAgents = {|num|
	~stopAgents.();

	num.do {|i|
		var agent = ~initAgent.();
		agent[\index] = i;

		~wAgents.add(agent);
	};
};

doMonteCarlo = {|t, agent, xFunc, yFunc, playProbabilityFunc, retryProbabilityFunc=0.5, maxRetries=64|
	var redrawProbability;
	var playProbability;

	var retry = true;
	var ret = false;
	var numRetries = 0;

	(maxRetries > 200).if {
		maxRetries = 200;
	};

	{retry && (ret == false) && (numRetries < maxRetries)}.while({

		var x = xFunc.value(t);
		var y = yFunc.value(t);

		var playProbability = playProbabilityFunc.value(x, y, agent).min(1).max(0);
		var retryProbability = retryProbabilityFunc.value(x, y, agent).min(1).max(0);

		playProbability.coin.if({
			ret = (x: x, y: y, p: playProbability);
		}, {
			retry = retryProbability.coin;
			numRetries = numRetries + 1;
			(numRetries == maxRetries).if ({
				"Reached maximum number of retries!".postln;
			});
		});
	});

	ret;
};

~stopAgents = {
	"All Agents stopped and cleared!".postln;

	~wAgents.do {|agent| agent[\routine].stop;};
	~wAgents = List();
};


~runAgents = {|length, dispersalFunction|

	var startTime = TempoClock.default.beats;

	dispersalFunction = dispersalFunction ? 0.0;

	~wAgents.do {|agent, i|
		agent[\routine] = Routine({
			var t = 0;
			var dur = 4;

			// displaces them a bit
			dispersalFunction.value(i).wait;

			{t < 1.0}.while({
				var ret;

				// advance x in time
				t = TempoClock.default.beats.linlin(startTime, startTime + length, 0, 1);

				ret = doMonteCarlo.value(t, agent, agent[\xFunc], agent[\yFunc], agent[\pPlay], agent[\pRetry], agent[\maxRetries].value);

				(ret != false).if({

					var note = agent[\noteMap].(ret[\x], ret[\y], ret[\p], agent);
					var vel =   agent[\velMap].(ret[\x], ret[\y], ret[\p], agent);
					var len =   agent[\lenMap].(ret[\x], ret[\y], ret[\p], agent);

					agent[\durMap].isKindOf(Pattern).if {
						var stream = agent[\durMap].asStream;
						agent[\durMap] = {|x, y, p, agent|
						stream.next;
						};
					};

					dur =       agent[\durMap].(ret[\x], ret[\y], ret[\p], agent);

					agent[\act].value(note, vel, len, x, y, p, agent);
				});

				dur.wait;

				agent[\quant].isNil.not.if {
					var nextTime = agent[\quant].asQuant.nextTimeOnGrid(TempoClock.default);
					(nextTime - TempoClock.default.beats).wait;
					agent[\quant] = nil;
				};

			});
		}).play(TempoClock.default);
	}
};

MIDIClient.disposeClient;