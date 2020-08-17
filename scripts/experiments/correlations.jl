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
include("../../src/models/random_model.jl")
include("../../src/models/up_and_downvote_system.jl")
include("../../src/evaluation.jl")
include("../../src/data_collection.jl")
include("../../src/scoring.jl")
include("../../src/rating.jl")

timestamp_func = @post_property_function(:timestamp)
score_func = @post_property_function(:score)

@time begin
    rat_fac = 2
    steps = 300
    quality_dimensions = 3

    vote_count(model, model_df) = sum(map(x -> x.votes, model.posts))

    quality_sum(model, model_df) = sum(map(
        x -> model.user_opinion_function(x.quality, ones(quality_dimensions)),
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
        @model_property_function(:user_opinion_function),
        @model_property_function(:rating_metric),
        @model_property_function(:model_type),
        @model_property_function(:seed),
        @rating_correlation(quality, end_position),
        @rating_correlation(timestamp_func, score_func)
    ]

    sort!(evaluation_functions, by = x -> string(x))

    model_init_params = [
        (
            view_model,
            Dict(
                :rating_metric => [scoring_custom],
                :rating_factor => [1:2:4...],
                :votes_exp => [7:3:15...],
                :time_exp => [0.3:0.3:1...],
                :user_opinion_function => user_rating,
            ),
        ),
        (
            random_model,
            Dict(:user_opinion_function => [user_rating, user_rating_exp]),
        ),
        (up_and_downvote_system, Dict()),
        (upvote_system, Dict()),
    ]

    model_init_params2 = [(
        upvote_system,
        Dict(
            :rating_metric => [
                metric_activation,
                scoring_reddit,
                metric_hacker_news,
                scoring_best,
            ],
        ),
    )]


    #corr_df = init_correlation_dataframe(evaluation_functions)

    corr_df = DataFrame()

    iterations = 20
    for i = 1:iterations
        println("$((i-1)/iterations*100) %")
        seed = abs(rand(Int32))
        models = create_models(model_init_params2; seed = seed)

        for j = 1:length(models)
            tmp_model = models[j]
            agent_df, model_df = run!(
                tmp_model,
                tmp_model.agent_step!,
                tmp_model.model_step!,
                steps;
                agent_properties = [],
                model_properties = default_view_model_properties,
            )

            ab_model = tmp_model
            ab_model_df = model_df
            global ab_model
            global ab_model_df

            #push!(
            #    corr_df,
            #    map(x -> x(ab_model, ab_model_df), evaluation_functions),
            #)
            corr_df = vcat(corr_df, [map(x -> x(ab_model, ab_model_df), evaluation_functions)])
        end
    end
end

plotly()
unary_corr_df = unary_columns(corr_df)
"""
corrplot(
    Array{Float64}(unary_corr_df),
    bins = 10,
    label = map(string, names(unary_corr_df)),
    markercolor = cgrad(:inferno),
)
"""


R"""
saveRDS($(robject(corr_df)), file = \"df2.rds\")
"""
