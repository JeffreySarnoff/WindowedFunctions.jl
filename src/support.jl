mutable struct MutableInt i::Int end

struct DataSequence{T}
    source::T
    length::Int
end

struct DataWindow{T}
    source::T
    length::Int
    span::MutableInt
    offset::MutableInt
end

function advance(dw::DataWindow)
    if dw.offset + span <= length
        dw.offset += 1
        return dw
    elseif dw.offset + 2 <= length
        dw.offset += 1
        dw.span = dw.span - 1
        return dw
    else
        return nothing
    end
end

function applyover(fn::Function, dw::DataWindow)
    fn(dw.source[dw.offset:dw.offset+dw.span-1])
end

function applyover(fn::Function, dw::DataWindow, p)
    fn(dw.source[dw.offset:dw.offset+dw.span-1], p)
end

Base.minimum(dw::DataWindow) = applyover(minimum, dw)
Base.maximum(dw::DataWindow) = applyover(maximum, dw)
Base.sum(dw::DataWindow) = applyover(sum, dw)
Base.prod(dw::DataWindow) = applyover(prod, dw)
Base.extrema(dw::DataWindow) = applyover(extrema, dw)

norm2(xs) = sqrt(sum(abs2.(xs)))
norm2(dw::DataWindow) = applyover(norm2, dw)

function extremadist(dw::DataWindow)
    lo, hi = extrema(dw)
    hi - lo
end

Statistics.mean(dw::DataWindow) = applyover(mean, dw)
Statistics.median(dw::DataWindow) = applyover(mean, dw)
Statistics.var(dw::DataWindow) = applyover(var, dw)
Statistics.std(dw::DataWindow) = applyover(std, dw)
Statistics.quantile(dw::DataWindow, p) = applyover(quantile, dw, p)



advance(dw::DataWindow) = dw.offset = dw.offset + 1
mayadvance(dw::DataWindow) = dw.length >= dw.offset + 1



mutable struct LinearBounds
    lo::Int
    hi::Int
end

Base.convert(::Type{LinearBounds}, lohi::NTuple{2,Int}) = LinearBounds(lohi[1], lohi[2])

struct WindowIndices
    win::LinearBounds
    all::LinearBounds
end

function win(w::WindowIndices, lohi::NTuple{2,Int})
    w.win.lo = lohi[1]
    w.win.hi = lohi[2]
end

function win(w::WindowIndices, lo::Int, hi::Int)
    w.win.lo = lo
    w.win.hi = hi
end

function advance(w::WindowIndices)
    win(w, w.win.lo+1, w.win.hi+1)
end

function mayadvance(w::WindowIndices)
    w.win.hi < w.all.hi
end

struct MovingValue{T,F}
    value::Ref{T}
    update::F
end

struct MovingRatio{T,F}
    value::Ref{T}
    update::F
    scale::T
end


function moving_max(moving::MovingValue, newvalue::T) where T
    current = moving.value[]
    if current < newvalue
        moving.value[] = newvalue
    end
end

function moving_min(moving::MovingValue, newvalue::T) where {T}
    current = moving.value[]
    if newvalue < current
        moving.value[] = newvalue
    end
end

function moving_maxabs(moving::MovingValue, newvalue::T) where T
    current = moving.value[]
    newvalue = abs(newvalue)
    if current < newvalue
        moving.value[] = newvalue
    end
end

function moving_minabs(moving::MovingValue, newvalue::T) where {T}
    newvalue = abs(newvalue)
    current = moving.value[]
    if newvalue < current
        moving.value[] = newvalue
    end
end

incremental_max(init::T=floatmin(T)) where {T} = MovingValue(init, moving_max)
incremental_min(init::T=floatmax(T)) where {T} = MovingValue(init, moving_min)

incremental_maxabs(init::T=zero(T)) where {T} = MovingValue(abs(init), moving_maxabs)
incremental_minabs(init::T=floatmax(T)) where {T} = MovingValue(abs(init), moving_minabs)

function moving_mean(moving::MovingRatio, newvalue::T) where {T}
    current = moving.value[]
    change  = 
    ]
    if current < newvalue
        moving.value[] = newvalue
    end
end


const SpanSpecification = NamedTuple{(:span, :offset, :firstidx, :lastidx), NTuple{4,Int}}

struct SourceSpan{T}
    source::T
    span::SpanSpecification
end

struct WindowSpan{T}
    source::T
    sourcespan::SpanSpecification
    windowspan::Ref{SpanSpecification}
end



const SourceSpan = NamedTuple{(:source, :span), Tuple{T, NTuple{4,Int}}}
const WindowSpec = NamedTuple{(:span, :firstidx, :lastidx, )}

# support_functions

function specify_window(sourcelength, windowspan, skipafterwindow, startfrom, endby)
    nonoverlapping_complete_windows, nonoverlapping_partial_window = fldmod(sourcelength, windowspan)
    nonoverlapping_complete_sourcevalues = nonoverlapping_complete_windows * windowspan
    nonoverlapping_partial_sourcevalues = nonoverlapping_partial_window
    nonoverlapping_partial = nonoverlapping_partial_sourcevalues // windowspan

    fullyoverlapping_complete_windows = sourcelength - windowspan + 1
    firstwindow_firstidx = 1
    firstwindow_lastidx = windowspan
    lastwindow_firstidx = sourcelength - windowspan + 1
    lastwindow_lastidx = sourcelength

    ithwindow_fullyoverlapping_firstidx(i) = i
    ithwindow_fullyoverlapping_lastidx(i) =  i + windowspan - 1
    
    ithwindow_nonoverlapping_firstidx(i) = 1+((i-1)*windowspan)
    ithwindow_nonoverlapping_lastidx(i) =        i * windowspan

    ithwindow_skipafter_firstidx(windowspan, skipafter, i) = 1 + (i-1)*(windowspan+skipafter)
    ithwindow_skipafter_lastidx(windowspan, skipafter, i) =  1 + (i-1)*((1+windowspan)+skipafter) 
    # ith_firstidx(w,s,i) + windowspan

end

"""
    nrolled(datasource, windowstate)

The count of values projected through a window rolling over data;
the datasource length (the count of its iterates) and the window
breadth (the count of its subpanes, `finalidx - firstidx + 1`)
are of a determinate length [breadth].
""" nrolled

"""
    nrunned(datasource, windowstate)

The count of values projected through a window running over data;
the datasource length (the count of its iterates) and the window
breadth (the count of its subpanes, `finalidx - firstidx + 1`)
are of a determinate length [breadth].
""" nrunned

"""
    nfilled(datasource, windowstate)
    nfilled(seqlength, windowspan)

- number of values to be partially determined
- values to be obtained using foreshortend window, imputation
""" nfilled

function nfilled(seqlength::T, windowspan::T) where {T<:Signed}
    (1 > windowspan <= seqlength) && WindowOverflowsData((; seqlength, windowspan))

    return windowspan - 1
end

"""
    fullandpartial(seqlength, windowspan)

- number of values
    - to be fully determined
    - to be partially determined

- values to be obtained 
     - using full windowspan
     - using foreshortend window, imputation

""" fullandpartial



function slide_window(datasource, dim, windowstate)
    datasource.firstidx += windowstate.span
    datasource.finalidx += windowstate.span
    windowstate.firstidx = datasource.firstidx
    windowstate.finalidx = datasource.finalidx
    
    if windowstate.finalidx > datatsource.idxmax
        datasource.shortfall = windowstate.finalidx - datasource.idxmax
    elseif windowstate.firstidx > datasource.idxmax
        datasource.shortfall = windowstate.finalidx - datasource.idxmax
        cleanwindow()
    end

    seeyourealsoonnow = (windowstate.finalidx, windowstate.finalidx)
    windowstate.currentvalue
end



    windowstate.firstidx = datasource.firstidx

    datasource.finalidx += windowstate.span



    
function nrolled(datasource, dim, windowstate)
    windowstate.firstidx = datasource.firstidx

    windowstate.finalidx = window_firstidx + windowstate.span
    if  windowstate.finalidx <= datasource.nvalues[dim]
        windowstate.shortfall = 0
    else
        windowstate.shortfall = windowstate.finalidx - nvalues
        windowstate.finalidx  = nvalues
    end
    windowstate
end
```

"""
"""
function nrolled(seqlength::T, windowspan::T) where {T<:Signed}
    (1 > windowspan <= seqlength) || SpanError(seqlength, windowspan)

    return seqlength - windowspan + 1
end

"""
    nfilled(seqlength, windowspan)

- number of values to be partially determined
- values to be obtained using foreshortend window, imputation
"""
function nfilled(seqlength::T, windowspan::T) where {T<:Signed}
    (1 > windowspan <= seqlength) && SpanError(seqlength, windowspan)

    return windowspan - 1
end

"""
    fullandpartial(seqlength, windowspan)

- number of values
    - to be fully determined
    - to be partially determined

- values to be obtained 
     - using full windowspan
     - using foreshortend window, imputation

"""
function fullandpartial(seqlength::T, windowspan::T) where {T<:Signed}
    (1 > windowspan <= seqlength) && SpanError(seqlength, windowspan)

    return seqlength - windowspan + 1, windowspan - 1
end

SpanError(seqlenth, windowspan) = 
    error("SpanErr(seqlength = $(seqlength), windowspan = $(windowspan))")
