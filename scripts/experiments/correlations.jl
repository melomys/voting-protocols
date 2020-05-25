"""
plots the correlation matrix between given features of the model
"""


using Agents
using DataFrames
using StatsPlots
using PyPlot

include("../../src/model.jl")
include("../../src/model_factory.jl")
include("../../src/activation_model.jl")
include("../../src/view_model.jl")
include("../../src/evaluation.jl")
include("../../src/data_preparation.jl")


rat_fac = 2
steps = 30
quality_dimensions = 3

vote_count(model, model_df) = sum(map(x -> x.votes, model.posts))

quality_sum(model, model_df) = sum(map(
    x -> model.user_rating_function(x.quality, ones(quality_dimensions)),
    model.posts,
))

gain(model, model_df) =
    model_df[end, :ranking_rating_relative] -
    model_df[1, :ranking_rating_relative]

evaluation_functions = [
    area_under_curve,
    vote_count,
    quality_sum,
    gain,
    @model_property_function(rating_factor),
    @model_property_function(votes_exp),
    @model_property_function(time_exp)
]

sort!(evaluation_functions, by = x -> string(x))

model_properties = [
    ranking_rating,
    ranking_rating_relative,
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity)
]
agent_properties = [:vote_probability]

model_init_params = [(
    model_initiation,
    Dict(
        :scoring_function => [scoring_custom],
        :agent_step! => view_agent_step!,
        :PostType => ViewPost,
        :UserType => ViewUser,
        :rating_factor => [1:2:4...],
        :votes_exp => [7:3:15...],
        :time_exp => [0.3:0.3:1...],
        :user_rating_function => user_rating_exp
    ),
)]


corr_df = init_correlation_dataframe(evaluation_functions)

iterations = 20
for i = 1:iterations
    seed = abs(rand(Int))
    models = create_models(model_init_params; seed = seed)

    for j = 1:length(models)
        model = models[j]

        agent_df, model_df = run!(
            model,
            model.agent_step!,
            model.model_step!,
            steps;
            agent_properties = agent_properties,
            model_properties = model_properties,
        )

        global model
        global model_df

        push!(corr_df, map(x -> x(model, model_df), evaluation_functions))
    end
end

plotly()
corrplot(
    Array{Float64}(corr_df),
    bins = 10,
    label = map(string, names(corr_df)),
    markercolor = cgrad(:inferno),
)
