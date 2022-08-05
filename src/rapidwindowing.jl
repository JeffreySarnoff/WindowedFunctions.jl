# rapidwindowing

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
           
        
             ___________________
            |                   |
            |                   |
            |                   |
            |                   |
            |                   |
             -–––––––––––––––––––

    advance sliding window
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
  
