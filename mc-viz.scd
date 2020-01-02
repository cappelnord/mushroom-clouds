~initViz = {|host, port, num=2, interval=0.02, yFunc|
	var net = NetAddr(host, port);
	yFunc = yFunc ? {1.0.rand};

	~wViz = {|tFunc|
		"wViz".postln;
		~wAgents.do {|agent, i|
			agent[\vizRoutine] = Routine({
				var t = 0;

				{t < 1.0}.while {

					num.do {
						var y = yFunc.value;
						var value = agent[\pPlay].value(t, y, agent).min(1).max(0).sqrt.sqrt;
						net.sendMsg("/m", t, y, value);
					};

					t = tFunc.value;
					interval.wait;
				};
			}).play(TempoClock.default);
		};
	};
}