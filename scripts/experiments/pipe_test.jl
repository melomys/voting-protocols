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
include("../../src/models/downvote_model.jl")
include("../../src/evaluation.jl")
include("../../src/data_collection.jl")
include("../../src/scoring.jl")
include("../../src/rating.jl")
include("../../src/export_r.jl")

timestamp_func = @post_property_function(:timestamp)
score_func = @post_property_function(:score)


steps = 50


evaluation_functions = default_evaluation_functions

model_properties = [
    ranking_rating,
    ranking_rating_relative,
    @model_property_function(:model_id),
    @model_property_function(:votes_exp),
    @model_property_function(:time_exp),
    @model_property_function(:seed),
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity),
]

model_init_params2 = [
    (
        [standard_model, random_model],
        Dict(
            :scoring_function => [
                scoring_activation,
                scoring_hacker_news,
            ],
            :user_rating_function =>
                [user_rating_exp, user_rating, user_rating_exp2],
            :UserType => ViewUser,
            :PostType => ViewPost,
            :init_score => [0, 10, 20, 30],
            :activity_voting_probability_distribution => [
                MvNormal([-4, 0], [1.0 0.8; 0.8 1.0]), #kleiner erwartungswert für activity, so sind nicht alle user auf einmal aktiv
                MvNormal([0, 0], [1.0 0.1; 0.1 1.0]),
            ],
            :deviation_function => [mean_deviation, std_deviation],
            :time_exp => [0.1,0.5,0.7],
            :steps => [steps]
        ),
    ),
    (
        view_model,
        Dict(
            :scoring_function =>
                [scoring_view_activation, scoring_view, scoring_view_exp],
            :user_rating_function =>
                [user_rating_exp, user_rating, user_rating_exp2],
            :UserType => ViewUser,
            :init_score => [0, 10, 20, 30],
            :activity_voting_probability_distribution => [
                MvNormal([-4, 0], [1.0 0.8; 0.8 1.0]), #kleiner erwartungswert für activity, so sind nicht alle user auf einmal aktiv
                MvNormal([0, 0], [1.0 0.1; 0.1 1.0]),
            ],
            :time_exp => [0.1, 0.5, 1],
            :steps => [steps]
        ),
    ),
    (downvote_model, Dict(
        :scoring_function => [
            scoring_reddit_hot,
            scoring_reddit_best,
        ],
        :user_rating_function =>
            [user_rating_exp, user_rating, user_rating_exp2],
        :UserType => ViewUser,
        :PostType => ViewPost,
        :activity_voting_probability_distribution => [
            MvNormal([-4, 0], [1.0 0.8; 0.8 1.0]), #kleiner erwartungswert für activity, so sind nicht alle user auf einmal aktiv
            MvNormal([0, 0], [1.0 0.1; 0.1 1.0]),
        ],
        :steps = [steps],
    ),
    ),
    (standard_model, Dict(:scoring_function => [scoring_best, scoring_worst],
    :steps => steps)),
]

model_init_params = [(
    standard_model,
    Dict(
        :scoring_function =>
            [scoring_activation, scoring_reddit_hot, scoring_hacker_news],
        :activity_voting_probabiltiy_distribution =>
            [MvNormal([-4, 0], [1.0 0.8; 0.8 1.0])],
        :init_score => [0, 10, 20],
        :user_rating_function => [user_rating_exp, user_rating],
    ),
)]

@time begin
    model_dfs, corr_df = collect_model_data(
        model_init_params2,
        model_properties,
        evaluation_functions,
        10,
    )
end

export_rds(corr_df, model_dfs)
