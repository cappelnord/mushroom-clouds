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
		~wAgents.do {|agent, i|
			agent[\vizRoutine] = Routine({
				var t = 0;

				{t < 1.0}.while {

					{
						agent[\active].if {
							var vals = List();
							var activeAgents = ~wAgents.count({|x| x[\active]});
							var thisNum = (num * (~wAgents.size / activeAgents.asFloat)).ceil;
							thisNum.do {
								var y = yFunc.value;
								var value = agent[\pPlay].value(t, y, agent).min(1.0).max(0.0);
								vals.add(t.asFloat);
								vals.add(y.asFloat);
								vals.add(value.asFloat);
							};

							vizNet.sendMsg("/m", *vals);
							t = tFunc.value;
						};
					}.try;
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