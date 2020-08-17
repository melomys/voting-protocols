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
include("../../src/export_r.jl")
include("../../src/default.jl")

timestamp_func = @post_property_function(:timestamp)
score_func = @post_property_function(:score)


step = 100


evaluation_functions = default_evaluation_functions

model_properties = [
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
        :all_models,
        Dict(
            :user_opinion_function => [
                user_rating_exp,
                user_rating,
                consensus,
                user_rating_dist1,
            ],
            #:activity_distribution => [Beta(2,5,5), Beta(1,5), Beta(1, 10), Beta(2.5,10, Beta(5,10), Beta(7.5,10))],
            #:voting_probability_distribution => [Beta(2,5,5), Beta(1,5), Beta(1, 10), Beta(2.5,10, Beta(5,10), Beta(7.5,10))]
            #:concentration => [Poisson(30), Poisson(50), Poisson(70), Uniform(30,70)]
            #:steps => [5,10,50,100,300,500,1000],
            #:start_users => [50,100,300,500, 1000],
            #:new_posts_per_step => [10,20,50,100],
            #:start_posts => [5,10, 50, 100, 300, 500, 1000],
            #:quality_dimensions => [1,2,3,5,10,50],
            #:vote_evaluation => [vote_difference, vote_partition, wilson_score],
            #:time_exp => [0.1, 0.7, 1, 1.0, 1.5, 2],
        ),
    ),
    (
        [upvote_system, random_model],
        Dict(
            :rating_metric => [metric_activation, metric_hacker_news],
            :init_score => [0:10:100],
            :deviation_function => [mean_deviation, std_deviation],
        ),
    ),
    (
        view_model,
        Dict(
            :rating_metric =>
                [metric_view_metric_activation, metric_view, metric_view_exp],
        ),
    ),
    (
        up_and_downvote_system,
        Dict(:rating_metric => [metric_reddit_hot, scoring_reddit_best]),
    ),
    (
        upvote_system,
        Dict(
            :rating_metric => [scoring_best, scoring_worst, scoring_random],
        ),
    ),
]


model_init_params_user = [(
    upvote_system,
    Dict(
    :rating_metric => metric_activation,
    :init_score => 10,
    :user_opinion_function => [user_rating_exp, consensus, dissent],
    :concentration_distribution => [Uniform(10,70), Uniform(10, 100), Uniform(30,70), Uniform(30,100), Uniform(70,100)],
    :activity_voting_probability_distribution => [MvLogNormal(MvNormal([-2, 0], [1.0 0.8; 0.8 1.0])),
    MvLogNormal(MvNormal([-2, 0], [1.0 0.8; 0.8 1.0])),MvLogNormal(MvNormal([-2, 0], [1.0 0.8; 0.8 1.0])),
    MvLogNormal(MvNormal([0, 0], [1.0 0.8; 0.8 1.0])), MvLogNormal(MvNormal([-2, -2], [1.0 0.8; 0.8 1.0])),
    ],
    :quality_dimensions => [1:3...]
        )

)]

model_init_params_rating_function = [(
    up_and_downvote_system,
    Dict(
    :rating_metric => metric_reddit_hot,
    :user_opinion_function => [user_rating, user_rating_exp, consensus, dissent]
    )
)]

model_init_params_concentration = [(
    upvote_system,
    Dict(
    :rating_metric => metric_reddit_hot,
    :concentration_distribution => [Uniform(10,70), Uniform(10, 100), Uniform(30,70), Uniform(30,100), Uniform(70,100)],
    )
)]

iterations = 2


for i=1:Threads.nthreads()-2
    Threads.@spawn begin
        model_dfs, corr_df = collect_model_data(
            model_init_params_concentration,
            default_model_properties,
            default_evaluation_functions,
            trunc(Int,iterations/Threads.nthreads()),
        )
        export_rds(corr_df, model_dfs, "concentration")
    end
end
"""
@time begin

    model_dfs, corr_df = collect_model_data(
        model_init_params_concentration,
        default_model_properties,
        default_evaluation_functions,
        1000,
    )
end
"""
