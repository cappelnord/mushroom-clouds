// TODO: ~cc that smooth over time

// Mushroom Clouds

~runAgents.(60 * 8, {|i| i * 0.125})

// TODO: put closest freq ratio in
// TODO: Absichern wenn mal Fehler passieren

~pedSustain.(0, 20)

(
~wAgents.do {|agent, i|
	agent[\act] = ~piano;
	agent[\durMap] = Prand([0.25, 0.25, 16], inf) * 0.25;
	agent[\velMap] = ~defaultVelMap * 0.3 + 10;
	agent[\quant] = 2;

	agent[\pPlay] = ~pFungus.("Sparassis crispa") * ~pScale.([0, 1, 4, 7], 0);


	agent[\lenMap] = 3;
};

)