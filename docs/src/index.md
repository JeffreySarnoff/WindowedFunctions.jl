#### functions move over data windows

       data into subparts
       subparts recieve focus as windows move
       functions apply to successive subparts
       window reveals subpart values
       function applies over window onto subpart



|                                                       |
|:-----------------------------------------------------:|
| WindowedFunctions.jl © 2017-2023 by Jeffrey Sarnoff   |
|                                                       |

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
