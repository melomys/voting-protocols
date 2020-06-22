

mutable struct ViewPost <: AbstractPost
    quality::Array
    votes::Int64
    views::Int64
    timestamp::Int64
    score::Float64
end

function ViewPost(rng, quality_distribution, time, init_score = 0)
    ViewPost(rand(rng, quality_distribution), 0, 0, time, init_score)
end

mutable struct ViewUser <: AbstractUser
    id::Int
    quality_perception::Array
    vote_probability::Float64
    activity_probability::Float64
    concentration::Int64
    voted_on::Array{AbstractPost}
    viewed::Array{AbstractPost}
end


function view_model(;
    PostType = ViewPost,
    UserType = ViewUser,
    agent_step! = view_agent_step!,
    scoring_function = scoring_view,
    rating_factor = 1,
    qargs...,
)
    standard_model(;
        PostType = PostType,
        UserType = UserType,
        agent_step! = agent_step!,
        scoring_function = scoring_function,
        rating_factor = rating_factor,
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
    if rand(model.rng) < user.activity_probability
        for i = 1:minimum([user.concentration, model.n])
            post = model.posts[model.ranking[i]]
            if model.user_rating_function(
                post.quality,
                user.quality_perception,
            ) > user.vote_probability && !in(post, user.voted_on)
                push!(user.voted_on, post)
                post.votes += 1

                push!(
                    model.user_ratings,
                    model.user_rating_function(
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


function scoring_view(post, time, model)
    ((post.votes + 1)^2 / (post.views + 1)^0.7) /
    (time - post.timestamp + 1)^(1)
end

function scoring_view_exp(post, time, model)
    post.views^post.votes / (time - post.timestamp + 1)^0.1
end

function scoring_view_no_time(post, time, model)
    ((post.votes + 1)^2 / (post.views + 1)^0.2)^0.3 /
    (time - post.timestamp + 1)^(0.1)
end

function scoring_unfair_view(post, time, model)
    (post.views - post.score) / (time - post.timestamp + 1)^(0.3)
end

function scoring_view_activation(post, time, model)
    ((post.votes) / (post.views) - post.score) / (time - post.timestamp + 1)
end
