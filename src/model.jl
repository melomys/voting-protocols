using DrWatson
@quickactivate

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
select_distribution = truncated(Normal(0, 2), 0, 1)


mutable struct User <: AbstractAgent
    id::Int
    quality_perception::Array
    vote_probability::Float64
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

    votes = zeros(Int, start_posts)
    quality = rand(quality_distribution, start_posts)
    timestamps = zeros(Int, start_posts)
    scores = zeros(Int, start_posts)

    params = @dict(
        votes,
        quality,
        timestamps,
        scores,
        start_users,
        new_user_probability,
        new_content_probability,
        vote_probability_scale,
        frontpagesize,
        seed
    )
    println(start_users)
    println(params[:start_users])
    return params
end

function scoring(votes, timestamp, time)
    -votes * (time - timestamp)
end

function model_initiation(;
    votes,
    quality,
    timestamps,
    scores,
    start_users = 100,
    new_user_probability = 0,
    new_content_probability = 0.1,
    vote_probability_scale = 10,
    frontpagesize = 10,
    seed = 0
)
    Random.seed!(seed)
    n = length(votes)
    window = [1:n...]

    properties = @dict(
        n,
        votes,
        quality,
        timestamps,
        scores,
        new_user_probability,
        new_content_probability,
        vote_probability_scale,
        frontpagesize,
        window
    )
    println(start_users)
    model = ABM(User; properties = properties)
    for i in 1:start_users
        add_agent!(
            model,
            rand(quality_distribution),
            rand() / vote_probability_scale,
        )
    end
    return model
end

function agent_step!(agent, model)
    if rand() < agent.vote_probability
        idx = Int64(ceil(
            rand(select_distribution) * model.properties[:frontpagesize],
        ))
        post_idx = model.properties[:window][idx]
        post_quality = model.properties[:quality][post_idx]
        if sum(post_quality .* agent.quality_perception) < 0
            model.properties[:votes][post_idx] += 1
        end
    end
end

function model_step!(model)
    println("MODEL_STEP")
    if rand() < model.properties[:new_content_probability]
        append!(model.properties[:quality], rand(quality_distribution))
        append!(model.properties[:votes], 0)
        append!(model.properties[:timestamps], 0)
        append!(model, properties[:scores], 0)
        model.properties[:n] += 1
    end
    if rand() < model.properties[:new_user_probability]
        add_agent!(
            step!model,
            rand(quality_distribution),
            rand() / model.properties[:vote_probability],
        )
    end

    for i = 1:model.properties[:n]
        model.properties[:score] = scoring(
            model.properties[:votes][i],
            model.properties[:timestamps][i],
            12,
        )
    end

    votes_idx = partialsortperm(
        model.properties[:scores],
        1:model.properties[:frontpagesize],
    )
    model.properties[:window] = votes_idx

end

params = create_params()
model = model_initiation(;params...)

#model_properties = Dict(:votes => [mean, median])
agent_properties = Dict(:vote_probability => [sum])



data = step!(model, agent_step!,3, agent_properties)
println(data)
println("running thru")
