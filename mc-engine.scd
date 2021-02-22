var midiInConnections = Dictionary();

var agentStoreKeys;

var loadImage = {|file|
	var image = Image.open(file);

	var pixels = image.pixels;
	var array = Array.newClear(pixels.size);

	// uses bitshifting to extract color channels from integers representing the color
	// calculates the average of the 3 color channels and stores it as a normalized float

	pixels.do {|c, i|
		var blue = c & 0x000000FF;
		var green = c & 0x0000FF00 >> 8;
		var red = c & 0x00FF0000 >> 16;
		// var value = (red + green + blue) / (3.0 * 256.0);
		var value = blue / 256.0;
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

~initMIDIOut = {|deviceName, portName, channel, buildPedalFunctions=true|
	var destination;

	var pedals = (\sustain: 0, \unaCorda: 0, \sostenuto: 0);

	portName = portName ? deviceName;
	channel = channel ? 0;


	MIDIClient.initialized.not.if {MIDIClient.init;};
	destination = MIDIOut.newByName(deviceName, portName);

	buildPedalFunctions.if {

		var pedalFunction = {|key, num|
			{|value, time=0|
				(time <= 0).if ({
					pedals[key] = value;
					destination.control(channel, num, value);
				},
				{
					var currentValue = pedals[key];
					var delta = (value - currentValue);
					var steps = delta.abs;
					var step = delta.sign;
					var wt = time / steps;
					fork {
						steps.do {
							currentValue = currentValue + step;
							pedals[key] = currentValue;
							destination.control(channel, num, currentValue);
							wt.wait;
						}
					};
				});
			}
		};

		~pedSustain = pedalFunction.value(\sustain, 64);
		~pedCorda = pedalFunction.value(\unaCorda, 67);
		~pedSostenuto = pedalFunction.value(\sostenuto, 66);

	};



	CmdPeriod.add({
		fork {

			~pedSustain.value(0);
			~pedCorda.value(0);
			~pedSostenuto.value(0);

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
		}, cc, channel);

		currentEnvironment[key] = {value};
	};
};

~initLoadFungi = {|path|
	var files = PathName(Document.current.dir ++ "/fungi").files;
	files.do {|file|
		var key = file.fileNameWithoutExtension;
		~wFungi[key] = loadImage.value(file.absolutePath);
		("\"" ++ key ++ "\"").postln;
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

~defaultFreqMap = {|x, y, p, agent|
	y.linexp(0, 1, ~wNotes.first.midicps, ~wNotes.last.midicps);
};

~defaultVelMap = {|x, y, p, agent|
	(48 + ((x * (agent[\index] * 0.1)).sin * 6) + 0.gauss(8).abs + (6 * p)) - y.linlin(0, 0.2, 8, 0);
};

~storeAllAgents = {
	~wAgents.do {|agent|
		~storeAgent.value(agent);
	};
};

~storeAgent = {|agent|
	agent[\store] = ();

	agentStoreKeys.do {|key|
		agent[\store][key] = agent[key];
	};
};

~restoreAgent = {|agent|
	agentStoreKeys.do {|key|
		agent[key] = agent[\store][key];
	};
};

~initAgent = {
	var agent = ();

	agent[\quant] = nil;

	agent[\noteMap] = ~defaultNoteMap;
	agent[\velMap] = ~defaultVelMap;
	agent[\freqMap] = ~defaultFreqMap;

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

	agent[\active] = true;

	agent[\echo] = false;

	agent[\history] = List();

	agentStoreKeys = agent.keys.copy;

	~storeAgent.value(agent);

	agent;
};

~pInterval = {|intervals, wrapOctaves=false|
	{|x, y, agent|
		var note = agent[\noteMap].value(x, y);
		var last = agent[\history].last[\note];

		wrapOctaves.if {
			note = note % 12;
			last = last % 12;
			intervals = intervals % 12;
		};

		last.isNil.if ({
			1.0;
		}, {
			var targets = last + intervals;
			targets.indexOf(note).isNil.not.if(1.0, 0.0);
		});
	};
};

~pScale = {|scale, root=0|
	var stepsPerOctave;
	var degrees;

	(scale.class == Scale).if ({
		stepsPerOctave = scale.stepsPerOctave;
		degrees = scale.degrees + root % stepsPerOctave;
	}, {
		stepsPerOctave = 12;
		degrees = scale + root % stepsPerOctave;
	});

	{|x, y, agent|
		var note = agent[\noteMap].value(x, y) % stepsPerOctave;
		degrees.indexOf(note).isNil.not.if(1.0, 0.0);
	};
};

~pOctaves = {|octaves|
	octaves = [octaves].flatten;

	{|x, y, agent|
		var note = agent[\noteMap].value(x, y);
		var octave = (note / 12).floor.asInteger;
		octaves.indexOf(octave).isNil.not.if(1.0, 0.0);
	};
};

~pHarmonicComb = {|fundamentalFreqFunction, harmonics, width=0.1|

	fundamentalFreqFunction = fundamentalFreqFunction ? {|x, y, agent| x.linexp(0, 1, 27.5, 27.5 * 4)};
	harmonics = harmonics ? (1..8);

	{|x, y, agent|
		var freq = agent[\freqMap].value(x, y);
		var fund = fundamentalFreqFunction.value(x, y);

		var ret = 0;

		(fund * harmonics).do {|harmonicFreq|
			var lower = harmonicFreq * (1.0 - (width / 2.0));
			var upper = harmonicFreq * (1.0 + (width / 2.0));
			var phase = freq.explin(lower, upper, 0, pi);
			ret = ret + phase.sin;
		};

		ret.tanh;
	};
};


~pFungus = {|key|
	var i = ~wFungi[key];
	i.isNil.not.if({
		var width = i[\width];
		var height = i[\height];
		var array = i[\array];

		{|x, y, agent|
			var ret;
			var idx;
			y = (1.0 - y);
			x = (x * width).floor.max(0).min(width-1).asInteger;
			y = (y * height).floor.max(0).min(height-1).asInteger;
			idx = (y * width + x).asInteger;
			ret = array[idx];
			ret;
		};
	}, {
		("Could not find fungus: " ++ key).postln;
		{0.0};
	});
};

// BROKEN!!!
~pBilinFungus = {|key|
	var i = ~wFungi[key];
	i.isNil.not.if({

		var width = i[\width];
		var height = i[\height];
		var array = i[\array];

		{|ix, iy, agent|
			var ret;
			var x, y, x1, x2, y1, y2;
			var fq11, fq21, fq12, fq22;
			var fxy1, fxy2;

			iy = (1.0 - iy);

			x = (ix * width).max(0).min(width);
			y = (iy * height).max(0).min(height);


			x1 = x.floor.max(0).min(width-1).asInteger;
			x2 = x.ceil.max(0).min(width-1).asInteger;
			y1 = y.floor.max(0).min(height-1).asInteger;
			y2 = y.ceil.max(0).min(height-1).asInteger;

			fq11 = array[y1 * width + x1];
			fq21 = array[y1 * width + x2];
			fq12 = array[y2 * width + x1];
			fq22 = array[y2 * width + x2];

			// https://en.wikipedia.org/wiki/Bilinear_interpolation

			// PROBLEM IST, DASS UNTER DEM BRUCH 0 RAUSKOMMEN KANN ...

			fxy1 = (((x2-x) / (x2-x1)) * fq11) + (((x-x1) / (x2-x1)) * fq21);
			fxy2 = (((x2-x) / (x2-x1)) * fq12) + (((x-x1) / (x2-x1)) * fq22);

			ret =  (((y2-y) / (y2-y1)) * fxy1) + (((y-y1) / (y2-y1)) * fxy2);

			ret;
		};
	}, {
		("Could not find fungus: " ++ key).postln;
		{0.0};
	});
};

~pSineWindow = {|posFunc=0.5, sizeFunc=0.5|
	{|x, y, agent|
		var pos = posFunc.value(x, y, agent);
		var size = sizeFunc.value(x, y, agent);
		var windowMin = pos - (size/2);
		var windowMax = pos + (size/2);
		var phase = y.linlin(windowMin, windowMax, 0.0, pi);
		phase.sin;
	}
};

~pMix = {|mixFunc=0, aFunc=1, bFunc=0, clip=true|
	{|x, y, agent|
		var mix = mixFunc.value(x, y, agent).min(1).max(0);
		var a = aFunc.value(x, y, agent);
		var b = bFunc.value(x, y, agent);
		clip.if {
			a = a.min(1).max(0);
			b = b.min(1).max(0);
		};
		((1.0 - mix) * a) + (mix * b);
	};
};

~pPart = {|partYFunc=0.5, belowFunc=1, aboveFunc=0|
	{|x, y, agent|
		(y < partYFunc.value(x, y, agent)).if({
			belowFunc.value(x, y, agent);
		}, {
			aboveFunc.value(x, y, agent);
		});
	};
};


~patternToFunction = {|obj|
	obj.isKindOf(Pattern).if ({
		var stream = obj.asStream;
		{|x, y, p, agent|
			stream.next;
		}
	}, {
		obj;
	});
};



~initAgents = {|num|
	~clearAgents.();

	num.do {|i|
		var agent = ~initAgent.();
		agent[\index] = i;

		~wAgents.add(agent);
	};
};

doMonteCarlo = {|t, agent, xFunc, yFunc, playProbabilityFunc, retryProbabilityFunc=0.5, maxRetries=128|
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

~clearAgents = {
	~stopAgents.value;
	"All agents cleared!".postln;
	~wAgents = List();
};

~stopAgents = {
	"All Agents stopped!".postln;
	~wAgents.do {|agent| agent[\routine].stop; agent[\vizRoutine].stop;};
};


~runAgents = {|length, dispersalFunction|

	var startTime = TempoClock.default.beats;

	var tFunc = {TempoClock.default.beats.linlin(startTime, startTime + length, 0, 1)};

	~stopAgents.value;

	dispersalFunction = dispersalFunction ? 0.0;

	~wViz.isNil.not.if {
		~wViz.value(tFunc);
	};

	~clearViz.isNil.not.if {
		~clearViz.value;
	};

	~wAgents.do {|agent, i|
		agent[\routine] = Routine({
			var t = 0;
			var dur = 4;

			// displaces them a bit
			dispersalFunction.value(i).wait;

			{t < 1.0}.while({
				var ret;

				{
					// advance x in time
					t = tFunc.value;

					agent[\active].if {

						ret = doMonteCarlo.value(t, agent, agent[\xFunc], agent[\yFunc], agent[\pPlay], agent[\pRetry], agent[\maxRetries].value);

						(ret != false).if({

							var note, vel, len;

							agent[\durMap] = ~patternToFunction.value(agent[\durMap]);
							agent[\lenMap] = ~patternToFunction.value(agent[\lenMap]);

							note = agent[\noteMap].(ret[\x], ret[\y], ret[\p], agent);
							vel = agent[\velMap].(ret[\x], ret[\y], ret[\p], agent).round.asInteger.min(127).max(0);
							len = agent[\lenMap].(ret[\x], ret[\y], ret[\p], agent);

							dur = agent[\durMap].(ret[\x], ret[\y], ret[\p], agent);

							agent[\echo].if {
								">> %  %  %".format(note.asString.padRight(3), vel.asString.padRight(3), len.round(0.001)).postln;
							};

							agent[\history].add((\note: note, \vel: vel, \len: len));

							agent[\act].value(note, vel, len, x, y, p, agent);
						});
					};

					dur.wait;

					agent[\quant].isNil.not.if {
						var nextTime = agent[\quant].asQuant.nextTimeOnGrid(TempoClock.default);
						(nextTime - TempoClock.default.beats).wait;
						agent[\quant] = nil;
					};

				}.try({|error|
					error.errorString.postln;
					"Agent got restored to last safe state!".warn;
					~restoreAgent.value(agent);
				});
			});
		}).play(TempoClock.default);
	}
};

MIDIClient.disposeClient;