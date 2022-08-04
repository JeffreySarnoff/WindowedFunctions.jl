# rapidwindowing

const EightNames = (:windowspan, :start, :stop, :oldestval, :newestval, :updatefrom, :updatewith)
const EightInts  = Tuple{Int, Int, Int, Int, Int, Int, Int, Int}

const CurrentWindowInfo = NamedTuple{EightNames, EightInts}

function advance_window(datasrc::WindowedData, currentwindow::CurrentWindowInfo)
    newstart, newstop = wi.start + 1, wi.stop + 1
    ((newstop <= datasrc.srcspan) && (newstart > 0)) || 
        DomainError(datasrc.srcspan,  newstart, newstop)
    newstart, newstop
end  

function update_window(datasrc::WindowedData, currentwindow::CurrentWindowInfo, windowedfunc::WindowedFunction)
    newstart, newstop = advance_window(datasrc, currentwindow)
    oldestval = datasrc.source[newstart]
    newestval = datasrc.source[newstop]
    updatefrom, upsatewith = windowedfunc.update(datasrc, newstart, newstop, 
                                                 currentwindow.updatefrom, currentwindow.updatewith)
    CurrentWindowInfo((datasrc.windowspan, newstart, newstop, oldestval, newestval, updatefrom, updatewith)
end
  

DomainError(seqlenth, startidx, stopidxn) = 
    error("DomainErr(seqlength = $(seqlength), start=$(startidx), stop=$(stopidx)")