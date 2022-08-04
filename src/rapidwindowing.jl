# rapidwindowing

const WindowInfo = 
    NamedTuple{(:span, :firstidx, :finalidx, :firstval, :finalval), NTuple{5,Int}}

function advance_window(datasrc::WindowedData, currentwindow::WindowInfo)
    newstart, newstop = wi.start + 1, wi.stop + 1
    ((newstop <= datasrc.srcspan) && (newstart > 0)) || 
        WindowBoundsErr((sourcelen=datasrc.srcspan,  start=newstart, stop=newstop))
    newstart, newstop
end  

function update_window(datasrc::WindowedData, currentwindow::WindowInfo, windowedfunc::WindowedFunction)
    newstart, newstop = advance_window(datasrc, currentwindow)
    oldestval = datasrc.source[newstart]
    newestval = datasrc.source[newstop]
    updatefrom, updatewith = windowedfunc.update(datasrc, newstart, newstop, 
                                                 currentwindow.updatefrom, currentwindow.updatewith)
    CurrentWindowInfo((datasrc.windowspan, newstart, newstop, oldestval, newestval, updatefrom, updatewith)
end
  
