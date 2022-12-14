
# module specific exception tests
#
#   ValidateSpan(sequence_length, window_span)
#   ValidateWeights(weights, window_span)

struct SpanException <: Exception
     msg::String
end

SpanError(sequence_length, window_span) =
    throw(SpanException("The window span $(window_span) exceeds the sequence length $(sequence_length).")))

ValidateSpan(sequence_length, window_span) =
    ((window_span > 0) && (sequence_length >= window_span)) || SpanError(sequence_length, window_span)

struct NWeightsException <: Exception
     msg::String
end

NWeightsError(nweights, window_span) =
    throw(NWeightsException("The window span is not equal to the number of weights ($(window_span) != $(nweights))."))

ValidateWeights(nweights::Int, window_span) =
    (nweights == window_span) || NWeightsError(nweights, window_span)

struct NormalizedWeightsException <: Exception
     msg::String
end

NormalizedWeightsError(weights) =
    throw(NormalizedWeightsException("The weights do not sum to ~1 (sum = $(sum(weights)))."))

ValidateNormalizedWeights(weights) =
    (isapprox(sum(weights), 1.0; rtol=eps(eltype(weights))) || NormalizedWeightsError(weights))

ValidateWeights(weights, window_span) =
    (ValidateWeights(length(weights), window_span); ValidateNormalizedWeights(weights)) 
