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


rollsum(windowspan::Int, data) = rolling(vsum, windowspan, data)
rollmean(windowspan::Int, data) = rolling(vmean, windowspan, data)
rollvar(windowspan::Int, data) = rolling(vvar, windowspan, data)
rollstd(windowspan::Int, data) = rolling(vstd, windowspan, data)
rollmaximum(windowspan::Int, data) = rolling(vmaximum, windowspan, data)
rollminimum(windowspan::Int, data) = rolling(vminimum, windowspan, data)

# vsum, vmean, vvar, vstd, vmaximum, vminimum,
# vextrema, vcor, vcov


#=
function rolling(windowspan::Int, fun::Function, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    nvals  = seqlen - windowspan + 1

    starts = 1:nvals
    stops = starts .+ (windowspan - 1)
    bounds = map((a,b)->a:b, starts, stops)

    map(boundry->fun(view(dataview, boundry)), bounds)
end

function rolling(windowspan::Int, fun::Function, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    nvals = seqlen - windowspan + 1

    starts = 1:nvals
    stops = starts .+ (windowspan - 1)
    bounds = map((a, b) -> a:b, starts, stops)

    result = Vector{T}(undef, nvals)
    i = 1
    for boundry in bounds
        result[i] = fun(view(dataview, boundry))
        i += 1
    end
    result
end

function rolling(windowspan::Int, fun::Function, data::AbstractVector{T}) where {T}
    dataview = view(data, :)
    seqlen = length(dataview)
    nvals = seqlen - windowspan + 1

    starts = 1:nvals
    stops = starts .+ (windowspan - 1)
    bounds = map((a, b) -> a:b, starts, stops)

    # result = Vector{T}(undef, nvals)
    map(i -> fun(view(dataview, i)), bounds)
    #result .= fun.(view.(Ref(dataview),bounds))

    #result
end
=#

# number of values to be obtained
function nrolled(seqlength::T, windowspan::T) where {T<:Signed}
    (0 < windowspan <= seqlength) || throw(SpanError(seqlength, windowspan))

    return seqlength - windowspan + 1
end