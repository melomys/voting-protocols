

mutable struct ViewPost <: APost
    quality::Array
    votes::Int64
    views::Int64
    timestamp::Int64
    score::Float64
end

function ViewPost(rng)
    ViewPost(rand(rng, quality_distribution), 0, 0, 0, 0)
end

function ViewPost(rng,time)
    ViewPost(rand(rng, quality_distribution),0,0,time,0)
end

function view_agent_step!(user, model)
    for i = 1:rand(model.rng, 1:model.n)
        post = model.posts[model.ranking[i]]
        if model.user_rating_function(post.quality, user.quality_perception) >
           user.vote_probability && !in(post, user.voted_on)
            push!(user.voted_on, post)
            post.votes += 1
            post.views += 1
        elseif !in(post,user.voted_on)
            post.views += 1
        end
    end
end


function scoring_view(post, time)
    (post.votes / post.views)^2 / (time - post.timestamp)^(0.1)
end
