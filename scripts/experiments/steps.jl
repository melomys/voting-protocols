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
    (:all_models, Dict(:steps => [5, 10, 30, 50, 100, 300, 500])),
]


model_properties = [
    ranking_rating,
    ranking_rating_relative,
    @model_property_function(:model_id),
    @model_property_function(:votes_exp),
    @model_property_function(:time_exp),
    @model_property_function(:seed),
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity),
]

@time begin
    model_dfs, df = collect_model_data(
        model_init_params,
        model_properties,
        default_evaluation_functions,
        20,
    )
end

export_rds(df, model_dfs, "steps")
