# deviation


"""
    no_deviation(model)

applies no deviation function
"""
function no_deviation(model)
    zeros(length(model.posts))
end

"""
    mean_deviation(model)

applies mean deviation function
"""
function mean_deviation(model)
    mean_scores = mean(map(x -> x.score, model.posts))
    function to_map(post)
        dist = abs(mean_scores - post.score)
        rand(model.rng_model,-dist:0.01:dist)
    end
    map(to_map, model.posts)
end


"""
    std_deviation(model)

applies std deviation function
"""
function std_deviation(model)
    std_scores = std(map(x -> x.score, model.posts))
    map(x -> rand(model.rng_model,-std_scores:0.01:std_scores), model.posts)
end
