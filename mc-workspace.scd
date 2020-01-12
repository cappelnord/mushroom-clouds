// TODO: ~cc that smooth over time

// Mushroom Clouds

~runAgents.(60 * 8, {|i| i * 0.125})

// TODO: put closest freq ratio in
// TODO: Absichern wenn mal Fehler passieren
// TODO: Scale Weight Filter
// TODO: Fungi-Sampling über komplette Taste
// TODO: Schauen was passiert mit OSC Fehlern in Processing
// TODO: Schauen wie es mit Neu-Würfel ist, sollte auch exposed sein in Worksapce
// TODO: Schauen wieso die Grafik irgendwie verzerrt dargestellt wird; gibt's irgendwo noch eine Transferkurve die angewandt wird?
// TODO: combine Funktion
// TODO: kann lenMap Pattern sein?
// TODO: MIDI Velocities clippen. Agent-Flag ob MIDI geposted werden soll (schön formatiert)
// TODO: Intervall-Filter
// TODO: Poster machen

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
	agent[\quant] = 1;

	agent[\pPlay] = ~pFungus.("Pleurotus ostreatus Mycel") * ~pScale.([0,1]);

	agent[\pRetry] = {|x, y, agent| 0.55 };

	agent[\lenMap] = 1;

	agent[\active] = i < activeAgents;
};

)