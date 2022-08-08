#=

A sequence is a totally ordered arraingement of shared-typed values
    (ordered in "appearance order" over successive values).
A multisequence is a sequence where each element is compound, a multielement.

An indexed sequence is a sequence of ordered pairs (indexing referent, element value)
   (where the "appearance order" matches the index order, ie pairs sorted over the index)
An indexed multisequence is sequence of ordered ntuples (indexing referent, tuple of elements' values)
=#

abstract type AbstractSequence end
abstract type AbstractTotalOrder
    
abstract type AbstractMultisequence{N} <: AbstractSequence end


