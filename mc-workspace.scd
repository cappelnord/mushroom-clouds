// TODO: ~cc that smooth over time
// TODO: Visualisierung

// Mushroom Clouds

~runAgents.(100, {|i| i * 0.125})

// TODO: put closest freq ratio in
// TODO: Absichern wenn mal Fehler passieren

(
~wAgents.do {|agent, i|
	agent[\act] = ~piano;
	agent[\durMap] = Prand([0.25, 0.5, 1, 2, 4], inf);
	agent[\quant] = nil;

	agent[\pPlay] = ~pFungus.("Sparassis crispa") * ~pClosestFreqRatio.() * ~pScale.(Scale.minorPentatonic, 0);

	agent[\lenMap] = 10 + 10.rand;
};

)