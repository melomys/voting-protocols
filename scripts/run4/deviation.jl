using VotingProtocols
using Distributed





model_init_params = [
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 0,
            :relevance_gravity => 0,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function =>[no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_opinion_function => dissent,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_hacker_news,
            :init_score => 50,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_opinion_function => dissent,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_view,
            :init_score => 20,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 0,
            :relevance_gravity => 0,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_opinion_function => dissent,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_opinion_function => dissent,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_activation,
            :init_score => 10,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_activation,
            :init_score => 30,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_activation,
            :init_score => 30,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 0,
            :user_opinion_function => dissent,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_activation,
            :init_score => 30,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :gravity => 2,
            :relevance_gravity => 2,
            :user_opinion_function => dissent,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 0,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 2,
            :user_opinion_function => consensus,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 0,
            :user_opinion_function => dissent,
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => metric_reddit_hot,
            :init_score => 30000,
            :vote_evaluation => vote_difference,
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
            :relevance_gravity => 2,
            :user_opinion_function => dissent,
        )
    )
]


export_data(model_init_params,"deviation")
