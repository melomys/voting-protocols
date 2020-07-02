# Per iteration
# parameters: model


function ranking_rating(model)
    rating = 0
    for i = 1:model.n
        rating +=
            1 / i * user_rating(
                model.posts[model.ranking[i]].quality,
                ones(model.quality_dimensions),
            )
    end
    return rating
end

function ranking_rating_relative(model)
    by_quality = sortperm(model.posts, by=x -> - user_rating(x.quality,ones(model.quality_dimensions)))
    rating = 0
    for i = 1:model.n
        rating += 1/i * user_rating(model.posts[by_quality[i]].quality,ones(model.quality_dimensions))
    end
    ranking_rating(model)/rating
end


function gini(model, model_df = Nothing)
    s = 0
    n = sum(map(post -> post.score, model.posts))
    for p1 in model.posts
        for p2 in model.posts
            s = s + abs(p1.score - p2.score)
        end
    end
    s/(2*n*length(model.posts))
end

# per model
# parameters: model, model_df


function area_under_curve(model, model_df)
    trapezoidial_rule(model_df[!, :ranking_rating_relative])
end


function sum_gradient(model, model_df)
    ranking = model_df[!, :ranking_rating_relative]
    sum(map(i ->  ranking[i+1] - ranking[i] ,1:length(ranking)-1))
end

quality_sum(model, model_df) = sum(map(
    x -> model.user_rating_function(x.quality, ones(model.quality_dimensions)),
    model.posts,
))

function gain(model, model_df)
    model_df[end, :ranking_rating_relative] -
    model_df[1, :ranking_rating_relative]
end

function mean_user_view(model, model_df)
    mean(x -> length(x.viewed)/model.n, allagents(model))
end

function mean_user_vote(model, model_df)
    mean(x -> length(x.voted_on)/model.n,allagents(model))
end

function post_views(model, model_df)
    views = map(x -> x.views, model.posts)
    return hist_dataframe(views,model)
end

vote_count(model, model_df) = sum(map(x -> x.votes, model.posts))


# evaluation of rich get richer effects only
function quality_first_quantile(model, model_df)
    max_score = model.posts[model.ranking[1]].score
    min_score = model.posts[model.ranking[end]].score
    quality_quantile = 0
    for post in model.posts
        if  post.score >= 0.75*(max_score-min_score)
            quality_quantile += model.user_rating_function(post.quality, ones(model.quality_dimensions))
        end
    end
    return quality_quantile/quality_sum(model,model_df)
end


# per post in models
# parameters: post, model, model_df

function end_position(post, model, model_df)
    index = findfirst(isequal(post), model.posts)
    findfirst(isequal(index), model.ranking)
end

function quality(post,model,model_df)
    model.user_rating_function(post.quality, ones(model.quality_dimensions))
end

# Helpers


function trapezoidial_rule(points)
    sum(points) - 1 / 2 * (points[1] + points[end])
end


"""
Sigmoid function
"""
sigmoid(x) = 1/(1+ℯ^(-x*0.5))


function hist_dataframe(array, model)
    dic = Dict()
    for i in 0:length(allagents(model))
        dic[i] = length(filter(x -> x == i, array))
    end
    return DataFrame(dic)
end


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
