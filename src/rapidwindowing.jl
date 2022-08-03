# rapidwindowing

const EightNames = (:windowspan, :start, :stop, :oldestval, :newestval, :updatefrom, :updatewith)
const EightInts  = Tuple{Int, Int, Int, Int, Int, Int, Int, Int}

const CurrentWindowInfo = NamedTuple{EightNames, EightInts}

function updatewindowinfo(datasrc::WindowedData, windowedfunc::WindowedFunction, wi::CurrentWindowInfo)
  newstart, newstop = wi.start + 1, wi.stop + 1
  newstop <= datasrc.srcspan && newstart > 0 || DomainError(datasrc.srcspan,  newstart, newstop)
  oldestval = datasrc.source[newstart]
  newestval = datasrc.source[newstop]
  updatefrom, upsatewith = windowedfunc.update(datasrc, newstart, newstop, wi.updatefrom, wi.updatewith)
  CurrentWindowInfo((wi.windowspan, newstart, newstop, oldestval, newestval, updatefrom, updatewith)
end 
  
