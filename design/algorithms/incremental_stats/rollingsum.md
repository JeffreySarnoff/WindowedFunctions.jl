ggjp
Nov 2019

What is the recommended way of doing a rolling / moving sum?

I’ve found packages RollingFunctions.jl and MarketTechnicals.jl, but neither has this.

    created
    Nov 2019
    last reply
    Nov 2019
    28
    replies
    3.9k
    views
    11
    users
    44
    likes
    1
    link
    7
    7
    4

nilshg
Nov 2019

What’s wrong with the RollingFunctions approach?

ajulia> using RollingFunctions

julia> a = rand(10);

julia> rolling(sum, a, 5)
6-element Array{Float64,1}:
 3.2334084082359906
 3.8027887140089467
 3.785573015992105
 3.991553119385805
 3.547388812871529
 3.221195695490038

ggjp
Nov 2019

Here’s a guess: since rolling accepts any function, it will do function-specific optimizations. In the case of sum, the best way to calculate a rolling sum is not to apply sum to successive windows. Instead, you’d want to, in each iteration, calculate the rolling sum as being the previous sum plus the new element entering the window, minus the last element leaving the window. The fact that this isn’t a function in RollingFunctions.jl makes me wonder whether I’m missing something
klaff
Nov 2019

Not too hard to roll a simple one (for simple situations) which might be faster than the more generic approach.

function rolling_sum(a, n::Int)
    @assert 1<=n<=length(a)
    out = similar(a, length(a)-n+1)
    out[1] = sum(a[1:n])
    for i in eachindex(out)[2:end]
        out[i] = out[i-1]-a[i-1]+a[i+n-1]
    end
    return out
end

This seems to work but no warranty implied, etc.

P.S. Just for fun, here’s a threaded version, which with four threads gives me about 2x performance.

function trolling_sum(a, n::Int)
    @assert 1<=n<=length(a)
    nseg=4
    if nseg*n >= length(a)
        return rolling_sum(a,n)
    else
        out = similar(a, length(a)-n+1)
        lseg = (length(out)-1)÷nseg+1
        segments = [(i*lseg+1, min(length(out),(i+1)*lseg)) for i in 0:nseg-1]
        Threads.@threads for (start, stop) in segments
            out[start] = sum(a[start:start+n-1])
            for i in start+1:stop
                out[i] = out[i-1]-a[i-1]+a[i+n-1]
            end
        end
        return out
    end
end

I’m not completely sure about thread safety here. All threads write to out, but never to the same location in out.
ggjp
Nov 2019

@klaff exactly, I wrote something which is basically the same, and according to btime it’s about 10x faster than RollingFunctions.rolling(sum, …) (12ms, 5 allocations vs 135ms, 2M+ allocations on a 2million+ Vector{Float64})

I still think I’m missing something… why doesn’t RollingFunctions have this built-in? Or why isn’t there a Base function etc. I just assumed this existed and I couldn’t find it.
Tamas_Papp
Nov 2019

    The fact that this isn’t a function in RollingFunctions.jl makes me wonder whether I’m missing something

I am not familiar with this package, but if this is the case, you can add a specialized method on ::typeof(sum).
Oscar_Smith
Nov 2019

To me, it seems that the thing missing is a rolling function that takes both a function and it’s inverse. That would allow this approach to be done genetically for a wife variety of functions.
ggjp
Nov 2019

@Oscar_Smith Interesting. I don’t really know that approach. Care to explain how that would work exactly?
Oscar_Smith
Nov 2019

The idea is that for functions with inverse, you can apply the function where you used +, Ave the inverse where you used -.
klaff
Nov 2019

I assume you’re thinking along the lines of how the accumulating statistics functions on HP calculators worked, with a Σ+ key and a Σ- key, where those would add or remove x,y sample pairs, not by keeping a list but by appropriately updating the stats registers of Σx, Σy, etc.
ggjp
Nov 2019

As suspected: https://github.com/JeffreySarnoff/RollingFunctions.jl/blob/f42c3e28668d63191daf93e4b62f81d9f98c1b40/src/roll/rolling.jl#L6-L16 86
mbauman
Nov 2019

So… make a pull-request with your suggested optimization? That’s the beauty of open-source — you can lean on others work and collaborate to improve it.
tim.holy
Steward
Nov 2019

ImageFiltering has generic operations for N-dimensional arrays. But if all you want is the sum, why not use cumsum?
klaff
Nov 2019

There is a reason not to do the fast method, depending on your application.

julia> a=randn(1_000_000_000)
1000000000-element Array{Float64,1}:
 -1.2344126204756887
 -0.8239991893593851
  1.178705934119596
 -0.013067916777890981
 -2.0283561056107553
  0.2622616832126358
 -0.6759869411454665
 -0.5361857977094139
  0.8097520205869354
  0.32388073554507785
 -2.527704302672418
  ⋮
 -0.6576524013369835
 -0.23953427627419813
 -0.028670388394535708
 -1.5805848784975132
  0.48150455056217334
  1.5563777415762128
 -2.8107725516409716
 -1.0499675458464977
 -0.27204237866643
 -1.3917792177726476

julia> rolling_sum(a, 20)[end]
-5.901424969621745

julia> sum(a[end-19:end])
-5.901424969620317

You probably don’t care about the last 4 digits being different due to accumulated error, although you could reset the error periodically if it was an issue.
fipelle
Nov 2019

You could also try to make it faster using @view and parallelising. For example via:

using Distributed;
addprocs(2) # you choose

function rolling_sum(X::Array{Float64,1}, window::Int64)

    # Compute rolling sum
    Y = @sync @distributed (+) for i=1:window
        @view(X[i:end-(window-i)])
    end

    # Return rolling sum
    return Y;
end

I think you might see better results for large windows and more complicated functions to roll. I do not know the RollingFunctions package very well. If there is some space I might do a commit.
sairus7
Nov 2019

See the following conversation, there are also some code examples in comments. In particular, this comment:

    Here is a minimal example of running mean, the same applies to higher order stats: using Statistics function runmean1(x::Vector{T}, n::Int64=10)::Vector{T} where {T<:Real} len = size(x,1) @assert n<len && n>1 "Argument n is out of bounds." out = zeros(len - n + 1) @inbounds for i = n:len out[i-n+1] = mean(view(x, i-n+1:i)) end return out end function runmean2(x::Vector{T}, n::Int64=10)::Vector{T} where {T<:Real} len = size(x,1) @assert n<len && n>1 "Arg… 

klaff
Nov 2019

I don’t think the rolling_sum function is amenable to parallel processing or multiple threads until the number of cores exceeds the length of the window, and then some. The out[i] = out[i-1]-a[i-1]+a[i+n-1] technique is inherently sequential, and so can’t really take advantage of SIMD. The other technique might be able to use SIMD but because it’s operations grow with length(data)*n rather than length(data), there’s a lot of inefficiency to be made up for.

EDIT: I take it back, but the problem would need to be split lengthwise, not at a deep loop level. So every 10,000 or so you’d reinitialize the sum and launch another sequentially computing task.
ggjp
Nov 2019

I wanted a rolling sum, not a cumulative sum.
tim.holy
Steward
Nov 2019

Yes, but you can subtract: since
ck=k∑i=1xi

then a rolling sum of the previous n entries is just ck−ck−n .
ggjp
Nov 2019

I see. Ok, maybe I’m falling into the premature optimization rabbit hole.
tim.holy
Steward
Nov 2019

To clarify, there probably isn’t a faster way: for a vector of length L, the cumulative sum can be computed in L operations. Therefore a rolling sum of length n, for arbitrary n, can be computed in 2L operations. A naive rolling sum of length n is n*L operations, which for n>2 is slower than using cumsum. For very large rolling sums, the difference will be dramatic.

This focus on operations count ignores roundoff errors, which are indeed muchmay be worse for the cumsum approach. If that’s important to you, then @klaff’s Rolling Sum is a better approach. That one is also 2L, so there’s no real reason not to use it.
ffevotte
Regular
Nov 2019

    This focus on operations count ignores roundoff errors, which are indeed much worse for the cumsum approach. If that’s important to you, then @klaff’s Rolling Sum is a better approach. That one is also 2L , so there’s no real reason not to use it.

Out of curiosity, why do you say that the cumsum approach is worse than the

    out[i] = out[i-1]-a[i-1]+a[i+n-1]

technique proposed in @klaff’s approach?

Admittedly I haven’t given much thought to this question, but I don’t see any obvious reason why one approach would be better than the other. And in some specific cases (for example when dealing with positive numbers), my intuition would even lead me to favor the cumsum approach (again, just intuition, I haven’t performed a serious error analysis…)
klaff
Nov 2019

Wouldn’t an approach around Base.cumsum need to allocate arrays for the two intermediate sums? Maybe I’m not thinking correctly about how that would work.
ffevotte
Regular
Nov 2019

No, there is only one array of cumulative sums. The two intermediate partial sums (that are subtracted from one another in the end) are two elements of the same array.

There could be a second array if you wanted to also store the rolling sums (instead of computing them on the fly, when the window size is known, using a single subtraction operation).
klaff
Nov 2019

Got it, thanks. Caffeine still being absorbed this morning.
tim.holy
Steward
Nov 2019

I haven’t done a serious analysis either. For the purposes of discussion let’s consider a list of numbers that are uniformly distributed between 0 and 1. The magnitude of the cumsum grows linearly with i, and consequently once you’ve summed 2/eps() of them together you’ll stop incrementing altogether due to a complete loss of precision. In contrast

out[i] = out[i-1]-a[i-1]+a[i+n-1]

intuitively seems like it should accumulate error as sqrt(i).
klaff
Nov 2019

The threaded version I wrote (trolling_sum) recomputes the sum at the beginning of each thread’s segment (necessary so the threads can be independent), which limits the accumulated error.
ffevotte
Regular
Nov 2019

    In contrast

    out[i] = out[i-1]-a[i-1]+a[i+n-1]

    intuitively seems like it should accumulate error as sqrt(i) .

On the other hand, this formula is prone to cancellations (where the relative error is unbounded), whereas in the cumsum of positive numbers, the relative error at each operation is (as you noted) bounded by eps().

But I’ll try to avoid derailing this thread any more, and perform a real error analysis instead of waving my hands :slight_smile:
tbeason
Nov 2019

I just want to pop in here and say that the beauty of RollingFunctions.jl is mostly in its ease. I’ve used it many times to create rolling versions of my own functions. It strikes the balance between general functionality and performance quite well. It already uses views and very tight loops.

If you are doing something simple like a sum, of course a specialized method will be faster.
