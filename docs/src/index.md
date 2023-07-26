

# Introducing Windowed Functions
#### __apply functions over data through moving windows__

|                                                       |
|:-----------------------------------------------------:|
| WindowedFunctions.jl © 2017-2023 by Jeffrey Sarnoff.  |
| This work product is released under the MIT License.  |
|                                                       |

## Rolling

``` julia
data  = [1, 2, 3, 4, 5, 6]  # here, a single vector
width = 3  # a window covering 3 indices at a time
slide = 1  # the window advances in steps of 1 index

# the moving window covers
        (1,2,3), (2,3,4), (3,4,5), (4,5,6)   # windowed data

# using sum
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

``` julia
data    = [1, 2, 3, 4, 5, 6]
width   = 3 # a window covering 3 indices at a time
slide   = 1 # the window advances in steps of 1 index
padding = 0 # the filler value

# the moving window covers
        (1,2,3), (2,3,4), (3,4,5), (4,5,6)   # windowed data

# using sum
        (6,       9,       12,      15)      # the result
rolling(sum, width, data) == (6, 9, 12, 15)  # this package

# using sum with padding (at start, the default)
        (0, 0, 6, 9, 12, 15)                 # the result
rolling(sum, width, data; padding=0) == (0, 0, 6, 9, 12, 15)

# using sum with padding at the end
        (6, 9, 12, 15, 0, 0)                 # the result
rolling(sum, width, data; padding=0, atend=true) == (6, 9, 12, 15, 0, 0)
```
## Tiling

`tiling` slides the window just past its current ending index.
- it is similar to `rolling`, and it is used the same way.

``` julia
data  = [1, 2, 3, 4, 5, 6]  # here, a single vector
width = 3      # a window covering 3 indices at a time
slide = width  # the window advances over itself

# the moving window covers
        (1,2,3), (4,5,6)      # windowed data

# using sum
        (1+2+3), (4+5+6)
        (6,       15,  )      # the result

tiling(sum, width, data) == (6, 15)  # this package
```
In the above example, all of the data was used (seen by the moving window).
When `tiling`, that occurs if and only if `mod(length(data), width) == 0`.
Otherwise, one or more (at most `width-1`) data items will not be seen.

The call to `tiling` above has two keyword arguments.  In the first example,
their default values were used.  Fully elaborated, that call becomes:
> `tiling(sum, width, data; padding=nopadding, atend=false)`

``` julia
data  = [1, 2, 3, 4, 5, 6, 7, 8]
width = 3      # a window covering 3 indices at a time
slide = width  # the window advances over itself
omitted = mod(length(data), width) # 2 indices do not contribute to the result

# the moving window either
#       covers [default]  or  covers [atend=true]
        (1,2,3), (4,5,6)      (3,4,5), (6,7,8)    # the possible windowed data

# using sum
        (1+2+3), (4+5+6)  or  (3+4+5), (6+7+8)
        (6,       15,  )      (12,      21   )    # the possible results

tiling(sum, width, data) == (6, 15)               # this package
tiling(sum, width, data; atend=true) == (12, 21)  # this package
```

When `tiling` covers the data incompletely, `padding` is available:

- if there is an incomplete tile `mod(length(data), width) != 0`
- that omitted tile is replaced with the padding value
- at most 1 tile is incomplete, so there can be at most 1 index padded

``` julia
tiling(sum, width, data; padding=missing)              == (missing, 6, 15)
tiling(sum, width, data; padding=missing, atend=false) == (missing, 6, 15)
tiling(sum, width, data; padding=missing, atend=true)  == (12, 21, missing)
```

## Running
#### _tapering functions_

Padding is very helpful, it simplifies handling.  It does require selecting
a single value to use as the _pad_. While any value that makes sense within
the context of the data sequence may be used, it is not always obvious what
value is best. If your handling supports (even better, resolves) `missing`,
then that is a fine and generally robust choice.

Otherwise, with numeric data it is desireable to use a padding value that
is unlikely to warp the information you are gathering.  Zero is the neutral
value for additive processing. One is the neutral value for multiplicative
processing.  For more involved processing, any predetermined choice may
be inelegant with certain data sequences.  You may want to take some
local estimator as the pad value, precomputing a short sample.

This package offers an alternative approach, `tapering`.
Rather than pad with a preselected value, `tapering` determines the
values to be appended using the same windowing function over
successively forshortened windows.

#### running functions through moving windows onto data

`running` is a variation on `rolling` that replaces `padding` with `tapering`.

``` julia
data    = [1, 2, 3, 4, 5, 6]
width   = 3 # a window covering 3 indices at a time
slide   = 1 # the window advances in steps of 1 index

# the moving window covers
        (1,2,3), (2,3,4), (3,4,5), (4,5,6)   # windowed data

# using sum
        (1+2+3), (2+3+4), (3+4+5), (4+5+6)
        (6,       9,       12,      15)      # the result

# using sum with tapering (at start, the default)
        (1,), (1+2), (1+2+3), (2+3+4), (3+4+5), (4+5+6)
        (1,    3,     6,       9,       12,      15)      # the result
running(sum, width, data) == (1, 3, 6, 9, 12, 15)         # this package

```

