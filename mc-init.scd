(
"mc-engine.scd".loadRelative;

~initWorld.();
~initLoadFungi.(Document.current.dir ++ "/fungi");

// ~piano = ~initMIDIOut.("Microsoft GS Wavetable Synth");
~piano = ~initMIDIOut.("Yamaha USB-MIDI-1");

"mc-viz.scd".loadRelative;
~initViz.value("127.0.0.1", 57140, 6, 0.025, ~scanYFunc.value(1080));

// "mc-eno.scd".loadRelative;
// ~eno = ~initEnoOut.();

// ~initMIDICC.((1..8), "LPD8");
// ~initMIDICC.((11..18), "LPD8");

~initAgents.(32);
)