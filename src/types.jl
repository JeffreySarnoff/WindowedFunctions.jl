#=
    Packaged Types

    data:        source, sink
    dataseries:
    window:      span

=#
# types










abstract type AbstractWindowed end

abstract type AbstractWindowedFunction <: AbstractWindowed end
abstract type AbstractWindowedOperator{Nargs} <: AbstractWindowedFunction end

abstract type AbstractWindowedData{T} <: AbstractWindowed end
abstract type AbstractWindowedArray{Ndims,T} <: AbstractWindowedData{T} end

abstract type AbstractWindowedVector{T} <: AbstractWindowedArray{1,T} end
abstract type AbstractWindowedTwoVectors{T} <: AbstractWindowedArray{2,T} end
abstract type AbstractWindowedThreeVectors{T} <: AbstractWindowedArray{3,T} end
abstract type AbstractWindowedFourVectors{T} <: AbstractWindowedArray{4,T} end
abstract type AbstractUnaryOperator <: AbstractWindowedOperator{1} end
abstract type AbstractBinaryOperator <: AbstractWindowedOperator{2} end
abstract type AbstractTrinaryOperator <: AbstractWindowedOperator{3} end
abstract type AbstractQuaternaryOperator <: AbstractWindowedOperator{4} end

const AbstractCurrentLook = NamedTuple{(:start, :current, :stop, :final),typeof(NTuple{4,Int64})}

function CurrentLook(start::T, current::T, stop::T, final::T) where {T<:Signed}
    AbstractCurrentLook((start, current, stop, final))
end

struct Windowed{View}
    source::View
    span::Int

    function Windowed(source, span::Int)
        viewsize = (Base.OneTo).(size(source))
        winview = view(source, viewsize...)
        return new{typeof(winview)}(winview, span)
    end
end

Windowed(x::Windowed) = x

source(w::Windowed) = w.source
span(w::Windowed) = w.span

struct Runner{F1,F2}
    setup::F1
    update::F2
end

Runner(x::Runner) = x

setup(x::Runner) = x.setup
update(x::Runner) = x.update


struct Running{View,F1,F2}
    runner::Runner{F1,F2}
    window::Window{View}
    current::NTuple{4,Int64}
end

Running(x::Running) = x

runner(x::Running) = x.runner
window(x::Running) = x.window
current(x::Running) = x.current


Base.iterate(w::Windowed) = (w.source, 2)
Base.iterate(w::Windowed, state::Int) = (w.span, nothing)

Base.iterate(r::Runner) = (r.setup, 2)
Base.iterate(r::Runner, state::Int) = (r.update, nothing)

Base.iterate(r::Running) = (r.runner, 2)
Base.iterate(r::Running, state::Int) =
    state == 2 ? (r.window, 3) : (r.current, nothing)


struct WindowedFunction{Setup,Apply,Update,Tracking,Arity}
    setup::Setup
    apply::Apply
    update::Update
    tracking::Tracking
end


struct WindowedData{T,Nseqs} <: AbstractWindowedData{T}
    source::T
    sourcespan::Int
    windowspan::Int
    ndetermined::Int     # how many values are fully determined, n_full_values <= sourcespan
    ntrailing::Int       # how many values are partially windowed, n_partial_values <= mod(sourcespan, windowspan)
end

function WindowedData(source::S, windowspan::Int)
    sourcesize = size(S)
    sourcespan = sourcesize[1]
    ndetermined, ntrailing = fullandpartial(sourcespan, windowspan)
    sourceviewed = @view(source[Base.OneTo.(sourcesize)...])
    WindowedData{typeof(sourceviewed),sum(sourcesize[2:end])}(sourcevied, sourcespan, windowspan, ndetermined, ntrailing)
end
    
     
     
