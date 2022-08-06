#=
   exceptions that may be encountered
=#

abstract type WindowedDataException <: Exception end

"""
    WindowOverflowsData <: WindowedDataException

lastindex(current_window) > lastindex(current_data)
""" WindowOverflowsData

"""
    WindowUnderflowsData <: WindowedDataException

firstindex(current_window) < firstindex(current_data)
""" WindowUnderflowsData


Base.@kwdef struct WindowOverflowsData <: WindowedDataException
    msg::String
end

Base.@kwdef struct WindowUnderflowsData <: WindowedDataException
    msg::String
end

function Base.showerror(io::IO, err::WindowedDataException)
    println(io, err.msg)
end
