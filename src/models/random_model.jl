function random_model(;
    random_scoring_factor = 0.5,
    model_step! = random_model_step!,
    deviation_function = mean_deviation,
    qargs...,
)
    standard_model(;
        model_step! = model_step!,
        random_scoring_factor = random_scoring_factor,
        deviation_function = deviation_function,
        model_type = random_model,
        qargs...,
    )
end

function random_model_step!(model)
    for i = 1:model.new_posts_per_step
        push!(
            model.posts,
            model.PostType(
                model.rng,
                model.quality_distribution,
                model.time,
                model.init_score,
            ),
        )
        model.n += 1
    end

    for i = 1:model.n
        model.posts[i].score =
            model.scoring_function(model.posts[i], model.time, model)
    end

    if rand() < model.new_user_probability
        add_agent!(
            model,
            rand(model.rng, model.quality_distribution),
            rand(model.rng) / model.vote_probability,
            rand(model.rng, 1:10),
        )
    end

    random_deviation = model.deviation_function(model)

    for (index,post) in enumerate(model.posts)
        post.score += random_deviation[index]
    end

    model.ranking = sortperm(map(x -> -x.score, model.posts))
    model.time += 1

end


function mean_deviation(model)
    mean_scores = mean(map(x -> x.score, model.posts))
    function to_map(post)
        dist = abs(mean_scores - post.score)
        rand(-dist:0.01:dist)
    end
    map(to_map, model.posts)
end

function std_deviation(model)
    std_scores = std(map(x -> x.score, model.posts))
    map(x -> rand(-std_scores:0.01:std_scores), model.posts)
end
