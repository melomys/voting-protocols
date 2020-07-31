using VotingProtocols
using Distributed





model_init_params = [
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 0,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function =>[no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_dist2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_dist2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 20,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 0,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_dist2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_dist2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_activation,
            :init_score => 10,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_activation,
            :init_score => 30,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_activation,
            :init_score => 30,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_dist2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_activation,
            :init_score => 30,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_dist2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 0,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 2,
            :user_rating_function => user_rating_exp2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 0,
            :user_rating_function => user_rating_dist2,
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 2,
            :user_rating_function => user_rating_dist2,
        )
    )
]


export_data(model_init_params,"deviation")
