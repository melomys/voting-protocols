using DrWatson
@quickactivate

using Agents
using DataFrames
using Statistics
using Distributions
using LinearAlgebra
using Random

include("collect.jl")

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
    id::Int64
    quality_perception::Array
    vote_probability::Float64
end

mutable struct Post <: AbstractAgent
    id::Int64
    quality::Vector{Float64}
    votes::Int64
    timestamp::Int64
    score::Float64
end

function scoring(votes, timestamp, time)
    - (votes+1) * (time - timestamp)
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

    votes = zeros(Int, start_posts)
    quality = rand(quality_distribution, start_posts)
    timestamps = zeros(Int, start_posts)
    scores = zeros(Int, start_posts)

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
    if rand() < model.properties[:new_content_probability]
        append!(model.properties[:quality], rand(quality_distribution))
        append!(model.properties[:votes], 0)
        append!(model.properties[:timestamps], 0)
        append!(model, properties[:scores], 0)
        model.properties[:n] += 1
    end
    if rand() < model.properties[:new_user_probability]
        add_agent!(model,
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


function run!(model, agent_step!,model_step!,n; when = true, when_model = when, agent_properties=nothing, model_properties=nothing)
        df_agent = init_agent_dataframe(model, agent_properties)
        df_model = init_model_dataframe(model, model_properties)
        if n isa Integer
            if when == true; for c in eachcol(df_agent); sizehint!(c, n); end; end
            if when_model == true; for c in eachcol(df_model); sizehint!(c, n); end; end
        end

        for s in 0:n
            collect_agent_data!(df_agent, model, agent_properties, s)
            collect_model_data!(df_model, model, model_properties, s)
            step!(model, agent_step!, model_step!, 1)
        end
        return df_agent, df_model
end





model = model_initiation()

model_properties = [:votes, :scores]
agent_properties = [:vote_probability]

model_df = init_model_dataframe(model, model_properties)
agent_df = init_agent_dataframe(model, agent_properties)

agent_df, model_df = run!(model, agent_step!, model_step!, 30, agent_properties=agent_properties, model_properties = model_properties)
data = step!(model, agent_step!,model_step!,3, agent_properties)
println(data)
