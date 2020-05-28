
using Agents
using DataFrames
using StatsPlots
using PyPlot
using Statistics

include("../../src/models/model.jl")
include("../../src/model_factory.jl")
include("../../src/activation_model.jl")
include("../../src/models/view_model.jl")
include("../../src/evaluation.jl")
include("../../src/data_collection.jl")
include("../../src/scoring.jl")
include("../../src/rating.jl")


rat_fac = 2
steps = 30


function quality(post,model,model_df)
    model.user_rating_function(post.quality, ones(model.quality_dimensions))
end

function end_position(post, model, model_df)
    index = findfirst(isequal(post), model.posts)
    findfirst(isequal(index), model.ranking)
end




evaluation_functions = [
    @post_property_function(:timestamp),
    @post_property_function(:score),
    @post_property_function(:votes),
    quality,
    end_position
]

sort!(evaluation_functions, by = x -> string(x))

model_init_params = [(
    view_model,
    Dict(
        :scoring_function => [scoring],
        :agent_step! => view_agent_step!,
        :user_rating_function => user_rating,
        :rating_factor => [0],
        :init_score => [10]
    ),
)]


corr_df = init_correlation_dataframe(evaluation_functions)

iterations = 20
for i = 1:iterations
    seed = abs(rand(Int))
    models = create_models(model_init_params; seed = seed)

    for j = 1:length(models)
        model = models[j]

        agent_df, model_df = run!(
            model,
            model.agent_step!,
            model.model_step!,
            steps;
            agent_properties = [],
            model_properties = default_view_model_properties,
        )

        global model
        global model_df
        for post in model.posts
            push!(corr_df, map(x -> x(post, model, model_df), evaluation_functions))
        end
    end
end

plotly()
corrplot(
    Array{Float64}(corr_df),
    bins = 10,
    label = map(string, names(corr_df)),
    markercolor = cgrad(:inferno),
)
