
#=

- wholesparts
  - rolling_wholesparts
  - tiling_wholesparts
  - running_wholesparts

  - wholes
  - rolling_wholes
  - tiling_wholes
  - running_wholes

  - parts
  - rolling_parts
  - tiling_parts
  - running_parts

=#

"""
    wholesparts(n, width, slide)
    wholesparts(; n, width, slide)

- wholesparts_rolling(n, width)
- wholesparts_tiling(n, width)
- wholesparts_running(n, width)

""" wholesparts

"""
    wholes(n, width, slide)
    wholes(; n, width, slide)

- wholes_rolling(n, width)
- wholes_tiling(n, width)
- wholes_running(n, width)

""" wholes

"""
    parts(n, width, slide)
    parts(; n, width, slide)

- parts_rolling(n, width)
- parts_tiling(n, width)
- parts_running(n, width)

""" parts

function wholesparts(n, width, slide)
    if n < width
        nwindows = 0
        nindices = n
        return (; nwindows, nindices)
    elseif slide < width
        nwindows = fld(n - width, slide)
        m = n - nwindows * slide
        nwindows += m >= width
        m -= slide
        if m == width
            nwindows += 1
            nindices = 0
        else
            nindices = m
        end
        return (; nwindows, nindices)
    elseif slide >= width
        nwindows, nindices = fldmod(n, slide)
        return (; nwindows, nindices)
    end
end

wholesparts(; n, width, slide) = wholesparts(n, width, slide)

rolling_wholesparts(n, width) = wholesparts(n, width, 1)
running_wholesparts(n, width) = rolling_wholesparts(n, width)
tiling_wholesparts(n, width)  = wholesparts(n, width, width)

@inline function wholes(n, width, slide)
    if n < width
        nwindows = 0
        return nwindows
    elseif slide < width
        nwindows = fld(n - width, slide)
        m = n - nwindows * slide
        nwindows += m >= width
        m -= slide
        if m == width
            nwindows += 1
        end
        return nwindows
    elseif slide >= width
        nwindows = fld(n, slide)
        return nwindows
    end
end

rolling_wholes(n, width) = wholes(n, width, 1)
running_wholes(n, width) = rolling_wholes(n, width)
tiling_wholes(n, width)  = wholes(n, width, width)

@inline function parts(n, width, slide)
    if n < width
        return n
    elseif slide < width
        nwindows = fld(n - width, slide)
        m = n - nwindows * slide
        m -= slide
        if m == width
            nindices = 0
        else
            nindices = m
        end
        return nindices
    elseif slide >= width
        return mod(n, slide)
    end
end

rolling_parts(n, width) = parts(n, width, 1)
running_parts(n, width) = rolling_parts(n, width)
tiling_parts(n, width)  = parts(n, width, width)

