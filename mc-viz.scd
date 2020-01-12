var vizNet;

~scanYFunc = {|height|
	var state = 0.0;
	var delta = 1.0 / height;
	{
		state = state + delta;
		(state > 1.0).if { state = state - 1.0 };
		state;
	}
};

~initViz = {|host, port, num=2, interval=0.02, yFunc|
	vizNet = NetAddr(host, port);
	yFunc = yFunc ? {1.0.rand};

	~wViz = {|tFunc|
		"wViz".postln;
		~wAgents.do {|agent, i|
			agent[\vizRoutine] = Routine({
				var t = 0;

				{t < 1.0}.while {

					var vals = List();
					num.do {
						var y = yFunc.value;
						var value = agent[\pPlay].value(t, y, agent).min(1).max(0).sqrt.sqrt;
						vals.add(t);
						vals.add(y);
						vals.add(value);
					};

					vizNet.sendMsg("/m", *vals);

					t = tFunc.value;
					interval.wait;
				};
			}).play(TempoClock.default);
		};
	};
};

~clearViz = {
	vizNet.isNil.not.if {
		vizNet.sendMsg("/clear");
	}
}