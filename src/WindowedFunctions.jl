module WindowedFunctions

using StatsBase
using Distances

const Seq = Union{AbstractVector{T}, Tuple{Vararg{T}}} where {T}
const MultiSeq = Union{AbstractArray{T,D}, NTuple{D, NTuple{N,T}}}} where {D,N,T}

seq(xs::AbstractVector{T}) where {T} = xs
seq(xs::NTuple{N,T}) where {N,T} = xs
multiseq(xys::AbstractArray{T,D}) where {T,D} = xys
multiseq(xys::NTuple{D, NTuple{N,T})} where {D,N,T} = xys

abstract type Windowed end

abstract type Gather{T} <: Function end
abstract type Accumulator{T} <: Gather{T} end
abstract type Aggregator{T}  <: Gather{T} end

struct AccFx{T,A<:Accumulator,F<:Function} <: Accumulator{T}
    acc::A
    fn::F
end

function AccFx(acc::A, fn::Function) where{T,A<:Accumulator{T}}
    AccFn{T,A,typeof(fn)}(acc, fn)
end
	   
function (acc::AccFx)()
    acc.acc()
end

function (acc::AccFx)(x)
    acc.acc(acc.fn(x))
end


struct AccumData{T}
    acc::Accumulator{T}
    data::Seq{T}
end

function Base.iterate(accumdata::AccumData{T}) where {T}
     datastate = (first(accumdata.data), ifelse(length(accumdata.data) > 1, 2, nothing))
     accstate  = (accumdata.acc(datastate[1]), 2)
     (accumdata, datastate)
end
function Base.iterate(accumdata::AccumData{T}, state) where {T}
     datastate = ifelse(isnothing(state), nothing, accumdata.data[state])
     state = ifelse(length(accumdata.data) > state, state+1, nothing)
     ifelse(!isnothing(datastate), accumdata.acc(datastate), nothing)
     (accumdata, state)
end

  
struct AggFx{T, A<:Aggregator{T}, F<:Function} <: Aggregator{T}
    aagg::A
    fn::F
end

using Accumulators
using Aggregators


include("support.jl")

end  # WindowedFunctions

