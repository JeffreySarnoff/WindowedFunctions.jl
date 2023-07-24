
__This package lets you apply functions over data through moving windows, providing insight.__

|                                                       |
|:-----------------------------------------------------:|
| WindowedFunctions.jl © 2017-2023 by Jeffrey Sarnoff.  |
| This work product is released under the MIT License.  |
|                                                       |

## a function, a moving window, and a data sequence

### rolling

```
data  = [1, 2, 3, 4, 5, 6]
width = 3 # a window covering 3 indices at a time
slide = 1 # the window advances in steps of 1 index
the moving window covers
        (1,2,3), (2,3,4), (3,4,5), (4,5,6)   # windowed data
using sum
        (1+2+3), (2+3+4), (3+4+5), (4+5+6)
        (6,       9,       12,      15)      # the result

rolling(sum, width, data) == (6, 9, 12, 15)  # this package
```

_`rolling` means the slide == 1_
With basic `rolling`, the result has `length(data) - (width - 1)` entries.
Often, it is useful to generate a result with length matching the length of the data.
This requires `padding` the `(width - 1)` entries that would have been omitted
with some designated filler value. These fillers may be placed at the start of
the result or at the end of the result.

The call to `rolling` above has two keyword arguments.  In the first example,
their default values were used.  Fully elaborated, that call becomes:
> `rolling(sum, width, data; padding=nopadding, atend=false)`

```
data    = [1, 2, 3, 4, 5, 6]
width   = 3 # a window covering 3 indices at a time
slide   = 1 # the window advances in steps of 1 index
padding = 0 # the filler value

the moving window covers
        (1,2,3), (2,3,4), (3,4,5), (4,5,6)   # windowed data

using sum
        (6,       9,       12,      15)      # the result
rolling(sum, width, data) == (6, 9, 12, 15)  # this package

using sum with padding (at start, the default)
        (0, 0, 6, 9, 12, 15)                 # the result
rolling(sum, width, data; padding=0) == (0, 0, 6, 9, 12, 15)

using sum with padding at the end
        (6, 9, 12, 15, 0, 0)                 # the result
rolling(sum, width, data; padding=0, atend=true) == (6, 9, 12, 15, 0, 0)
```
### tiling







       data into subparts
       subparts recieve focus as windows move
       functions apply to successive subparts
       window reveals subpart values
       function applies over window onto subpart





### Worked Examples

Each method is shown, examples clarify proper use.
Concepts are illustrated and developed with shared data.

----

##### in three different ways

- [__rolling__](approach/rolling.md)
- [__tiling__](approach/tiling.md)
- [__running__](approach/running.md)

##### optionally specifying

- [__weights__](approach/weights.md)
- [__padding__](approach/padding.md)
- [__pad placement__](approach/atend.md)

##### with these data sequences

- [__datastreams__](approach/datastreams.md)


----

## Capabilities

----

#### __padding__
###### - extends the length of an obtained result
###### - may be placed at the start or at the end of the result
###### - is controlled with keyword args

| _keyword_  | _default_    | _action_     |
|:-----------|:-------------|:-------------|
| `padding`  | `nopadding`  | do not pad   |
| `atend`    | false        | pad at start |

   - where `padding = nopadding`, `atend` is ignored.
-----

#### __data sources__

##### sequence
- _unweighted_
   - ≺ rolling | tiling | running ≻(fn, width, seq)
- _weighted_
   - ≺ rolling | tiling | running ≻(fn, width, seq, weights)

##### multisequence
- _unweighted_
   - ≺ rolling | tiling | running ≻(fn, width, seq1, seq2)
   - ≺ rolling | tiling | running ≻(fn, width, seq1, seq2, seq3)
- _weighted_
   - ≺ rolling | tiling | running ≻(fn, width, seq1, seq2, _weighting_)
   - ≺ rolling | tiling | running ≻(fn, width, seq1, seq2, seq3, _weighting_)


| multisequence     |   |      signature                                            |
|:------------------|---|:----------------------------------------------------------|
|                   |   | ≺ rolling \| tiling \| running ≻(fn, width, _`rest`_...)  |
|                   |   | _`rest`_ are the remaining args, they follow `width`      |
|                   |   |                                                           |
| _unweighted_      |   |                                                           |
|                   |   |(seq1, seq2)                                               |
|                   |   |(seq1, seq2, seq3)                                         |
|                   |   |                                                           |
| _shared weights_  |   |                                                           |
|                   |   |(seq1, seq2, weights)                                      |
|                   |   |(seq1, seq2, seq3, weights)                                |
|                   |   |                                                           |
| _unique weights_  |   |                                                           |
|                   |   |(seq1, seq2, [weights1, weights2])                         |
|                   |   |(seq1, seq2, seq3, [weights1, weights2, weights3])         |
|                   |   |                                                           |




##### matrix

- columns are data sequences
   - _each column is processed independently_
   - _the windowed fn is applied columnwise_

###### _unweighted_
- ≺ rolling | tiling | running ≻(fn, width, datamatrix)

###### _weighted (shared weights)_
- ≺ rolling | tiling | running ≻(fn, width, datamatrix, weights)

###### _weighted (column weights)_
 - ≺ rolling | tiling | running ≻(fn, width, datamatrix, weightmatrix)


----
