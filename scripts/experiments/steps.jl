include("../../src/models/model.jl")
include("../../src/model_factory.jl")
include("../../src/models/view_model.jl")
include("../../src/models/random_model.jl")
include("../../src/models/downvote_model.jl")
include("../../src/evaluation.jl")
include("../../src/data_collection.jl")
include("../../src/scoring.jl")
include("../../src/rating.jl")
include("../../src/export_r.jl")
include("../../src/default.jl")

model_init_params = [
    (
        standard_model,
        Dict(
            :scoring_function => [scoring_activation],
            :init_score => [0, 10],
        ),
    ),
    (
        downvote_model,
        Dict(
            :scoring_function => [scoring_reddit_best, scoring_reddit_hot],
        ),
    ),
    #(:all_models, Dict(:steps => [5, 10, 30, 50, 100, 300, 500])),
]


@time begin
    model_dfs, df = collect_model_data(
        model_init_params,
        default_model_properties,
        default_evaluation_functions,
        2,
    )
end

export_rds(df, model_dfs, "steps")
