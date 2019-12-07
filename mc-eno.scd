
// FM synth with some random detunings and slight amplitude modulation to the end

s.waitForBoot({
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

	// effects: filtered feedback delays and reverb
	SynthDef(\fmPlingFX, {|in=0, out=0|
		var sig = In.ar(in, 2);
		var sigToDelay = HPF.ar(sig, 300);
		sig = sig + (FbC({|fb| LPF.ar(sigToDelay + (fb * 0.4), 3000)}, 4/8.0, 4/8.0, 2) * 0.2) + (FbC({|fb|
			LPF.ar(HPF.ar(sigToDelay + (fb * 0.8), 2000), 6000)
		}, 6/8.0, 6/8.0, 2) * 0.1);
		sig = sig + (JPverb.ar(sig, 16, 0.2) * 0.09);
		Out.ar(out, sig * 18.dbamp); // push gain up a bit
	}).add;
});


~initEnoOut = {
	var bus = Bus.audio(s, 2);
	var fxNode = Synth(\fmPlingFX, [\in, bus, \out, 0]);
	var times = 0!128;
	// sounds should not be retriggered too quick in succession
	var thresh = 0.125;

	{|num, vel=64, dur=1|
		((times[num] + thresh) <= TempoClock.default.beats).if({

			// parameters are adjusted to velocity and pitch ..
			// .. this matches personal preferences!

			Synth(\fmPling, [
				\freq, num.midicps,
				\amp, vel.linexp(0, 128, -60.dbamp, 1) * num.linexp(50, 128, 1, -18.dbamp) * num.linexp(0, 60, -18.dbamp, 1),
				\pan, num.linlin(20, 90, 0, 0.6) * (num*0.2).sin,
				\len, dur,
				\modIndex, vel.linlin(0, 128, 2, 6),
				\attack, num.linexp(0, 128, 0.002, 0.0005) * 3,
				\out, bus
			]);
			times[num] = TempoClock.default.beats;
		});
	}
};