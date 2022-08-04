#=
   throw(WindowBounds)
=#
#=

    use: throw(WindowBounds)
=#

const Except = :Exception
const ExceptSingletons = (:WindowBounds, :WindowAdvance)
const Exceptions = Symbol.(ExceptSingletons, Except)
const ExceptMsgs  = (:("window exceeds data boundry"), 
                     :("window advanced past data"))

for (E,S,M) in zip(Exceptions, ExceptSingletons, ExceptMsgs)
  @eval begin

    Base.@kwdef(
      struct $E <: Exception
          msg::String=$M
      end)

    const $S = $E()

    function Base.showerror(io::IO, err::$E)
        println(io, err.msg)
    end

  end
end
