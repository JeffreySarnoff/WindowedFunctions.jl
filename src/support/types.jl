struct NoPadding end
const nopadding = NoPadding()

hasnopadding(x) = x === nopadding
haspadding(x) = x !== nopadding

# absent specified element type

const VectorWeights = AbstractVector{<:AbstractWeights}  # VectorWeights <: VectorVectors
const VectorVectors = AbstractVector{<:AbstractVector}

const ViewWeights = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractWeights}
const ViewVector = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractVector}

const ViewVectorWeights = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractVector{<:AbstractWeights}}
const ViewVectorVectors = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractVector{<:AbstractVector}}

const ViewMatrix = SubArray{T,2,M,Tuple{Base.Slice{Base.OneTo{Int64}},Base.Slice{Base.OneTo{Int64}}},true} where {T,M<:AbstractMatrix}

# with element type included

const ViewOfWeights{T} = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractWeights{T}}
const ViewOfVector{T} = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractVector{T}}
const ViewOfMatrix{T} = SubArray{T,2,M,Tuple{Base.Slice{Base.OneTo{Int64}},Base.Slice{Base.OneTo{Int64}}},true} where {T,M<:AbstractMatrix{T}}

const VectorOfWeights{T} = AbstractVector{<:AbstractWeights{T}} where {T}
const VectorOfVectors{T} = AbstractVector{<:AbstractVector{T}} where {T}

const ViewOfVectorOfWeights{T} = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractVector{<:AbstractWeights{T}}}
const ViewOfVectorOfVectors{T} = SubArray{T,1,A,Tuple{Base.Slice{Base.OneTo{Int64}}},true} where {T,A<:AbstractVector{<:AbstractVector{T}}}

#=
const VectorOfNTuples = AbstractVector{<:NTuple}
const VectorOfTuples  = AbstractVector{<:Tuple}

const TupleOfNTuples = Tuple{Vararg{NTuple}}
const TupleOfTuples = Tuple{Vararg{Tuple}}
const TupleOfVectors = Tuple{Vararg{AbstractVector}}
const TupleOfWeights = Tuple{Vararg{AbstractWeights}}

const Sequence = Union{AbstractVector{T},NTuple{N,T}} where {N,T}
seq(x::AbstractVector{T}) where {T} = x
seq(x::NTuple{N,T}) where {N,T} = x

const Multisequence = Union{Tuple{<:Sequence},AbstractVector{<:Sequence}}

=#

"""
    typeofviewof(x)

a `typeof` variant that generates view types from concrete x values
"""
typeofviewof

function typeofviewof(x)
    typeofx = typeof(x)
    eltypex = eltype(x)
    SubArray{eltypex,1,typeofx,Tuple{Base.Slice{Base.OneTo{Int}}},true}
end


#=
      AbstractVector
                    >: AbstractWeights
                                        >: VectorWeights 
                                                            >: VectorVectors

      AbstractVector
                    >: ViewVector
                                      >: ViewVectors
                   >: ViewOfWieghts


=#


