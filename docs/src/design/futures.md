## __FUTURE CAPABILITIES (maybe)__

#### _these operations are under consideration_

### Proportional Tapering

The call to `running` above has three keyword arguments.  In the first example,
their default values were used.  Fully elaborated, that call becomes:
> `running(sum, width, data; padding=nopadding, atend=false, scale=false)`

To scale tapered value by `width / current_taper_length`,use `scale=true`.

``` julia
# using sum with scaled tapering (at start, the default)
        (1 * 3/1,), ((1+2) * 3/2), (1+2+3), (2+3+4), (3+4+5), (4+5+6)
        (3.0,         4.5,          6.0,     9.0,     12.0,    15.0)
running(sum, width, data; scale=true)              == (3.0, 4.5, 6.0, 9.0, 12.0, 15.0)
running(sum, width, data; atend=false, scale=true) == (3.0, 4.5, 6.0, 9.0, 12.0, 15.0)

# using sum with scaled tapering at the end
        (1+2+3), (2+3+4), (3+4+5), (4+5+6), ((5+6) * 3/2,), (6 * 3/1,)
        (6.0,     9.0,     12.0,    15.0,    16.5,           18.0)
running(sum, width, data; atend=true, scale=true) == (6.0, 9.0, 12.0, 15.0, 16.5, 18.0)
```

### Hopping

_this is the general case for moving windows_

``` julia
data      = [1, 2, 3, 4, 5, 6]  # here, a single vector
nitems    = n  # length(data)
width     = w  # a window covering `w` indices at a time
slide     = s  # the window advances in steps of `±s` indices
hop       = h  # the window skips `±h` indices before sliding
indexfrom = i  # the initial window starts at index `i`
```

_`slide`, `hop`, `indexfrom` must make sense given `nitems` and `width`_

#### constraints

- `1 <= width     <= nitems`
- `1 <= indexfrom <= nitems`
- `(width-nitems) <= slide <= (nitems-width)`
- `(width-nitems) <= hop   <= (nitems-width)`

#### orientation

`orientation = sign(hop + slide)`

- orientation is positive
  - the window moves from lower indices to higher indices
  - `indexfrom + width <= nitems`
- orientation is negative
  - the window moves from higher indices to lower indices
  - `indexfrom - width >= 1`
- orientation is zero
  - (the moving window does not move)
  - the function is applied once, the result is a single value
  - _it is likely that this is a client error_

###  Windowing in 2D

Substantive image processing becomes available with 2D moving windows.

- __image__ [is an image stored as] pixel values within a [rectangular] matrix.
- winsize = (rows spanned, columns spanned) by the window
- winoffset = winsize .- 1
- winmove = advance window by (nrows, ncolumns)
- winstart = (initial row, initial column) for window upper left
- winstop  = winstart .+ winoffset

##### _the initial and the next windows_

``` julia
Base.:(+)(start::T, move::T) where {I<:Integer, T<:NTuple{2,I}} =
    (start[1]+move[1], start[2]+move[2])
Base.:(-)(start::T, move::T) where {I<:Integer, T<:NTuple{2,I}} =
    (start[1]-move[1], start[2]-move[2])

image = reshape(1:5^2, (5,5))
#= 5×5 reshape(::UnitRange{Int64}, 5, 5) with eltype Int64:
 1   6  11  16  21
 2   7  12  17  22
 3   8  13  18  23
 4   9  14  19  24
 5  10  15  20  25
=#

winstart = (1, 1)
winstop  = (3, 3)
winmove  = (2, 2)

intial_window_content =
    image[CartesianIndex(winstart):CartesianIndex(winstop)]
#= 3×3 Matrix{Int64}:
 13  18  23
 14  19  24
 15  20  25
=#

winstart += winmove
winstop  += winmove

next_window_content =
   image[CartesianIndex(winstart):CartesianIndex(winstop)]
#= 3×3 Matrix{Int64}:
 13  18  23
 14  19  24
 15  20  25
=#
```

