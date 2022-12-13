module WindowedFunctions

using StatsBase
using StatsAPI
using Distances

abstract type Windowed end

abstract type Gather{T} <: Function end
abstract type Accumulator{T} <: Gather{T} end
abstract type Aggregator{T}  <: Gather{T} end

struct AccFn{T,A<:Accumulator,F<:Function} <: Accumulator{T}
    acc::A
	fn::F
end

 function AccFn(acc::A, fn::Function) where{T,A<:Accumulator{T}}
     AccFn{T,A,typeof(fn)}(acc, fn)
 end
	   
function (acc::AccFunc)()
    acc.acc()
end

function (acc::AccFunc)(x)
    acc.acc(acc.fn(x))
end


  
struct AggFn{T, A<:Aggregator{T}, F<:Function} <: Aggregator{T}
    aagg::A
    fn::F
end

using Accumulators
using Aggregators


include("support.jl")

end  # WindowedFunctions

