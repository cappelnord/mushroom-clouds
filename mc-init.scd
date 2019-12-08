(
"mc-engine.scd".loadRelative;

~initWorld.();
~initLoadFungi.(Document.current.dir ++ "/fungi");

~piano = ~initMIDIOut.("Microsoft GS Wavetable Synth");
// ~piano = ~initMIDI.("Yamaha USB-MIDI-1");

// "mc-eno.scd".loadRelative;
// ~eno = ~initEnoOut.();

// ~initMIDICC.((1..8), "LPD8");
// ~initMIDICC.((11..18), "LPD8");

~initAgents.(32);
)