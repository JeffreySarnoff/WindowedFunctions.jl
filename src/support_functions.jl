# support_functions


"""
    nrolled(seqlength, windowspan)

- number of values to be fully determined
- values to be obtained using full windowspan
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

SpanError(seqlenth, windowspan) = error("SpanErr(seqlength = $seqlength, windowspan = $windowspan)")
