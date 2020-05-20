function ranking_rating(model)
    rating = 0
    for i = 1:model.n
        rating +=
            1 / i * user_rating(
                model.posts[model.ranking[i]].quality,
                ones(quality_dimensions),
            )
    end
    return rating
end

function ranking_rating_relative(model)
    by_quality = sortperm(model.posts, by=x -> - user_rating(x.quality,ones(quality_dimensions)))
    rating = 0
    for i = 1:model.n
        rating += 1/i * user_rating(model.posts[by_quality[i]].quality,ones(quality_dimensions))
    end
    ranking_rating(model)/rating
end

function trapezoidial_rule(points)
    sum(points) - 1 / 2 * (points[1] + points[end])
end


function area_under_curve(model_df)
    trapezoidial_rule(model_df[!, :ranking_rating])
end

function gain(model_df)
    sign(model_df[2, :ranking_rating] - model_df[1, :ranking_rating]) *
    sign(model_df[end, :ranking_rating] - model_df[2, :ranking_rating])
end

""" returns dataframe, each row holds the given parameter over time of one post.
    time in the dataframe is relative to the creation of the post.
    the dataframe is right-padded with the last value of each post.
"""
function relative_post_data(data)
    padding = -1
    ncols = maximum(map(length, data))
    left_padded = [vcat(data[i], ones(ncols - length(data[i]))*padding) for i in 1:length(data)]
    left_padded_transformed = [map(x -> x[i], left_padded) for i in 1:length(left_padded[1])]
    right_padded = map(x -> vcat(filter(filt-> filt!= padding,x),ones(length(data) - length(filter(filt-> filt!= padding,x)))*filter(filt-> filt!= padding,x)[end]), left_padded_transformed)
    DataFrame(right_padded)
end

""".
returns dataframe, each row holds the given parameter over time of one post.
the dataframe ist left-padded with zeros.
"""
function post_data(data;padding=NaN)
    ncols = maximum(map(length, data))
    DataFrame(Matrix(DataFrame([vcat(data[i], ones(ncols - length(data[i]))*padding) for i in 1:length(data)]))')
end

"""
Sigmoid function
"""
sigmoid(x) = 1/(1+ℯ^(-x*0.5))
