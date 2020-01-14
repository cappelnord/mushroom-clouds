
// Mushroom Clouds

~runAgents.(60 * 8, {|i| i * 0.125})

// TODO: put closest freq ratio in (Eventuell refaktorieren)
// TODO: Absichern wenn mal Fehler passieren
// TODO: Scale Weight Filter
// TODO: Fungi-Sampling über komplette Taste
// TODO: Schauen was passiert mit OSC Fehlern in Processing
// TODO: Poster machen
// TODO: ~cc that smooth over time


/*
"Agaricus sp."  "Amanita rubescens"  "Clathrus archeri"
"Coprinellus disseminatus"  "Coprinellus micaceus"  "Coprinopsis picacea"
"Fomitopsis pinicola"  "Helvella lacunosa"  "Laetiporus sulphureus"
"Lepiota aspera"  "Lycoperdon excipuliforme"  "Macrolepiota fuliginosa"
"Pleurotus ostreatus Mycel"  "Pleurotus ostreatus"  "Russula sp."
"Schizophyllum commune"  "Sparassis crispa"  "Trametes versicolor"
"Tremella mesenterica"  "Xerocomellus sp."
*/

~pedSustain.(0, 2)
~pedCorda.(127, 2)

(
var activeAgents = 32;

~wAgents.do {|agent, i|
	// {|x, y, agent| 1.0 }

	var p1 = ~pFungus.("Agaricus sp.").pow(2);
	var p2 = ~pFungus.("Pleurotus ostreatus Mycel").pow(2);

	var windows = [3, 8, 13, 20].collect {|i| ~pSineWindow.({|x| (x*i).sin.abs}, 0.3)};


	agent[\pPlay] = p1 * windows.sum.min(1).max(0) * ~pScale.([7], 0) - ~pSineWindow.(1, 0.7) + (p2 * 0.3) + ~pInterval.([-1, 1, -2, 2]) * ~pScale.(Scale.minorPentatonic);

	agent[\act] = ~piano;
	agent[\durMap] = Prand([0.5, 1, 0.75,2, 4], inf);
	agent[\velMap] = ~defaultVelMap * 0.9;
	agent[\quant] = nil;



	agent[\pRetry] = {|x, y, agent| 0.7 };

	agent[\lenMap] = 4;


	agent[\echo] = false;
	agent[\active] = i < activeAgents;
};

)