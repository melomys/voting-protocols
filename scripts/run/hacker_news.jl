using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [
    (
        [standard_model,random_model],
        Dict(
            :scoring_function => [scoring_hacker_news,scoring_activation],
            :init_score => [-10, 0, 10, 20, 30],
            :steps => [5, 10, 30, 50, 100, 300, 500],
            :start_users => [5,10,50,100, 300, 500],
            :start_posts => [5,10,50,100, 300, 500],
            :new_posts_per_step => [1,5,10,20,30],


        ),
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
export_rds(corr_df, model_dfs, "hacker_news")
    end
end
