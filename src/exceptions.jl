#=
   exceptions that may be encountered
=#

abstract type DataWindowException <: Exception end

Base.@kwdef struct WindowOverflowsData <: DataWindowException
    msg::String
end

Base.@kwdef struct WindowUnderflowsData <: DataWindowException
    msg::String
end

function Base.showerror(io::IO, err::DataWindowException)
    println(io, err.msg)
end

