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

~runAgents.(60 * 12, {|i| i * 0.325})

~pedSustain.(0)

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

	p = ~pPart.(p2, p1, p3);

	p = p * (~pScale.([0, 7]));

	p = p - (~pSineWindow.(0, 0.1) + (~pSineWindow.(1, 0.2) * 0.25));

	agent[\pPlay] = p;

	agent[\durMap] = Prand([1, 0.5, 0.25, 0.75], inf);
	agent[\velMap] = ~defaultVelMap * 0.4 + {[0, 0, 0, 0, 0, 10 + 5.rand].choose};
	agent[\quant] = nil;

	agent[\pRetry] = {|x, y, agent| 0.25 };

	agent[\lenMap] = Prand([0.5, 1, 0.75], inf) * 8;


	agent[\act] = ~piano;
	agent[\echo] = false;
	agent[\active] = i < activeAgents;
};

)