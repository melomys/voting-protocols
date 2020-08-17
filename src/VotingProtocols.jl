module VotingProtocols

using Agents
using Distributions
using DataFrames
using LinearAlgebra
using RCall

include("user_creation.jl")

include("models/upvote_system.jl")
include("models/up_and_downvote_system.jl")
include("models/random_model.jl")


include("model_factory.jl")
include("rating.jl")
include("scoring.jl")
include("evaluation.jl")
include("data_collection.jl")

include("default.jl")

include("export_r.jl")




export collect_model_data, default_evaluation_functions, default_model_properties, default_models
export upvote_system, view_model, up_and_downvote_system, random_model
export metric_activation, scoring_best, metric_hacker_news, scoring_random, scoring_reddit_best, metric_reddit_hot, scoring_unfair_view, metric_view, metric_view_metric_activation, metric_view_exp, scoring_worst
export user_rating, dissent, user_rating_dist1, user_rating_exp, consensus
export wilson_score, vote_difference, vote_partition
export dcg, ndcg, gini, area_under_curve, area_under_gini, sum_gradient, quality_sum, gain, mean_user_view, mean_user_vote, post_views, post_scores, vote_count, end_position, quality
export export_rds, export_data
export user, extreme_user, uniform_user
export create_models, post_data, relative_post_data
export sigmoid, @model_property_function, @get_post_data, @area_under, @rating_correlation, @model_df_column
export no_deviation, std_deviation, mean_deviation, posts_with_no_views
end
