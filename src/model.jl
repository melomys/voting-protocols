

#export User, Post, model_initiation, agent_step!, model_step!, @get_post_data
using DrWatson

using Agents
using DataFrames
using Statistics
using Distributions
using LinearAlgebra
using Random

# Quality Dimensions
quality_dimensions = 3

M = [0 for i = 1:quality_dimensions]
sigma_col_vec = [0.2 for i = 1:quality_dimensions]
sigma_row_vec = [0.5 for i = 1:quality_dimensions]
Σ = sigma_col_vec * sigma_row_vec'

for i = 1:quality_dimensions
    Σ[i, i] = 1
end

quality_distribution = Distributions.MvNormal(M, Σ)

abstract type AbstractPost end
abstract type AbstractUser <: AbstractAgent end

mutable struct Post <: AbstractPost
    quality::Array
    votes::Int64
    timestamp::Int64
    score::Float64
end

mutable struct User <: AbstractUser
    id::Int
    quality_perception::Array
    vote_probability::Float64
    concentration::Int64
    voted_on::Array{AbstractPost}
end

function Post(rng)
    Post(rand(rng, quality_distribution), 0, 0, 0)
end

function Post(rng, time)
    Post(rand(rng, quality_distribution), 0, time)
end

function Post(rng, time, init_score)
    Post(rand(rng, quality_distribution), 0, time, init_score)
end

function User(
    id::Int,
    quality_perception::Array{Float64},
    vote_probability::Float64,
    concentration::Int64,
)
    User(
        id,
        quality_perception,
        vote_probability,
        concentration,
        AbstractPost[],
    )
end

function scoring(post, time, model)
    (post.votes + 1)^2 / (time - post.timestamp + 1)^(0.1)
end

function scoring_custom(post,time,model)
    (post.votes+1)^model.votes_exp / (time - post.timestamp + 1)^model.time_exp
end

function scoring_hacker_news(post, time, model)
    (post.votes - 1)^8 / (time - post.timestamp + 1)^1.8
end

function scoring_random(post, time, model)
    rand()
end

function scoring_best(post, time, model)
    user_rating(post.quality, ones(quality_dimensions))
end

function scoring_worst(post, time, model)
    - scoring_best(post, time,model)
end

function user_rating(post_quality, user_quality_perception)
    sum(post_quality .* user_quality_perception)
end

function user_rating_exp(post_quality, user_quality_perception)
    sum(post_quality .^ user_quality_perception)
end


function model_initiation(;
    start_posts = 100,
    start_users = 100,
    new_user_probability = 0,
    vote_probability_scale = 1,
    frontpagesize = 10,
    new_posts_per_step = 3,
    scoring_function = scoring,
    user_rating_function = user_rating,
    seed = 0,
    agent_step! = agent_step!,
    model_step! = model_step!,
    PostType = Post,
    UserType = User,
    init_score = 0,
    qargs...,
)
    rng = MersenneTwister(seed)
    posts = PostType[]
    for i = 1:start_posts
        push!(posts, PostType(rng))
    end

    n = start_posts
    ranking = [1:start_posts...]
    time = 0


    properties = @dict(
        n,
        posts,
        new_user_probability,
        vote_probability_scale,
        new_posts_per_step,
        frontpagesize,
        ranking,
        scoring_function,
        user_rating_function,
        time,
        agent_step!,
        model_step!,
        rng,
        PostType,
        UserType,
        init_score
    )

    for qarg in qargs
        properties[qarg[1]] = qarg[2]
    end


    model = ABM(UserType; properties = properties)
    for i = 1:start_users
        add_agent!(
            model,
            rand(rng, quality_distribution),
            rand(rng) / vote_probability_scale,
            rand(rng, 1:10),
        )
    end
    return model
end

function agent_step!(user, model)
    for i = 1:rand(model.rng, 1:model.n)
        post = model.posts[model.ranking[i]]
        if model.user_rating_function(
            post.quality,
            user.quality_perception
        ) > user.vote_probability && !in(post, user.voted_on)
            push!(user.voted_on, post)
            post.votes += 1
        end
    end
end

function model_step!(model)
    for i = 1:model.n
        model.posts[i].score =
            model.scoring_function(model.posts[i], model.time,model)
    end


    for i = 1:model.new_posts_per_step
        push!(model.posts, model.PostType(model.rng, model.time,model.init_score))
        model.n += 1
    end

    if rand() < model.new_user_probability
        add_agent!(
            model,
            rand(model.rng, quality_distribution),
            rand(model.rng) / model.vote_probability,
            rand(model.rng, 1:10),
        )
    end

    model.ranking = sortperm(map(x -> -x.score, model.posts))
    model.time +=1

end

macro get_post_data(s, f)
    name = Symbol(f, "_", eval(s))
    return :(function $name(model)
        collected = map(x -> getproperty(x, $s), model.posts)
        $f(collected)
    end)
end

macro model_property_function(property)
    name = Symbol("",property)
    return :(function $property(model, model_df)
        model.$property
    end)
end
