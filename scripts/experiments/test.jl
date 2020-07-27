using Distributed
using RCall
using LinearAlgebra
using Distributions
println(nprocs())
@time @everywhere using VotingProtocols



model_init_params = [
    (
        :all_models,
        Dict(
            :user_rating_function => [user_rating_exp2, user_rating_dist2],
        ),
    ),
    #(
    #    standard_model,
    #    Dict(
    #        :scoring_function => [scoring_activation, scoring_hacker_news, scoring_view, scoring_view_activation, scoring_view_exp],
    #        :init_score => [-10:10:30...],
    #        :deviaton_function => [no_deviation, mean_deviation]
    #    ),
    #),
    (
        downvote_model,
        Dict(
            :scoring_function => [scoring_reddit_hot, scoring_reddit_best],
            :deviation_function => [no_deviation, mean_deviation]
        )
    ),
    #(
    #    standard_model,
    #    Dict(
    #        :scoring_function => [scoring_random],
    #    ),
    #),
]

model_properties = default_model_properties
evaluation_functions = default_evaluation_functions
iterations = 1
pack = 1
@time begin
@sync @distributed for i=1:iterations

model_dfs, corr_df = collect_model_data(
    model_init_params,
    model_properties,
    evaluation_functions,
    pack)
    export_rds(corr_df, model_dfs, "gngngn")
    end
end
