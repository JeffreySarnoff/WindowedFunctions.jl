# rapidwindowing

const RapidElTypes = Union{Int8, Int16, Int32, Int64,
                           UInt8, UInt16, UInt32, UInt64,
                           Float16, Float32, Float64,
                           Char, String, AbstractString,
                           Symbol}


RapidArrayTypes(n) = map(T->Array{T,n}, Base.uniontypes(RapidElTypes))

rapid1types = RapidArrayTypes(1)
rapid2types = RapidArrayTypes(2)
rapid3types = RapidArrayTypes(3)
rapid4types = RapidArrayTypes(4)

                           [Array{N,T} for T in Base.uniontypes(RapidEltypes) for N]




const RapidlySequencedData{V<:Vector{T}} where {T<:}, T2, D<:Union{}} where {T, D} = Union{Vector{}}
function viewing(x::)

#=
    the outer box is the entire data source, an n-length vector of T
        this data source is comprised of exactly n elememts, 
        some elements may occur more than once,
        the elements may appear sequences in any n-permutation
    the data source is, in this case, 1D totally connected seq of n elements
        the intial element is at idx 1, the finall element is at idx=n

    the inner contiguous section the current position of the entire window
        the inner window covers winspan sequentially connected data elements from the source
        the initial element covered is at relidx1, the final element covered is at relidxn

        before the windowing operation, after the windowing is initializedz,
           the relidx1 == dataidx1 and the relidxn == dataidxn
        just after the first unit slide of the window,
           the relidx1 == dataidx1+1 and there relidxn == datainxn+1
           
    each relative index from relidx1 through relidxn
        relatively indexes an element within the data source
    all of the elements within the window at its current place
        are indicated by individual positional contguity ▢▢▢▢▢▢



             ---––––––––––––––––----––
            |▢▢▢▢▢▢                   |
            |                         |
            | ▢▢▢▢▢▢                  |
            |  ▢▢▢▢▢▢                 |
            |                         |
            |        ▢▢▢▢▢▢           |
            |                         |
            |              ▢▢▢▢▢▢     |
            |               ▢▢▢▢▢▢    |
            |                         |
            |                   ▢▢▢▢▢▢|
             ---––––––––––––––––----––

             ---––––––––––––––––----––
            |▢                        |  (maybe, depends on function)
            |▢▢                       |
            |▢▢▢                      |
            |▢▢▢▢                     |
            |▢▢▢▢▢                    |
            |▢▢▢▢▢▢                   |
            |                         |
            | ▢▢▢▢▢▢                  |
            |  ▢▢▢▢▢▢                 |
            |                         |
            |        ▢▢▢▢▢▢           |
            |                         |
            |              ▢▢▢▢▢▢     |
            |               ▢▢▢▢▢▢    |
            |                         |
            |                   ▢▢▢▢▢▢|
            |                    ▢▢▢▢▢|
            |                     ▢▢▢▢|
            |                      ▢▢▢|
            |                       ▢▢|
            |                        ▢| (maybe, depends on function)
             ---––––––––––––––––----––

""" move_window

const WindowInfo = 
    NamedTuple{(:winspan, :firstidx, :finalidx, :firstval, :finalval), NTuple{5,Int}}

function advance_window(datasrc::WindowedData, winfo::WindowInfo)
    winspan = winspan(datasrc)
    secondidx = 1 + winfo.firstidx
    topidx = 1 + winfo.finalids 
    newstart, newstop = winfo.start + 1, winfo.stop + 1
    ((newstop <= datasrc.srcspan) && (newstart > 0)) || 
        WindowBoundsErr((winspan=winspan,  start=newstart, stop=newstop))
    newstart, newstop
end  

function update_window(datasrc::WindowedData, currentwindow::WindowInfo, windowedfunc::WindowedFunction)
    newstart, newstop = advance_window(datasrc, currentwindow)
    oldestval = datasrc.source[newstart]
    newestval = datasrc.source[newstop]
    updatefrom, updatewith = windowedfunc.update(datasrc, newstart, newstop, 
                                                 currentwindow.updatefrom, currentwindow.updatewith)
    CurrentWindowInfo((datasrc.windowspan, newstart, newstop, oldestval, newestval, updatefrom, updatewith))
end
  
