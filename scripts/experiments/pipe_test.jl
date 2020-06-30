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


steps = 300
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
    @model_property_function(:activity_voting_probability),
    @model_property_function(:concentration_scale),
    @model_property_function(:init_score),
    @model_property_function(:new_posts_per_step),
    @model_property_function(:model_id),
    @model_property_function(:model_type),
    @model_property_function(:quality_dimensions),
    @model_property_function(:scoring_function),
    @model_property_function(:seed),
    @model_property_function(:start_posts),
    @model_property_function(:start_users),
    @model_property_function(:time_exp),
    @model_property_function(:user_ratings),
    @model_property_function(:user_rating_function),
    @model_property_function(:votes_exp),
    @rating_correlation(quality, end_position),
    @rating_correlation(timestamp_func, score_func)
]

sort!(evaluation_functions, by = x -> string(x))

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
        [standard_model, random_model, downvote_model],
        Dict(
            :scoring_function => [
                scoring_activation,
                scoring_reddit_hot,
                scoring_hacker_news,
            ],
            :user_rating_function =>
                [user_rating_exp, user_rating, user_rating_exp],
            :UserType => ViewUser,
            :init_score => [0, 10, 20],
            :activity_voting_probability_distribution => [
                MvNormal([-4, 0], [1.0 0.8; 0.8 1.0]), #kleiner erwartungswert für activity, so sind nicht alle user auf einmal aktiv
                MvNormal([0, 0], [1.0 0.1; 0.1 1.0]),
            ],
            :deviation_function => [mean_deviation, std_deviation],
            :time_exp => 0.5,
        ),
    ),
    (
        view_model,
        Dict(
            :scoring_function =>
                [scoring_view_activation, scoring_view, scoring_view_exp],
            :user_rating_function =>
                [user_rating_exp, user_rating, user_rating_exp],
            :UserType => ViewUser,
            :init_score => [0, 10, 20],
            :activity_voting_probability_distribution => [
                MvNormal([-4, 0], [1.0 0.8; 0.8 1.0]), #kleiner erwartungswert für activity, so sind nicht alle user auf einmal aktiv
                MvNormal([0, 0], [1.0 0.1; 0.1 1.0]),
            ],
            :time_exp => [0.1, 0.5, 1],
        ),
    ),
    (standard_model, Dict(:scoring_function => [scoring_best, scoring_worst])),
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
        model_init_params,
        model_properties,
        evaluation_functions,
        10,
    )
end


files = cd(readdir,"data")
numbers = map(x -> parse(Int32,match(r"([0-9]+)",x)[1]),files)

no = maximum(numbers) + 1

df_file = "data/df$(no).rds"
model_dfs_file = "data/model_dfs$(no).rds"

R"""
saveRDS($(robject(corr_df)), file = $df_file)
"""

#R"""
#saveRDS($(robject(cat_model_dfs(model_dfs))), file = $model_dfs_file)
#"""
