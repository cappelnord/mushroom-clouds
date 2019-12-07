(mode == \visualize).if({
	// window size of viszalization
	var w = 1920;
	var h = 1080;
	var window = Window("Probability Distribution per Note", Rect(300, 300, w, h), false);

	// see help file for Pen
	window.drawFunc = {
		var noteHeight = h.asFloat / notes.size;

		// guess max probability for normalizing (this is a bit dumb)
		var max = 0.0;
		var min = 1.0;
		10000.do {
			var value = playProbabilityFunc.value(1.0.rand, 1.0.rand);
			(value > max).if {max = value;};
			(value < min).if {min = value;};
		};
		("max: " ++ max).postln;
		("min: " ++ min).postln;


		Pen.width = 1;
		Pen.smoothing = false;

		// let's move from x to y
		w.do {|px|
			var x = px / w.asFloat;

			// calc probabilities on all y
			var bins = ();
			(0, 0.001..1).do {|y|
				var probability = playProbabilityFunc.value(x, y);
				var note = noteForY.value(y);
				bins[note].isNil.if {bins[note] = List()};
				bins[note].add(probability);
		    };

			// calculate the mean values
			bins = bins.collect({|list| list.mean});

			// draw a line; note for note!
			bins.keys.do {|note|
				var py = h - (yForNote.value(note) * h);
				var grey = (bins[note] / max).min(1).sqrt;
				// grey.postln;
				Pen.strokeColor = Color.grey(grey);
				Pen.line(Point(px, py), Point(px, py - noteHeight));
				Pen.stroke;
			};
		};
		"done".postln;
	};
	window.refresh;
	window.front;
});