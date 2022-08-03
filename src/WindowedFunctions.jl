module WindowedFunctions


"""
With ndata = length(data), using a window of length windowsize, 
rolling a function results in a vector of ndata - windowsize + 1 elements.

So there will be obtained (windowsize - 1) fewer values than there are data values.
All exported rfunctions used with `rollfun` behave this way.
"""
rollfun

"""
With ndata = length(data), using a window of length windowsize,
To obtain the same number of output data values as are given in the input data,
the initial (windowsize - 1) values output must be generated outside of the rolling behavior.

This is accomplished by tapering the needed values -- using the same function, 
rolling it over successively smaller window sizes. 
All exported functions used with `runfun` behave this way.
"""
runfun

"""
The exported functions named `r<fun>` are the applicative engines 
that `rollfun` and `runfun` compose over the windowed data
"""
rfunc, rfuncs, rabs, rmin, rmax, rsum, rmean, rvar, rstd, rwindsorizedmean, rsoftmax, rsoftlog

"""
The exported functions named `rapply`, `rapplyN`
are the generic applicative engines
that are available to use in the construction of new `r<fun>`s.

- `rapply` takes 1..n args
- `rapply1, rapply2, rapply3, rapply4` take 1, 2, 3, 4 args respectively
"""
rapply, rapply1, rapply2, rapply3, rapply4


export runfun, rollfun
       rapply, rapply1, rapply2, rapply3, rapply4,
       rabs, rmin, rmax, rsum, rmean, rvar, rstd,
       rwindsorizedmean, rsoftmax, rsoftlog


include("rapidwindowing.jl")
include("rapply.jl")
include("rollfun.jl")
include("runfun.jl")
include("rfuncs_unary.jl")
include("rfuncs_binary.jl")

end  # WindowedFunctions

