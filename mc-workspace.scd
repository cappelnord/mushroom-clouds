// Mushroom Clouds

/*
"Agaricus sp."  "Sparassis crispa"  "Lycoperdon excipuliforme"
"Coprinellus micaceus" "Coprinellus disseminatus"  "Pleurotus ostreatus"
"Clathrus archeri" "Coprinopsis picacea"
"Laetiporus sulphureus"  "Trametes versicolor"
"Amanita rubescens"  "Macrolepiota fuliginosa"
"Fomitopsis pinicola"  "Helvella lacunosa"  "Pleurotus ostreatus Mycel"
"Lepiota aspera"  "Russula sp."  "Xerocomellus sp."
"Schizophyllum commune"  "Tremella mesenterica"

~pInterval, ~pScale, ~pOctaves, ~pHarmonicComb,
~pFungus, ~pSineWindow, ~pMix, ~pPart

*/


(
Ndef(\eno, {DC.ar(0!2)}).ar(2);

Ndef(\mix, {
	var sig = Ndef(\eno).ar(2) * 2;
	var verb;
	sig = FbC({|fb| sig + (fb * 0.25)}, 2, 3/4/2) + sig;
	verb = JPverb.ar(sig, 5);
	sig + (verb * 0.2);
});

Ndef(\mix).fadeTime = 5;
Ndef(\mix).play;
)


~runAgents.(60 * 12, {|i| i * 0.325})

(
var activeAgents = 32;

~storeAllAgents.();

~wAgents.do {|agent, i|
	// {|x, y, agent| 1.0 }

	var p1 = ~pFungus.("Pleurotus ostreatus Mycel").pow(2);
	var p2 = ~pFungus.("Lycoperdon excipuliforme").pow(2);
	var p3 = ~pFungus.("Schizophyllum commune").pow(2);
	var p4 = ~pFungus.("Amanita rubescens").pow(2);
	var p5 = ~pFungus.("Tremella mesenterica").pow(2);
	var p;

	p = ~pPart.(p3, p2, p5);

	p = p * (~pScale.(Scale.minorPentatonic,2));

	// p = p - (~pSineWindow.(0, 0.1) + (~pSineWindow.(1, 0.2) * 0.25));

	agent[\pPlay] = p;

	agent[\durMap] = Prand([1, 0.5, 0.25, 0.75], inf) * 1;
	agent[\velMap] = ~defaultVelMap * 1 + {[0, 0, 0, 0, 0, 10 + 5.rand].choose};
	agent[\quant] = 2;

	agent[\pRetry] = {|x, y, agent| 0.9 };

	agent[\lenMap] = Prand([0.125, 0.5, 1, 0.75], inf) * 2;


	agent[\act] = ~eno;
	agent[\echo] = false;
	agent[\active] = i < activeAgents;
};
)

s.scope

(
SynthDef(\fmPling, {|freq=440, out=0, pan=0, amp=0.1, len=8, modIndex=5, attack=0.001|
	var randomizedFreq = freq * Rand(0.995, 1.005);
	var mod = SinOsc.ar(freq*4.45 + Rand(0, 0.1)) * XLine.ar(freq * modIndex, 0.001, 0.1);
	var mod2 = SinOsc.ar(randomizedFreq*2) * XLine.ar(freq * 0.4, 0.001, 5);
	var sig = SinOsc.ar(randomizedFreq + mod + mod2, phase: 0.5pi) * AmpCompA.kr(randomizedFreq, (21+12).midicps);
	var ampModEnv = EnvGen.kr(Env([0, 0, 0.7], [1, len]));
	var ampMod = (1.0 - ampModEnv) + (SinOsc.ar(Rand(0.1, 0.8)) * ampModEnv);
	var env = EnvGen.ar(Env.perc(attack, len, 1, -2), doneAction: 2);
	Out.ar(out, Pan2.ar(sig * env * amp * ampMod, pan));
}).add;
)


(
var times = 0!128;
// sounds should not be retriggered too quick in succession
var thresh = 0.125;

~eno = {|num, vel=64, dur=1|
	((times[num] + thresh) <= TempoClock.default.beats).if({

		// parameters are adjusted to velocity and pitch ..
		// .. this matches personal preferences!

		Synth(\fmPling, [
			\freq, num.midicps,
			\amp, vel.linexp(0, 128, -60.dbamp, 1) * num.linexp(50, 128, 1, -18.dbamp) * num.linexp(0, 60, -18.dbamp, 1),
			\pan, num.linlin(20, 90, 0, 0.6) * (num*0.2).sin,
			\len, dur,
			\modIndex, vel.linlin(0, 128, 2, 6),
			\attack, num.linexp(0, 128, 0.002, 0.0005) * 2,
			\out, Ndef(\eno).bus
		]);
		times[num] = TempoClock.default.beats;
	});
}
)
