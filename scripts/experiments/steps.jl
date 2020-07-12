using Distributed

@everywhere using VotingProtocols

model_init_params = [
    (
        standard_model,
        Dict(
            :scoring_function => [scoring_activation],
            :init_score => [10],
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => [scoring_reddit_hot],
            :user_rating_function => [user_rating_dist2],
        ),
    ),
    (
        random_model,
        Dict(
            :scoring_function => [scoring_hacker_news],
        )
    ),
    (:all_models, Dict(:steps => [5]))#, 10, 30, 50, 100, 300, 500])),
]



iterations = 100

#Threads.@threads
for i=1:iterations

model_dfs, corr_df = @fetch collect_model_data(
    model_init_params,
    default_model_properties,
    default_evaluation_functions,
    100)
export_rds(corr_df, model_dfs, "steps")
    end


"""
@time begin
    model_dfs, df = collect_model_data(
        model_init_params,
        default_model_properties,
        default_evaluation_functions,
        5,
    )
end

export_rds(df, model_dfs, "steps")
"""
