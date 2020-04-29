using DrWatson
@quickactivate

using Agents
using DataFrames
using Statistics
using Distributions
using LinearAlgebra
using Random

# Definition of quality
# N(μ = 0, σ = 1)
# MVN(M = [0,..,0], Σ = positiv definite Cov Matrix)
quality_dimensions = 3

M = [0 for i = 1:quality_dimensions]
sigma_col_vec = [0.2 for i = 1:quality_dimensions]
sigma_row_vec = [0.5 for i = 1:quality_dimensions]
Σ = sigma_col_vec * sigma_row_vec'

for i = 1:quality_dimensions
    Σ[i, i] = 1
end
quality_distribution = Distributions.MvNormal(M, Σ)
select_distribution = truncated(Normal(0,2),0,1)

mutable struct Post <: AbstractAgent
    id::Int
    quality::Vector{Float64}
    votes::Int64
    timestamp::Int64
    score::Float64
end

function create_params(;
    start_posts = 10,
    start_users = 100,
    new_user_probability = 0,
    new_content_probability = 0.1,
    vote_probability_scale = 10,
    frontpagesize = 10,
    seed = 19,
)

    params = @dict(
        start_posts,
        start_users,
        new_user_probability,
        new_content_probability,
        vote_probability_scale,
        frontpagesize,
        seed
    )
    return params
end

function scoring(post, time)
    -(post.votes + 1) / (time - post.timestamp)
end

function model_initiation(;
    start_posts = 10,
    start_users = 100,
    new_user_probability = 0,
    new_content_probability = 0.1,
    vote_probability_scale = 10,
    frontpagesize = 10,
    seed = 0
)
    Random.seed!(seed)


    quality_perception = rand(quality_distribution,start_users)
    vote_probability = rand(start_users) ./ vote_probability_scale
    c = start_users
    time = 0

    properties = @dict(
        c,
        time,
        quality_perception,
        vote_probability,
        new_user_probability,
        new_content_probability,
        frontpagesize,
    )
    model = ABM(Post; properties = properties)
    for i in 1:start_posts
        add_agent!(
            model,
            rand(quality_distribution),
            zeros(3)...
        )
    end
    return model
end

function agent_step!(agent, model)
    agent.score = scoring(agent, model.properties[:time])
end

function model_step!(model)
    if rand() < model.properties[:new_content_probability]
        add_agent!(model, rand(quality_distribution), 0, model.properties[:time], 0)
    end
    posts = collect(values(model.agents))

    votes_idx = partialsortperm(posts, 1:model.properties[:frontpagesize], by= x-> x.score)
    window = posts[votes_idx]
    for i in 1:model.properties[:c]
        if rand() < model.properties[:vote_probability][i]


            idx = Int64(ceil(rand(select_distribution) * model.properties[:frontpagesize]))
            view_post = window[idx]
            if sum(view_post.quality .* model.properties[:quality_perception][i]) < 0
               view_post.votes += 1
           end
       end
    end
    model.properties[:time] += 1
end



params = create_params()
model = model_initiation(;params...)

properties = Dict(:votes => [median, mean])
data = step!(model, agent_step!,model_step!,30,properties)
println(data)
