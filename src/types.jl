# types

abstract type AbstractWindowed end
abstract type AbstractWindowedFunction <: AbstractWindowed end
abstract type AbstractWindowedData     <: AbstractWindowed end

abstract type AbstractWindowedArray{Ndims,T}  <: AbstractWindowedData end
abstract type AbstractWindowedVector{T}       <: AbstractWindowedArray{1,T} end
abstract type AbstractWindowedTwoVectors{T}   <: AbstractWindowedArray{2,T} end
abstract type AbstractWindowedThreeVectors{T} <: AbstractWindowedArray{3,T} end
abstract type AbstractWindowedFourVectors{T}  <: AbstractWindowedArray{4,T} end

abstract type AbstractWindowedOperator{Nargs} <: AbstractWindowedFunction end

abstract type AbstractUnaryOperator      <: AbstractWindowedOperator{1} end
abstract type AbstractBinaryOperator     <: AbstractWindowedOperator{2} end
abstract type AbstractTrinaryOperator    <: AbstractWindowedOperator{3} end
abstract type AbstractQuaternaryOperator <: AbstractWindowedOperator{4} end



struct DataWindow <: AbstractDataWindow
