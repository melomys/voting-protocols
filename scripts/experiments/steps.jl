using Distributed
#@time using VotingProtocols
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [
    (
        upvote_system,
        Dict(
            :rating_metric => [metric_activation],
            :init_score => [30],
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => [metric_reddit_hot],
            :user_opinion_function => [dissent],
        ),
    ),
    (
        random_model,
        Dict(
            :rating_metric => [metric_hacker_news],
        )
    ),
    (:all_models, Dict(:steps => [5, 10, 30, 50, 100, 300, 500])),
]



iterations = 1000
@time begin
#Threads.@threads
@sync @distributed for i=1:iterations

model_dfs, corr_df = collect_model_data(
    model_init_params,
    default_model_properties,
    default_evaluation_functions,
    5)
export_rds(corr_df, model_dfs, "steps")
    end
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
