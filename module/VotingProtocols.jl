module VotingProtocols


"""
model_files = cd(readdir, "../src/models")

for model_file in model_files
    include("../src/models/model_file")
end
"""


include("../src/user_creation.jl")

include("../src/models/model.jl")
include("../src/models/downvote_model.jl")
include("../src/models/random_model.jl")
include("../src/models/view_model.jl")


include("../src/model_factory.jl")
include("../src/rating.jl")
include("../src/scoring.jl")
include("../src/evaluation.jl")
include("../src/data_collection.jl")

include("../src/default.jl")

include("../src/export_r.jl")




export collect_model_data, default_evaluation_functions, default_model_properties
export standard_model, view_model, downvote_model, random_model
export scoring_activation, scoring_best, scoring_hacker_news, scoring_random, scoring_reddit_best, scoring_reddit_hot, scoring_unfair_view, scoring_view, scoring_view_activation, scoring_view_exp, scoring_worst
export user_rating, user_rating_dist2, user_rating_dist1, user_rating_exp, user_rating_exp2
export wilson_score, vote_difference, vote_partition
export ranking_rating_relative, dcg, ndcg, gini, area_under_curve, area_under_gini, sum_gradient, quality_sum, gain, mean_user_view, mean_user_vote, post_views, post_scores, vote_count, end_position, quality
export export_rds
end
