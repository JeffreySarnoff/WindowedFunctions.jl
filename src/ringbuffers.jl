module RingBuffers

#=

    window1 = [_1,_2,..,_N-1,_N]
    window2 = [   _2,..,_N-1,_N,_N+1]
    window3 = [   _3,..,_N-1,_N,_N+1,_N+2]
    windowI = [   _I,..,_N-1,_N,_N+1,..,_N+I-1]
    windowN = [   _N,..,_N+N-1]
    windowN+1 = [ _N+1,..,N+N]

=#
export CircularVector, RingBuffer

struct CircularVector{T}
    buffer::Vector{T}
    size::Int
    first::Ref{Int}
    last::Ref{Int}
end

function CircularVector(::Type{T}, n::Int) where {T<:Number}
    first = Ref(1)
    size = n
    last = Ref(n)
    buf = fill(zero(T), n)
    CircularVector{T}(buf, size, first, last)
end

function CircularVector(buffer::Vector{T}) where {T<:Number}
    first = Ref(1)
    size = length(buffer)
    last = Ref(size)
    CircularVector{T}(buffer, size, first, last)
end

function getindex(cv::CircularVector, idx::Int)
    index = cv.first + idx - 1
    if index > cv.last
        index = cv.last - idx + 1
    end
    cb.buffer[index]
end


end  # RingBuffers