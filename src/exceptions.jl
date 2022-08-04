#=
   throw(WindowBounds)
=#
#=

    use: throw(WindowBounds)
         throw(WindowBoundsErr((sourcelen, start, stop)))
=#

const Except = :Exception
const ExceptSingletons = (:WindowBounds, :WindowAdvance)
const MutableExceptSingletons = (:WindowBoundsErr, :WindowAdvanceErr)
const Exceptions = Symbol.(ExceptSingletons, Except)
const MutableExceptions = Symbol.(MutableExceptSingletons, Except)
const ExceptMsgs = (:("window exceeds data boundry"),
    :("window advanced past data"))

for (E, S, M, ME, MS) in zip(Exceptions, ExceptSingletons, ExceptMsgs, MutableExceptions, MutableExceptSingletons)
    @eval begin

        Base.@kwdef(
            struct $E{T} <: Exception
                msg::String = $M
            end)

        Base.@kwdef(
            mutable struct $ME{T} <: Exception
                msg::T
            end)

        const $S = $E()

        function Base.showerror(io::IO, err::$E)
            println(io, err.msg)
        end

        function Base.showerror(io::IO, err::$ME)
            println(io, string(err.msg))
        end
    end
end
