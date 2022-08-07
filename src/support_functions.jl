# support_functions


"""
    nrolled(datasource, windowstate)

Given a data source, here a sequence of values of a shared type, 
  each one may appear once or more than once within this vector,
  the length of the vector is the extent of that value sequence.
""" nrolled

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
