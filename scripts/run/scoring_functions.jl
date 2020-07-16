using VotingProtocols
using Distributed

model_init_params = [
    (
        :all_models,
        Dict(
            :user_rating_function => [user_rating_exp],
        ),
    ),
    (
        [standard_model, random_model],
        Dict(
            :scoring_function => [scoring_activation, scoring_hacker_news, scoring_view, scoring_view_activation, scoring_view_exp],
            :init_score => [-10:0:10:30... ],
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => [scoring_reddit_hot, scoring_reddit_best]
            :model_step! => [model_step!, random_model_step!]),
    ),
    (
        standard_model,
        Dict(
            :scoring_function => [scoring_random],
        ),
    ),
]





export_data(model_init_params,"scoring_functions")
