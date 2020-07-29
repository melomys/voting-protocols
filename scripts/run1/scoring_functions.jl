using VotingProtocols
using Distributed

model_init_params = [
    (
        :all_models,
        Dict(
            :user_rating_function => [user_rating_exp2, user_rating_dist2],
            :relevance_gravity => [0, 1.8]
        ),
    ),
    (
        standard_model,
        Dict(
            :scoring_function => [scoring_activation, scoring_hacker_news, scoring_view, scoring_view_activation],
            :init_score => [-10:10:30...],
            :deviation_function => [no_deviation, mean_deviation]
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => [scoring_reddit_hot, scoring_reddit_best],
            :deviation_function => [no_deviation, mean_deviation]
        )
    ),
    (
        standard_model,
        Dict(
            :scoring_function => [scoring_random],
        ),
    ),
]





export_data(model_init_params,"scoring_functions")
