#=
   basic_running(fn, width, data1) ..
   basic_running(fn, width, data1, data2, data3, data4)

   padfirst_running(fn, width, data1, padding) ..
   padfirst_running(fn, width, data1, data2, data3, data4, padding)

   padfinal_running(fn, width, data1, padding) ..
   padfinal_running(fn, width, data1, data2, data3, data4, padding)
=#


# basic_running

function basic_running(fn::Function, width::Integer,
    data1::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)

    basic_running(fn, width, ᵛʷdata1)
end

function basic_running(fn::Function, width::Integer,
    data1::AbstractVector{T}, data2::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)

    basic_running(fn, width, ᵛʷdata1, ᵛʷdata2)
end

function basic_running(fn::Function, width::Integer,
    data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)

    basic_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3)
end

function basic_running(fn::Function, width::Integer,
    data1::AbstractVector{T}, data2::AbstractVector{T},
    data3::AbstractVector{T}, data4::AbstractVector{T}) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷdata4 = asview(data4)

    basic_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, ᵛʷdata4)
end

function basic_running(fn::Function, width::Integer,
    data1::AbstractVector{T1}, data2::AbstractVector{T2}) where {T1,T2}
    typ = promote_type(T1, T2)
    ᵛʷdata1 = T1 === typ ? asview(data1) : asview([typ(x) for x in data1])
    ᵛʷdata2 = T2 === typ ? asview(data2) : asview([typ(x) for x in data2])

    basic_running(fn, width, ᵛʷdata1, ᵛʷdata2)
end

function basic_running(fn::Function, width::Integer,
    data1::AbstractVector{T1}, data2::AbstractVector{T2}, data3::AbstractVector{T3}) where {T1,T2,T3}
    typ = promote_type(T1, T2, T3)
    ᵛʷdata1 = T1 === typ ? asview(data1) : asview([typ(x) for x in data1])
    ᵛʷdata2 = T2 === typ ? asview(data2) : asview([typ(x) for x in data2])
    ᵛʷdata3 = T3 === typ ? asview(data3) : asview([typ(x) for x in data3])

    basic_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3)
end

function basic_running(fn::Function, width::Integer,
    data1::AbstractVector{T1}, data2::AbstractVector{T2},
    data3::AbstractVector{T3}, data4::AbstractVector{T4}) where {T1,T2,T3,T4}
    typ = promote_type(T1, T2, T3, T4)
    ᵛʷdata1 = T1 === typ ? asview(data1) : asview([typ(x) for x in data1])
    ᵛʷdata2 = T2 === typ ? asview(data2) : asview([typ(x) for x in data2])
    ᵛʷdata3 = T3 === typ ? asview(data3) : asview([typ(x) for x in data3])
    ᵛʷdata4 = T4 === typ ? asview(data4) : asview([typ(x) for x in data4])

    basic_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, ᵛʷdata4)
end

# padfirst_running

function padfirst_running(fn::Function, width::Integer, data1::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)

    padfirst_running(fn, width, ᵛʷdata1, padding)
end

function padfirst_running(fn::Function, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)

    padfirst_running(fn, width, ᵛʷdata1, ᵛʷdata2, padding)
end

function padfirst_running(fn::Function, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)

    padfirst_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, padding)
end

function padfirst_running(fn::Function, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T},
    data3::AbstractVector{T}, data4::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷdata4 = asview(data4)

    padfirst_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, ᵛʷdata3, padding)
end

# padfinal_running

function padfinal_running(fn::Function, width::Integer, data1::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)

    padfinal_running(fn, width, ᵛʷdata1, padding)
end

function padfinal_running(fn::Function, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)

    padfinal_running(fn, width, ᵛʷdata1, ᵛʷdata2, padding)
end

function padfinal_running(fn::Function, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)

    padfinal_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, padding)
end

function padfinal_running(fn::Function, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T},
    data3::AbstractVector{T}, data4::AbstractVector{T}, padding) where {T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    ᵛʷdata4 = asview(data4)

    padfinal_running(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, ᵛʷdata4, padding)
end

 #=
 #    basic_running implementation
=#

function basic_running(fn::Function, width::Integer, ᵛʷdata1::ViewVector{T}) where {T}
    n = length(ᵛʷdata1)
    check_width(n, width)

    nvalues = rolling_wholes(n, width)

    rettype = fastrts(fn, (Vector{T},))
    result = Vector{rettype}(undef, nvalues)

    ilow, ihigh = 1, width
    @inbounds for idx in eachindex(result)
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    result
end

function basic_running(fn::Function, width::Integer, ᵛʷdata1::ViewVector{T}, padding) where {T}
    n = length(ᵛʷdata1)
    check_width(n, width)

    if iszero(running_parts(n, width))
        return basic_running(fn, width, ᵛʷdata1)
    end

    padding_idxs = n-width:n
    rettype = fastrts(fn, (Vector{T},))
    result = Vector{Union{typeof(padding),rettype}}(undef, n)
    result[padding_idxs] .= padding

    ilow, ihigh = 1, width
    @inbounds for idx in width:n
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    result
end



















#=
   taperfirst(fn, width, data1) ..
   taperfirst(fn, width, data1, data2, data3)

   taperfinal(fn, width, data1) ..
   taperfinal(fn, width, data1, data2, data3)
=#

# taperfirst

function taperfirst(fn::F, width::Integer, data1::AbstractVector{T}; padding=nopadding) where {F<:Function,T}
    ᵛʷdata1 = asview(data1)
    if padding == nopadding
        taperfirst(fn, width, ᵛʷdata1)
    else
        taperfirstpadded(fn, width, ᵛʷdata1, padding)
    end
end

function taperfirst(fn::F, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}; padding=nopadding) where {F<:Function,T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    if padding == nopadding
        taperfirst(fn, width, ᵛʷdata1, ᵛʷdata2)
    else
        taperfirstpadded(fn, width, ᵛʷdata1, ᵛʷdata2, padding)
    end
end

function taperfirst(fn::F, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}; padding=nopadding) where {F<:Function,T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    if padding == nopadding
        taperfirst(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3)
    else
        taperfirstpadded(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, padding)
    end
end

# taperfinal

function taperfinal(fn::F, width::Integer, data1::AbstractVector{T}; padding=nopadding) where {F<:Function,T}
    ᵛʷdata1 = asview(data1)
    if padding == nopadding
        taperfinal(fn, width, ᵛʷdata1)
    else
        taperfinalpadded(fn, width, ᵛʷdata1, padding)
    end
end

function taperfinal(fn::F, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}; padding=nopadding) where {F<:Function,T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    if padding == nopadding
        taperfinal(fn, width, ᵛʷdata1, ᵛʷdata2)
    else
        taperfinalpadded(fn, width, ᵛʷdata1, ᵛʷdata2, padding)
    end
end

function taperfinal(fn::F, width::Integer, data1::AbstractVector{T}, data2::AbstractVector{T}, data3::AbstractVector{T}; padding=nopadding) where {F<:Function,T}
    ᵛʷdata1 = asview(data1)
    ᵛʷdata2 = asview(data2)
    ᵛʷdata3 = asview(data3)
    if padding == nopadding
        taperfinal(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3)
    else
        taperfinalpadded(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3, padding)
    end
end

# taperfirst implementation

function taperfirstpadded(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, padding) where {F<:Function,T}
    result = taperfirst(fn, width, ᵛʷdata1)
    for i = eachindex(result)
        if !isnan(result[i])
            break
        else
            result[i] = padding
        end
    end
    result
end

function taperfirstpadded(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}, padding) where {F<:Function,T}
    result = taperfirst(fn, width, ᵛʷdata1, ᵛʷdata2)
    for i = eachindex(result)
        if !isnan(result[i])
            break
        else
            result[i] = padding
        end
    end
    result
end

function taperfirstpadded(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}, ᵛʷdata3::ViewVector{T}, padding) where {F<:Function,T}
    result = taperfirst(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3)
    for i = eachindex(result)
        if !isnan(result[i])
            break
        else
            result[i] = padding
        end
    end
    result
end

function taperfirst(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}) where {F<:Function,T}
    n = length(ᵛʷdata1)
    check_width(n, width)

    nvalues = nrunning(n, width)
    if iszero(nimputed_running(n, width))
        return basic_running(fn, width, ᵛʷdata1)
    end

    taper_idxs = 1:n-nvalues
    rettype = fastrts(fn, (Vector{T},))
    result = Vector{rettype}(undef, n)

    @inbounds for idx in taper_idxs
        @views result[idx] = fn(ᵛʷdata1[1:idx])
    end

    ilow, ihigh = 1, width
    @inbounds for idx in width:n
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    result
end

function taperfirst(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}) where {F<:Function,T}
    n = min(length(ᵛʷdata1), length(ᵛʷdata2))
    check_width(n, width)

    nvalues = nrunning(n, width)
    if iszero(nimputed_running(n, width))
        return basic_running(fn, width, ᵛʷdata1, ᵛʷdata2)
    end

    taper_idxs = 1:n-nvalues
    rettype = fastrts(fn, (Vector{T}, Vector{T}))
    result = Vector{rettype}(undef, n)

    @inbounds for idx in taper_idxs
        @views result[idx] = fn(ᵛʷdata1[1:idx], ᵛʷdata2[1:idx])
    end

    ilow, ihigh = 1, width
    @inbounds for idx in width:n
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh], ᵛʷdata2[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    result
end

function taperfirst(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}, ᵛʷdata3::ViewVector{T}) where {F<:Function,T}
    n = min(length(ᵛʷdata1), length(ᵛʷdata2), length(ᵛʷdata3))
    check_width(n, width)

    nvalues = nrunning(n, width)
    if iszero(nimputed_running(n, width))
        return basic_running(fn, width, ᵛʷdata1, ᵛʷdata2)
    end

    taper_idxs = 1:n-nvalues
    rettype = fastrts(fn, (Vector{T}, Vector{T}, Vector{T}))
    result = Vector{rettype}(undef, n)

    @inbounds for idx in taper_idxs
        @views result[idx] = fn(ᵛʷdata1[1:idx], ᵛʷdata2[1:idx], ᵛʷdata3[1:idx])
    end

    ilow, ihigh = 1, width
    @inbounds for idx in width:n
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh], ᵛʷdata2[ilow:ihigh], ᵛʷdata3[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    result
end

# taperfinal implementation

function taperfinalpadded(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, padding) where {F<:Function,T}
    result = taperfinal(fn, width, ᵛʷdata1)
    for i = length(result):-1:1
        if !isnan(result[i])
            break
        else
            result[i] = padding
        end
    end
    result
end

function taperfinalpadded(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}, padding) where {F<:Function,T}
    result = taperfinal(fn, width, ᵛʷdata1, ᵛʷdata2)
    for i = length(result):-1:1
        if !isnan(result[i])
            break
        else
            result[i] = padding
        end
    end
    result
end

function taperfinalpadded(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}, ᵛʷdata3::ViewVector{T}, padding) where {F<:Function,T}
    result = taperfinalt(fn, width, ᵛʷdata1, ᵛʷdata2, ᵛʷdata3)
    for i = length(result):-1:1
        if !isnan(result[i])
            break
        else
            result[i] = padding
        end
    end
    result
end

function taperfinal(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}) where {F<:Function,T}
    n = length(ᵛʷdata1)
    check_width(n, width)

    nvalues = nrunning(n, width)
    if iszero(nimputed_running(n, width))
        return basic_running(fn, width, ᵛʷdata1)
    end

    rettype = fastrts(fn, (Vector{T},))
    result = Vector{rettype}(undef, n)

    ilow, ihigh = 1, width
    @inbounds for idx in 1:nvalues
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    taper_idxs = ilow:n
    @inbounds for idx in taper_idxs
        @views result[idx] = fn(ᵛʷdata1[idx:end])
    end

    result
end

function taperfinal(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}) where {F<:Function,T}
    n = min(length(ᵛʷdata1), length(ᵛʷdata2))
    check_width(n, width)

    nvalues = nrunning(n, width)
    if iszero(nimputed_running(n, width))
        return basic_running(fn, width, ᵛʷdata1)
    end

    rettype = fastrts(fn, (Vector{T}, Vector{T}))
    result = Vector{rettype}(undef, n)

    ilow, ihigh = 1, width
    @inbounds for idx in 1:nvalues
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh], ᵛʷdata2[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    taper_idxs = ilow:n
    @inbounds for idx in taper_idxs
        @views result[idx] = fn(ᵛʷdata1[idx:end], ᵛʷdata2[idx:end])
    end

    result
end

function taperfinal(fn::F, width::Integer, ᵛʷdata1::ViewVector{T}, ᵛʷdata2::ViewVector{T}, ᵛʷdata3::ViewVector{T}) where {F<:Function,T}
    n = min(length(ᵛʷdata1), length(ᵛʷdata2), length(ᵛʷdata3))
    check_width(n, width)

    nvalues = nrunning(n, width)
    if iszero(nimputed_running(n, width))
        return basic_running(fn, width, ᵛʷdata1)
    end

    rettype = fastrts(fn, (Vector{T}, Vector{T}, Vector{T}))
    result = Vector{rettype}(undef, n)
    # result[padding_idxs] .= padding

    ilow, ihigh = 1, width
    @inbounds for idx in 1:nvalues
        @views result[idx] = fn(ᵛʷdata1[ilow:ihigh], ᵛʷdata2[ilow:ihigh], ᵛʷdata3[ilow:ihigh])
        ilow = ilow + 1
        ihigh = ihigh + 1
    end

    taper_idxs = ilow:n
    @inbounds for idx in taper_idxs
        @views result[idx] = fn(ᵛʷdata1[idx:end], ᵛʷdata2[idx:end], ᵛʷdata3[idx:end])
    end

    result
end

