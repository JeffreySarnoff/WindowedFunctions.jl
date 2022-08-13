# rollfun

using VectorizedStatistics

function rolling(fun::Function, windowspan::Int, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    offset = windowspan - 1
    nvals = seqlen - windowspan + 1
    starts = 1:nvals

    result = Vector{T}(undef, nvals)
    for idx in starts
        result[idx] = fun(view(dataview, idx:idx+offset))
    end
    result
end

rollvar(windowspan::Int, data) = rolling(vvar, windowspan, data)
rollstd(windowspan::Int, data) = rolling(vstd, windowspan, data)

# vsum, vmean, vvar, vstd, vmaximum, vminimum,
# vextrema, vcor, vcov

function rollsum(windowspan::Int, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    offset = windowspan - 1
    nvals = seqlen - windowspan + 1
    starts = 1:nvals

    result = Vector{T}(undef, nvals)
    result[1] = sum(view(dataview, 1:1+offset))

    # result[2] = result[1] - dataview[1] + dataview[1+windowspan]
    # result[3] = result[2] - dataview[2] + dataview[2+windowspan]

    for idx in starts[2:end]
        idx1 = idx-1
        result[idx] = result[idx1]
        result[idx] -= dataview[idx1] + dataview[idx1+windowspan]
    end

    result
end

function rollmean(windowspan::Int, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    offset = windowspan - 1
    invspan = one(T)/windowspan
    nvals = seqlen - windowspan + 1
    starts = 1:nvals

    result = Vector{T}(undef, nvals)
    result[1] = mean(view(dataview, 1:1+offset))

    for idx in starts[2:end]
        idx1 = idx - 1
        result[idx] = result[idx1]
        result[idx] += (-dataview[idx1] + dataview[idx1+windowspan]) * invspan
    end

    result
end

function rollmaximum(windowspan::Int, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    offset = windowspan - 1
    invspan = one(T) / windowspan
    nvals = seqlen - windowspan + 1
    starts = 1:nvals

    result = Vector{T}(undef, nvals)
    result[1] = vmaximum(view(dataview, 1:1+offset))

    for idx in starts[2:end]
        idx1 = idx - 1
        old = dataview[idx1]
        next = dataview[idx1+windowspan]
        if old < result[idx1]
            result[idx] = max(result[idx1], dataview[idx1+windowspan])
        else
            result[idx] = maximum(view(dataview,idx:idx+offset))
        end
    end

    result
end

function rollminimum(windowspan::Int, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    offset = windowspan - 1
    invspan = one(T) / windowspan
    nvals = seqlen - windowspan + 1
    starts = 1:nvals

    result = Vector{T}(undef, nvals)
    result[1] = vminimum(view(dataview, 1:1+offset))

    for idx in starts[2:end]
        idx1 = idx - 1
        old = dataview[idx1]
        next = dataview[idx1+windowspan]
        if old >= result[idx1]
            result[idx] = min(result[idx1], dataview[idx1+windowspan])
        else
            result[idx] = minimum(view(dataview, idx:idx+offset))
        end
    end

    result
end

# number of values to be obtained
function nrolled(seqlength::T, windowspan::T) where {T<:Signed}
    (0 < windowspan <= seqlength) || throw(SpanError(seqlength, windowspan))

    return seqlength - windowspan + 1
end