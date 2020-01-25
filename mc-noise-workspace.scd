x = {|n| n*50*3 * 4 % 1.0};

a = ~nGenerateBuffer.(~pFungus.("Trametes versicolor"), x,  {|n| n}, 30);
b = ~nGenerateBuffer.(~pFungus.("Amanita rubescens"), x,  {|n| n}, 30);
c = ~nGenerateBuffer.(~pFungus.("Lepiota aspera"), x,  {|n| n}, 30);
d = ~nGenerateBuffer.(~pFungus.("Russula sp."), x,  {|n| n}, 30);
e = ~nGenerateBuffer.(~pFungus.("Coprinopsis picacea"), x,  {|n| n}, 30);
f = ~nGenerateBuffer.(~pFungus.("Lepiota aspera"), x,  {|n| n}, 30);
g = ~nGenerateBuffer.(~pFungus.("Pleurotus ostreatus"), x,  {|n| n}, 30);


// this is nice! BUt try interpolated
{PlayBuf.ar(1, [b, f])}.play

s.scope