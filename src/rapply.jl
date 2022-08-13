# rapply.jl
zab=zip(a,b)
c=collect(zab)
julia > #map(r->sum(view(data,r)),c)
julia > #c=map(x->UnitRange(x...),c)

r = map(z -> UnitRange(z...), c)
map(sum, view.(Ref(data), r))

julia> @btime view.(Ref($dataview),$r);
  1.460 μs (2 allocations: 20.05 KiB)

julia> @btime map(sum,view.(Ref($dataview),$r));
  16.700 μs (3 allocations: 24.17 KiB)

julia> @btime map(i->sum(view($dataview,i)), $r);
  14.300 μs (1 allocation: 4.12 KiB)

julia> @btime sumview.(Ref($dataview),$r);
  14.600 μs (1 allocation: 4.12 KiB)
"""
    rapply

r[oll]apply fun over a moving window
""" rapply

function rapply(data_source::AT, window_spec::NT, fun::Function, ) where {NT<:NamedTuple, N,T, AT<:AbstractArray{T,N}}

"""
    rspecifer characterizes an rapply-able function

    - arity into each rapplication, arity out of each rappliction
        - e.g   (1->1, 1->2, 2->1, 2->2, 2->3, 3->1, 3->2, ..)
        - softmax is 1->1, extrema is 1->2, intraday change is 2->1 ..
    - src[s] and dest[s] wrt arities

    - rfunc to use
    - any preprocessign func/op/filter, any postprocessung func/op/filter

    - any exceptional values and their handling (from  srcs and into dests)
    - any limitations
""" rspecifier

const rapplicative_fieldnames = (:arityin, :arityout, :sourcesin, :destsout,
                                 :rapplicative,
                                 :preprocessing, :postprocessing)

const RapplicativeSpecifier = NamedTuple{rapplicative_fieldnames}