(
"mc-engine.scd".loadRelative;
"mc-noise.scd".loadRelative;

~initWorld.();
~initLoadFungi.(Document.current.dir ++ "/fungi");
)