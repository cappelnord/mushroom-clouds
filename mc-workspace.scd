
// Mushroom Clouds

~runAgents.(60 * 8, {|i| i * 0.125})

// TODO: put closest freq ratio in
// TODO: Absichern wenn mal Fehler passieren
// TODO: Scale Weight Filter
// TODO: Fungi-Sampling über komplette Taste
// TODO: Schauen was passiert mit OSC Fehlern in Processing
// TODO: Schauen wieso die Grafik irgendwie verzerrt dargestellt wird; gibt's irgendwo noch eine Transferkurve die angewandt wird?
// TODO: combine Funktion
// TODO: kann lenMap Pattern sein?
// TODO: Poster machen
// TODO: ~cc that smooth over time
// TODO: MIDI-Noten & Velocities clippen max/min



/*
"Agaricus sp."
"Amanita rubescens"
"Clathrus archeri"
"Coprinellus disseminatus"
"Coprinellus micaceus"
"Coprinopsis picacea"
"Fomitopsis pinicola"
"Helvella lacunosa"
"Laetiporus sulphureus"
"Lepiota aspera"
"Lycoperdon excipuliforme"
"Macrolepiota fuliginosa"
"Pleurotus ostreatus Mycel"
"Pleurotus ostreatus"
"Russula sp."
"Schizophyllum commune"
"Sparassis crispa"
"Trametes versicolor"
"Tremella mesenterica"
"Xerocomellus sp."
*/


~pedSustain.(0, 2)

(
var activeAgents = 32;

~wAgents.do {|agent, i|
	// {|x, y, agent| 1.0 }

	agent[\act] = ~piano;
	agent[\durMap] = Prand([1, 1/3.0, 2/3.0, 0.5], inf);
	agent[\velMap] = ~defaultVelMap * 1.0 * {|x, y| y};
	agent[\quant] = 2;

	agent[\pPlay] = ~pFungus.("Pleurotus ostreatus Mycel");

	agent[\pRetry] = {|x, y, agent| 0.96 };

	agent[\lenMap] = 8;


	agent[\echo] = true;
	agent[\active] = i < activeAgents;
};

)