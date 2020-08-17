using Distributed
using RCall
using LinearAlgebra
using Distributions
println(nprocs())
@time @everywhere using VotingProtocols



model_init_params = [
    (:all_models, Dict(
    :steps => 100,
    :sorted => 1,
    :relevance_gravity => [0, 1.8]
    #:user => [[(0.9, user()),(0.1, extreme_user(1))], [(0.9,user()),(0.1, extreme_user(-1))]]
    #:quality_distribution => MvNormal(zeros(3), I(3)*10.0)
    )),
    (
        [up_and_downvote_system],
        Dict(:rating_metric => [metric_hacker_news],
        :init_score => 30,
        :deviation_function => [no_deviation],
    )),
    #(upvote_system, Dict(
#    :rating_metric => metric_activation,
#    :user_opinion_function => [consensus],
#    :init_score => [30]
#    ))
]

model_init_params = [
    (
        :all_models,
        Dict(
            :user_opinion_function => [consensus, dissent],
            :relevance_gravity => [0, 1.8]
        ),
    ),
    (
        upvote_system,
        Dict(
            :rating_metric => [metric_activation, metric_hacker_news, metric_view, metric_view_metric_activation],
            :init_score => [-10:10:30...],
            :deviation_function => [no_deviation, mean_deviation]
        ),
    ),
    (
        up_and_downvote_system,
        Dict(
            :rating_metric => [metric_reddit_hot, scoring_reddit_best],
            :deviation_function => [no_deviation, mean_deviation]
        )
    ),
    (
        upvote_system,
        Dict(
            :rating_metric => [scoring_random],
        ),
    ),
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
