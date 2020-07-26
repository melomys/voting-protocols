using Distributed
using VotingProtocols

model_init_params = [
    (
        :all_models,
        Dict(
            :user_rating_function => [
                user_rating_exp,
                user_rating,
                user_rating_exp2,
                user_rating_dist2,
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
        [standard_model, random_model],
        Dict(
            :scoring_function => [scoring_activation, scoring_hacker_news],
            :init_score => [0:10:100... ],
            :deviation_function => [mean_deviation, std_deviation],
        ),
    ),
    (
        view_model,
        Dict(
            :scoring_function =>
                [scoring_view_activation, scoring_view, scoring_view_exp],
        ),
    ),
    (
        downvote_model,
        Dict(:scoring_function => [scoring_reddit_hot, scoring_reddit_best]),
    ),
    (
        standard_model,
        Dict(
            :scoring_function => [scoring_best, scoring_worst, scoring_random],
        ),
    ),
]

@time begin
    model_dfs, corr_df = collect_model_data(
        model_init_params,
        default_model_properties,
        default_evaluation_functions,
        1000,
    )
end

export_rds(corr_df, model_dfs, "models")