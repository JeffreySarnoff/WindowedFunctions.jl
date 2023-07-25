__under construction__
(_see tests_)


##### [approaching `datastreams`](../approach/datastreams.md)

## Supported Data Sequences


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
