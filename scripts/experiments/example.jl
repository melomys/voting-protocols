model_configs = [
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_reddit_hot,
            :model_step! => random_model_step!,
            :deviation_function => [
                mean_deviation,
                std_deviation],
        ),
    ),
    (
        [standard_model, downvote_model],
        Dict(
            :scoring_function => [
                scoring_activation,
                scoring_hacker_news],
            :gravity => [0.5, 1.0, 1.5, 2.0],
        ),
    ),
    (
        :all_models,
        Dict(
            :user_rating_function => user_rating_exp
        ),
    ),
]
