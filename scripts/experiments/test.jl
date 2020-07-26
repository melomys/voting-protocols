using Distributed
using RCall
using LinearAlgebra
using Distributions
println(nprocs())
@time @everywhere using VotingProtocols

model_init_params = [
    (:all_models, Dict(
    :steps => 100,
    #:user => [[(0.9, user()),(0.1, extreme_user(1))], [(0.9,user()),(0.1, extreme_user(-1))]]
    :quality_distribution => MvNormal(zeros(3), I(3)*10.0)
    )),
    (
        [downvote_model],
        Dict(:scoring_function => [scoring_reddit_hot],

        :user_rating_function => [user_rating_exp,user_rating_dist2],
    )),
    #(standard_model, Dict(
#    :scoring_function => scoring_activation,
#    :user_rating_function => [user_rating_exp2],
#    :init_score => [30]
#    ))
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
