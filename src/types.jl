# types

abstract type AbstractWindowed end
abstract type AbstractWindowedFunction <: AbstractWindowed end
abstract type AbstractWindowedData{T}  <: AbstractWindowed end

abstract type AbstractWindowedArray{Ndims,T}  <: AbstractWindowedData{T} end
abstract type AbstractWindowedVector{T}       <: AbstractWindowedArray{1,T} end
abstract type AbstractWindowedTwoVectors{T}   <: AbstractWindowedArray{2,T} end
abstract type AbstractWindowedThreeVectors{T} <: AbstractWindowedArray{3,T} end
abstract type AbstractWindowedFourVectors{T}  <: AbstractWindowedArray{4,T} end

abstract type AbstractWindowedOperator{Nargs} <: AbstractWindowedFunction end

abstract type AbstractUnaryOperator      <: AbstractWindowedOperator{1} end
abstract type AbstractBinaryOperator     <: AbstractWindowedOperator{2} end
abstract type AbstractTrinaryOperator    <: AbstractWindowedOperator{3} end
abstract type AbstractQuaternaryOperator <: AbstractWindowedOperator{4} end

struct WindowedFunction{Setup, Apply<:Function, Update<:Function, Tracking, Arity}
    setup::Setup
    apply::Apply
    update::Update
    tracking::Tracking
end

struct WindowedData{T,Nseqs,Eltype,} <: AbstractWindowedData{T}
     source::T
     sourcespan::Int
     windowspan::Int
     ndetermined::Int     # how many values are fully determined, n_full_values <= sourcespan
     ntrailing::Int       # how many values are partially windowed, n_partial_values <= mod(sourcespan, windowspan)
end


     
     
