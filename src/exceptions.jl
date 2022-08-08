#=
   exceptions that may be encountered
=#

"""
    WindowOverflowsData

The final position of a sliding window has advanced past the end of the data.
""" WindowOverflowsData

struct WindowOverflowsData{T} <: Exception
    msg::T

    WindowsOverflowsData(x::T) where T = new{T}(string(x))
end

function Base.showerror(io::IO, err::WindowOverflowsData)
    println(io, err.msg)
end
