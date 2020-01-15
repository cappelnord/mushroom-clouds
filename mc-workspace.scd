
// Mushroom Clouds

~runAgents.(60 * 8, {|i| i * 0.125})

// TODO: Absichern wenn mal Fehler passieren
// TODO: !!! Schauen was passiert mit OSC Fehlern in Processing !!!
// TODO: Poster machen
// TODO: ~cc that smooth over time
// TODO: Wenn ein Agent einen fehler wirft dann läuft er nicht mehr weiter

// TODO: Pilze sortieren
// TODO: Skalen raussuchen
// TODO: Come up with Anfang / Come up with Ende

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
~pedCorda.(0, 2)

(
var activeAgents = 32;

~wAgents.do {|agent, i|
	// {|x, y, agent| 1.0 }

	var p1 = ~pFungus.("Fomitopsis pinicola").pow(2);
	var p2 = ~pFungus.("Tremella mesenterica").pow(2);

	agent[\pPlay] = ~pPart.({|x| (x*200).sin.abs}, p1, p2) * ~pScale.(Scale.major, 0) - ~pSineWindow.(0, 0.2) * ~pHarmonicComb.(200, (1..12), 0.4);

	agent[\act] = ~piano;
	agent[\durMap] = Prand([0.5, 1.5, 1, 4], inf);
	agent[\velMap] = ~defaultVelMap;
	agent[\quant] = nil;

	agent[\pRetry] = {|x, y, agent| 0.9 };

	agent[\lenMap] = Prand([0.5, 1, 0.25], inf) * 3;

	agent[\echo] = true;
	agent[\active] = i < activeAgents;
};

)