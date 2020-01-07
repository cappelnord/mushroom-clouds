// TODO: ~cc that smooth over time

// Mushroom Clouds

~runAgents.(60 * 8, {|i| i * 0.125})

// TODO: put closest freq ratio in
// TODO: Absichern wenn mal Fehler passieren
// TODO: Scale Weight Filter
// TODO: Flip Y Axis

~pedSustain.(0, 8)

(
~wAgents.do {|agent, i|
	agent[\act] = ~piano;
	agent[\durMap] = Prand([0.25, 0.25, 0.5], inf) * 4;
	agent[\velMap] = ~defaultVelMap * 0.3;
	agent[\quant] = 0;

	agent[\pPlay] = ~pFungus.("Sparassis crispa").pow(6) * 400000 * ~pScale.([5, i%3, i%5], 0);

	agent[\lenMap] = 4;
};

)