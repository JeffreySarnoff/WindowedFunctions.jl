
#### using constitutive parts

```
ohlcv(open, high, low, close, vol) =
   (; open, high, low, close, vol)

open, close, vol = map(x->a[x], (:open, :close, :vol))
high, low, vol = map(x->a[x], (:high, :low, :vol))

ocv(ohlcv) =
  (open = ohlcv.open, close = ohlcv.close, vol = ohlcv.vol)

hlv(ohlcv) =
  (high = ohlcv.high, low = ohlcv.low, vol = ohlcv.vol)

weighted_change(ocv) = (ocv.close - ocv.open) * log(ocv.vol)

weighted_movement(hlv) = (hlv.high - hlv.low) * log(hlv.vol)

price_dynamism(ohlcv) = 
  weighted_change(ocv(ohlcv)) * weighted_movement(hlv(ohlcv))


data = open_high_low_close_volume 
Defining a window-ready function of 6 args 
from two constitutive functional parts.

`fn(v1,v2,v3,v4,v5,v6) = fnab(fna(v1, v2, v3), fnb(v3, v4, v5))`

----