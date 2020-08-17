function view_model(;
    agent_step! = view_agent_step!,
    rating_metric = metric_view,
    qargs...,
)
    upvote_system(;
        agent_step! = agent_step!,
        rating_metric = rating_metric,
        model_type = view_model,
        qargs...,
    )
end

function ViewUser(
    id::Int,
    quality_perception::Array{Float64},
    vote_probability::Float64,
    activity_probability::Float64,
    concentration::Int64,
)
    ViewUser(
        id,
        quality_perception,
        vote_probability,
        activity_probability,
        concentration,
        AbstractPost[],
        AbstractPost[],
    )
end



function view_agent_step!(user, model)
    if rand(model.rng_user_posts) < user.activity_probability
        for i = 1:minimum([user.concentration, model.n])
            post = model.posts[model.ranking[i]]
            if model.user_opinion_function(
                post.quality,
                user.quality_perception,
            ) > rating_quantile(model,1 - user.vote_probability) && !in(post, user.voted_on)
                push!(user.voted_on, post)
                post.votes += 1

                push!(
                    model.user_ratings,
                    model.user_opinion_function(
                        post.quality,
                        user.quality_perception,
                    ),
                )

            end
            if !in(post, user.viewed)
                push!(user.viewed, post)
                post.views += 1
            end
        end
    end
end
