module WindowedFunctions

using Tables, TableOperations, TableTransforms
using CSV, DataFrames

using StatsFuns: logistic, logit, 
      log1psq, log1pmx, logmxp1,
      logexpm1, log1pexp, log1mexp, log2mexp,
      logsumexp, softplus, invsoftplus, softmax

using StatsBase: wsum, variant, sem, span, mad, 
      wmean, geomean, harmmean, genmean,
      aweights, eweights, fweights, pweights, uweights, weights

using OnlineStats: EqualWeight, ExponentialWeight, HarmaonicWeight, McclainWeight, LearningWeight, LearningWeight2,
      smooth, smooth!, Quantile, Moments, AutoCov

using LogExpFunctions: xlogx, xexpx, logcosh, 
      logsumexp!, softmax!, cloglog, cexpexp,
      # 2-arg functions
      xlogy, xlog1py, xexpy, logaddexp, logsubexp

using Distances: euclidean, sqeuclidean, peuclidean, cityblock, totalvariation, jaccard, braycurtis, rogerstanimoto, chebyshev, minkowski,
      hamming, cosine_dist, corr_dist, chisq_dist, kl_divergence, gkl_divergence, js_divergence, renyi_divergence,
      spannorm_dist, weuclidean, wsqeuclidean, wcityblock, wminkowski, whamming, sqmahalanobis, mahalanobis, bhattacharyya,
      hellinger, bregman,
      haversine, spherical_angle,
      meanad, msd, rmsd, nrmsd

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

include("exceptions.jl")
include("types.jl")
include("support_functions.jl")

include("rapidwindowing.jl")
include("rapply.jl")
include("rollfun.jl")
include("runfun.jl")
include("rfuncs_unary.jl")
include("rfuncs_binary.jl")

end  # WindowedFunctions

