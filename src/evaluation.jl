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


"""
Sigmoid function
"""
sigmoid(x) = 1/(1+ℯ^(-x*0.5))


"""
calculates the index when the maximum of the given parameter is reached
"""
function index_maximum_reached(arr)
    arr = filter(!isnan,arr)
    maximum = arr[end]
    if maximum == 0
        return 1
    elseif arr[end-1] < arr[end]
        return length(arr)
    else
        last = maximum
        for i in length(arr):-1:1
            if arr[i] < last
                return i
            else
                last = arr[i]
            end
        end
    end
end
