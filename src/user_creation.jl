function user()
    function add_user!(model)
        activity, voting_probability = rand(model.rng_user_posts, model.activity_voting_probability_distribution)
        add_agent!(
            model,
            rand(model.rng_user_posts, model.quality_distribution),
            sigmoid(voting_probability),
            sigmoid(activity),
            rand(model.rng_user_posts, model.concentration_scale),
        )
    end
end

function extreme_user(extremeness)
    function add_extreme_user!(model)
        add_agent!(
            model,
            rand(model.rng_user_posts, model.quality_distribution) - ones(length(model.quality_distribution))*extremeness,
            Float64(rand(model.rng_user_posts, [0.55])),
            1,
            rand(model.rng_user_posts, [500]),
        )
    end
end

function uniform_user()
    function add_uniform_user!(model)
        activity, voting_probability = rand(model.rng_user_posts, model.activity_voting_probabiliy_distribution)
        add_agent!(
            model,
            rand(model.rng_user_posts, [mean(quality_distribution)]),
            sigmoid(voting_probability),
            sigmoid(activity),
            rand(model.rng_user_posts, model.concentration_scale),
        )
    end
end
