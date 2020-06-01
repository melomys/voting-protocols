function downvote_model(;
    user_rating_function = downvote_user_rating,
    agent_step! = downvote_agent_step!,
    qargs...)
    model_initiation(;
    user_rating_function = user_rating_function,
    agent_step! = agent_step!,
    qargs...
    )
end

function downvote_user_rating(post_quality, user_quality_perception)
    dim = length(post_quality)
    1 - sqrt(sum(((post_quality)-(user_quality_perception)).^2))/sqrt(dim)
end

vals = []
function downvote_agent_step!(user,model)
    for i= 1:minimum([user.concentration, model.n])
    #for i = 1 : rand(1:model.n)
        post = model.posts[model.ranking[i]]
        if user.vote_probability > rand(model.rng) &&  !in(post, user.voted_on)
            push!(vals, model.user_rating_function(post.quality, user.quality_perception))
            if model.user_rating_function(post.quality, user.quality_perception) > 0.35
                post.votes += 1
            else
                post.votes -= 1
            end
            push!(user.voted_on, post)
        end
    end
end


function pseudo_downvote_agent_step!(user,model)
    for i= 1:minimum([user.concentration, model.n])
    #for i = 1 : rand(1:model.n)
        post = model.posts[model.ranking[i]]
        if user.vote_probability > rand(model.rng) &&  !in(post, user.voted_on)
            push!(vals, model.user_rating_function(post.quality, user.quality_perception))
            if model.user_rating_function(post.quality, user.quality_perception) > 0.35
                #post.votes += 1
            else
                post.votes -= 1
            end
            push!(user.voted_on, post)
        end
    end
end
