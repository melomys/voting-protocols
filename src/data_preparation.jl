

""" returns dataframe, each row holds the given parameter over time of one post.
    time in the dataframe is relative to the creation of the post.
    the dataframe is right-padded with the last value of each post.
"""
function relative_post_data(data)
    padding = NaN
    ncols = maximum(map(length, data))
    left_padded = [vcat(data[i], ones(ncols - length(data[i]))*padding) for i in 1:length(data)]
    left_padded_transformed = [map(x -> x[i], left_padded) for i in 1:length(left_padded[1])]
    filter_padding(x) = filter(!isnan, x)
    right_padded = map(x -> vcat(filter_padding(x),ones(length(data) - length(filter_padding(x)))*padding), left_padded_transformed)
    DataFrame(right_padded)
end

""".
returns dataframe, each row holds the given parameter over time of one post.
the dataframe ist left-padded with zeros.
"""
function post_data(data)
    padding = NaN
    ncols = maximum(map(length, data))
    DataFrame(Matrix(DataFrame([vcat(data[i], ones(ncols - length(data[i]))*padding) for i in 1:length(data)]))')
end



function columnname(model_params)
    string(reduce(
        (x, y) -> x * "_" * y,
        map(x -> string(model_params[x]), collect(keys(model_params))),
    ))
end

function init_result_dataframe(models_params)
    DataFrame(Dict(map(
        x -> (columnname(Dict(x)), []),
        get_params(model_init_params),
    )))
end
