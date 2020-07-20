function user()
    function add_user!(model)
        add_agent!(
            model,
            rand(model.rng_user_posts, model.quality_distribution),
            rand(model.rng_user_posts, model.activity_distribution),
            rand(model.rng_user_posts, model.voting_probability_distribution),
            Int64(round(rand(
                model.rng_user_posts,
                model.concentration_distribution,
            ))),
        )
    end
end

function extreme_user(extremeness)
    function add_extreme_user!(model)
        add_agent!(
            model,
            rand(model.rng_user_posts, model.quality_distribution) - ones(model.quality_dimensions) * extremeness,
            1.0,
            1.0,
            rand(model.rng_user_posts, [500]),
        )
    end
end

function uniform_user()
    function add_uniform_user!(model)
        add_agent!(
            model,
            rand(model.rng_user_posts, [mean(quality_distribution)]),
            rand(model.rng_user_posts, model.activity_distribution),
            rand(model.rng_user_posts, model.voting_probability_distribution),
            Int64(round(rand(
                model.rng_user_posts,
                model.concentration_distribution,
            ))),
        )
    end
end
