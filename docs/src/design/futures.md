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

###  Varying Window Width

Here is a copy of the initial `rolling` example
```
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

There are situations where working without the constraint
of a fixed window width is helpful. Specifying successive
window widths is supported; the sum of these widths, along
with the optional keywords `padding` and `atend`,  is used
to determine the data that is spanned by all of the windows.

- `rolling` with multiple window widths assumes each window follows the prior, beginning at `prior_start+1` and finishing at `prior_start+current_window_width` (inclusive).

```
data   = [1, 2, 3, 4, 5, 6]  # here, a single vector
widths = [2, 2, 4]  # a window covering 3 indices at a time
slide  = 1  # the window advances in steps of 1 index

# the moving windows cover
        (1,2), (2,3), (3,4,5,6)   # windowed data

# using sum
        (1+2), (2+3), (3+4+5+6)
        (3,     5,       18)      # the result

rolling(sum, widths, data) == (3, 5, 18)  # this package
```

- `tiling` with multiple window widths assumes the windows are immediately adjacent, beginning at `prior_end+1` and finishing at `prior_end+current_window_width` (inclusive).

```
data   = [1, 2, 3, 4, 5, 6]  # here, a single vector
widths = [1, 2, 3]  # a window covering 3 indices at a time
slide  = [1, 2, 3]  # the window advances by each width

# the moving windows cover
        (1,), (2,3), (4,5,6)   # windowed data

# using sum
        (1), (2+3), (4+5+6)
        (1,     5,   15)      # the result

tiling(sum, widths, data) == (1, 5, 15)  # this package
```

- `running` with multiple window widths assumes each window follows the prior, beginning at `prior_start+1` and finishing at `prior_start+current_window_width` (inclusive).
   - use `padding` (with `atend` if needed), it is ignored unless needed

```
data   = [1, 2, 3, 4, 5, 6]  # here, a single vector
widths = [2, 2, 3]  # a window covering 3 indices at a time
slide  = 1  # the window advances in steps of 1 index
atend  = false # fill in the first value(s)

# the moving windows cover
        (2,3), (3,4), (4,5,6)   # windowed data
# tapering covers
 (1,),  (2,3), (3,4), (4,5,6)   # windowed data

# using sum
        (1,), (2+3), (3+4), (4+5+6)
        (1,    5,     7,     15)      # the result

running(sum, widths, data) == (1, 5, 7, 15)  # this package
```


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

#### _moving through a recursive Z pattern_

uses
- [erosion, dilation, opening, closing, thinning, thickening](https://homepages.inf.ed.ac.uk/rbf/HIPR2/hitmiss.htm)

max indices

```
# 2D
julia> x=2^16; morton=cartesian2morton([x,x]); match= ([x,x]==morton2cartesian(morton));
julia> (; coords=:xy, x, morton, match)
(coords = :xy, x = 65536, morton = 4294967296, match = true)

# 3D
julia> x=2^10; morton=cartesian3morton([x,x,x]); match= ([x,x,x]==morton3cartesian(morton));
julia> (; coords=:xyz, x, morton, match)
(coords = :xyz, x = 1024, morton = 1073741824, match = true)

```

refs
- [wikipedia](https://en.wikipedia.org/wiki/Z-order_curve)
- [Morton coding](https://github.com/JaneliaSciComp/Morton.jl)
- [TiledViews](https://github.com/bionanoimaging/TiledViews.jl)
- [TiledIteration](https://github.com/JuliaArrays/TiledIteration.jl)
