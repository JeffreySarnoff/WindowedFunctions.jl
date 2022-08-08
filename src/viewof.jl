viewof(x::AbstractArray{T,1}) where {T} = view(x, :)
viewof(x::AbstractArray{T,2}) where {T} = view(x, :, :)
viewof(x::AbstractArray{T,3}) where {T} = view(x, :, :, :)
viewof(x::AbstractArray{T,4}) where {T} = view(x, :, :, :, :)
viewof(x::AbstractArray{T,5}) where {T} = view(x, :, :, :, :, :)
viewof(x::AbstractArray{T,6}) where {T} = view(x, :, :, :, :, :, :)

viewof(m::AbstractArray) = view(m, map(i -> 1:i, size(m))...)

viewofcols(m::AbstractArray{T,N}, columns::Vector) where {T,N} = view(m, :, columns)
viewofcols(m::AbstractArray{T,N}, columns) where {T,N} = view(m, :, [columns...])

viewofrows(m::AbstractArray{T,N}, rows::Vector) where {T,N} = view(m, rows, :)
viewofrows(m::AbstractArray{T,N}, rows) where {T,N} = view(m, [rows...], :)
