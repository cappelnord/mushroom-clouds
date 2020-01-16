
// Mushroom Clouds


// TODO: Konkreten Anfang machen.
// TODO: Come up with Anfang / Come up with Ende

/* REMOVE
Scale.bartok  Scale.scriabin  Scale.harmonicMinor
Scale.minor  Scale.melodicMinorDesc
*/

/*
ANFANG: Mit Pedal! Auch um das C herum spielend. Dann mit Vel-Choose Funktion einzelne lautere Tasten integrieren.

Wenn es mehr chromatisch/dichter wird dann Pedal weg, kürzere Töne.
Dafür mit harmonic combs. Breitere Harmonic Combs wirken auch gleich
mehr wie Melodien, weniger wie Pattern.

ENDE: Mit Pedal! Mit Tremella multiplizieren?

*/

/*
"Agaricus sp."  "Sparassis crispa"  "Lycoperdon excipuliforme"
"Coprinellus micaceus" "Coprinellus disseminatus"  "Pleurotus ostreatus"
"Clathrus archeri" "Coprinopsis picacea"
"Laetiporus sulphureus"  "Trametes versicolor"
"Amanita rubescens"  "Macrolepiota fuliginosa"
"Fomitopsis pinicola"  "Helvella lacunosa"  "Pleurotus ostreatus Mycel"
"Lepiota aspera"  "Russula sp."  "Xerocomellus sp."
"Schizophyllum commune"  "Tremella mesenterica"
*/

~runAgents.(60 * 8, {|i| i * 0.625})

~pedSustain.(127, 2)

(
var activeAgents = 32;

~storeAllAgents.();

~wAgents.do {|agent, i|
	// {|x, y, agent| 1.0 }

	var p1 = ~pFungus.("Pleurotus ostreatus").pow(2);
	var p2 = ~pFungus.("Pleurotus ostreatus Mycel").pow(2);

	agent[\pPlay] = p1;

	agent[\act] = ~piano;
	agent[\durMap] = Prand([1, 0.5, 0.25, 0.75], inf);
	agent[\velMap] = ~defaultVelMap * 0.6 + {[0,0,0,0, 40].choose};
	agent[\quant] = nil;

	agent[\pRetry] = {|x, y, agent| 0.55 };

	agent[\lenMap] = Prand([0.5, 1, 0.25], inf) * 4;

	agent[\echo] = false;
	agent[\active] = i < activeAgents;
};

)