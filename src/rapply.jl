# rapply.jl

"""
    rapply

r[oll]apply fun over a moving window
""" rapply

function rapply(datasource::, windowspec, fun::Function, )

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