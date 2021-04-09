(
"mc-engine.scd".loadRelative;

~initWorld.();

// ~piano = ~initMIDIOut.("Microsoft GS Wavetable Synth");
// ~piano = ~initMIDIOut.("Yamaha USB-MIDI-1");

"mc-viz.scd".loadRelative;
~initViz.value("127.0.0.1", 57140, 6, 0.04, ~scanYFunc.value(1080));

// "mc-eno.scd".loadRelative;
// ~eno = ~initEnoOut.();

// ~initMIDICC.((1..8), "LPD8");
// ~initMIDICC.((11..18), "LPD8");

~initLoadFungi.(Document.current.dir ++ "/fungi");
~initAgents.(32);

)