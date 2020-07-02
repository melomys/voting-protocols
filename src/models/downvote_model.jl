function downvote_model(;
    user_rating_function = downvote_user_rating,
    agent_step! = downvote_agent_step!,
    qargs...,
)
    standard_model(;
        user_rating_function = user_rating_function,
        agent_step! = agent_step!,
        model_type = downvote_model,
        qargs...,
    )
end

function downvote_user_rating(post_quality, user_quality_perception)
    dim = length(post_quality)
    1 - sqrt(sum(((post_quality) - (user_quality_perception)) .^ 2)) / sqrt(dim)
end

vals = []


function downvote_agent_step!(user, model)
    if rand(model.rng_user_posts) < user.activity_probability
        for i = 1:minimum([user.concentration, model.n])
            post = model.posts[model.ranking[i]]
            if !in(post, user.voted_on)
                if model.user_rating_function(
                    post.quality,
                    user.quality_perception,
                ) < user.vote_probability / 2
                    post.downvotes += 1
                    push!(user.voted_on, post)
                elseif model.user_rating_function(
                    post.quality,
                    user.quality_perception,
                ) > 1 - user.vote_probability / 2
                    post.votes += 1
                    push!(user.voted_on, post)
                end

                push!(
                    model.user_ratings,
                    model.user_rating_function(
                        post.quality,
                        user.quality_perception,
                    ),
                )
                if !in(post, user.viewed)
                    push!(user.viewed, post)
                    post.views += 1
                end

            end
        end
    end
end


function pseudo_downvote_agent_step!(user, model)
    for i = 1:minimum([user.concentration, model.n])
        post = model.posts[model.ranking[i]]
        if model.user_rating_function(post.quality, user.quality_perception) >
           user.vote_probability && !in(post, user.voted_on)
            push!(
                vals,
                model.user_rating_function(
                    post.quality,
                    user.quality_perception,
                ),
            )
            if model.user_rating_function(
                post.quality,
                user.quality_perception,
            ) > 0.35
                #post.votes += 1
            else
                post.votes -= 1
            end
            push!(user.voted_on, post)
        end
    end
end
