"""
plots the correlation matrix between given features of the model
"""


using Agents
using DataFrames
using StatsPlots
using RCall

using PyPlot

include("../../src/models/model.jl")
include("../../src/model_factory.jl")
include("../../src/models/view_model.jl")
include("../../src/evaluation.jl")
include("../../src/data_collection.jl")
include("../../src/scoring.jl")
include("../../src/rating.jl")

timestamp_func = @post_property_function(:timestamp)
score_func = @post_property_function(:score)

@time begin
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
        sum_gradient,
        @model_property_function(:rating_factor),
        @model_property_function(:votes_exp),
        @model_property_function(:time_exp),
        @model_property_function(:user_ratings),
        @model_property_function(:user_rating_function),
        @rating_correlation(quality, end_position),
        @rating_correlation(timestamp_func, score_func)
    ]

    sort!(evaluation_functions, by = x -> string(x))

    model_init_params = [(
        view_model,
        Dict(
            :scoring_function => [scoring_custom],
            :rating_factor => [1:2:4...],
            :votes_exp => [7:3:15...],
            :time_exp => [0.3:0.3:1...],
            :user_rating_function => user_rating_exp,
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
                agent_properties = [],
                model_properties = default_view_model_properties,
            )

            global model
            global model_df

            push!(corr_df, map(x -> x(model, model_df), evaluation_functions))



        end
    end
end

plotly()
unary_corr_df = unary_columns(corr_df)
corrplot(
    Array{Float64}(unary_corr_df),
    bins = 10,
    label = map(string, names(unary_corr_df)),
    markercolor = cgrad(:inferno),
)


R"""
saveRDS($(robject(corr_df)), file = \"df.rds\")
"""
