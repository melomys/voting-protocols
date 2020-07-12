using Distributed
addprocs(1)

@everywhere push!(LOAD_PATH, "./module")
@everywhere using VotingProtocols
"""
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/models/model.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/model_factory.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/models/view_model.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/models/random_model.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/models/downvote_model.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/evaluation.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/data_collection.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/scoring.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/rating.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/export_r.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/default.jl")


include("../../src/models/model.jl")
include("../../src/model_factory.jl")
include("../../src/models/view_model.jl")
include("../../src/models/random_model.jl")
include("../../src/models/downvote_model.jl")
include("../../src/evaluation.jl")
@everywhere include("/home/ludwig/Bachelorarbeit/voting-protocols/src/data_collection.jl")
include("../../src/scoring.jl")
include("../../src/rating.jl")
include("../../src/export_r.jl")
include("../../src/default.jl")

"""
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



iterations = 5

#Threads.@threads
for i=1:iterations

model_dfs, corr_df = @fetch collect_model_data(
    model_init_params,
    default_model_properties,
    default_evaluation_functions,
    5)
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
