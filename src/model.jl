

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


mutable struct Post
    quality::Array
    votes::Int64
    timestamp::Int64
    score::Float64
end

mutable struct User <: AbstractAgent
    id::Int
    quality_perception::Array
    vote_probability::Float64
    concentration::Int64
    voted_on::Array{Post}
end

function User(id::Int, quality_perception::Array{Float64}, vote_probability::Float64, concentration::Int64)
    User(id, quality_perception,vote_probability, concentration, Post[])
end

function scoring(votes, timestamp, time)
    (votes + 1) / (time - timestamp)
end

function user_rating(post_quality, user_quality_perception)
    sum(post_quality .* user_quality_perception)/sum(user_quality_perception)
end

function model_initiation(;
    start_posts = 100,
    start_users = 100,
    new_user_probability = 0,
    vote_probability_scale = 1,
    frontpagesize = 10,
    new_posts_per_step = 3,
    seed = 0,
)
    Random.seed!(seed)
    posts = Post[]
    for i = 1:start_posts
        push!(posts, Post(rand(quality_distribution), 0, 0, 0))
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
        time
    )
    model = ABM(User; properties = properties)
    for i = 1:start_users
        add_agent!(
            model,
            rand(quality_distribution),
            rand() / vote_probability_scale,
            rand(1:10)
        )
    end
    return model
end

function agent_step!(user, model)
    for i in 1:rand(1:model.n)
        post = model.posts[model.ranking[i]]
        if user_rating(post.quality, user.quality_perception) > user.vote_probability && !in(post, user.voted_on)
            push!(user.voted_on,post)
            post.votes += 1
        end
    end
end

function model_step!(model)
    for i in 1:model.new_posts_per_step
        push!(model.posts, Post(rand(quality_distribution), 0, model.time, 0))
        model.n += 1
    end

    if rand() < model.new_user_probability
        add_agent!(
            model,
            rand(quality_distribution),
            rand() / model.vote_probability,
            rand(1:10)
        )
    end

    model.time += 1

    for i = 1:model.properties[:n]
        model.posts[i].score =
            scoring(model.posts[i].votes, model.posts[i].timestamp, model.time)
    end

    votes_idx =
        sortperm(map(x -> x.score, model.posts))
    model.ranking = votes_idx
end


macro get_post_data(s, f)
    name = Symbol(f, "_", eval(s))
    return :(function $name(model)
        collected = map(x -> getproperty(x, $s), model.posts)
        $f(collected)
    end)
end
