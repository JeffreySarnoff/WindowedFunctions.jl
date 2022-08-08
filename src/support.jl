# support_functions

function specify_window(sourcelength, windowspan)
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
""" nfilled

""""
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
