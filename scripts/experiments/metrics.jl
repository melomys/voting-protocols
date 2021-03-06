using Plots

using Agents
using DataFrames
using LinearAlgebra
using Logging


include("../../src/user_creation.jl")

include("../../src/models/model.jl")
include("../../src/models/downvote_model.jl")
include("../../src/models/random_model.jl")
include("../../src/models/view_model.jl")


include("../../src/model_factory.jl")
include("../../src/rating.jl")
include("../../src/scoring.jl")
include("../../src/evaluation.jl")
include("../../src/data_collection.jl")

include("../../src/default.jl")

include("../../src/export_r.jl")

#sigmoid(x) = 1/(1+ℯ^((0.5)*(-x)))

model_init_params = [
    (:all_models, Dict(
    :steps => 100,
    :relevance_gravity => [0],
        :gravity => 1.8,
    #:user => [[(0.9, user()),(0.1, extreme_user(1))], [(0.9,user()),(0.1, extreme_user(-1))]]
    #:quality_distribution => MvNormal(zeros(3), I(3)*10.0)
    )),
    (
        [up_and_downvote_system],
        Dict(:rating_metric => [metric_activation, metric_hacker_news, metric_view],
        :init_score => 30,
        :deviation_function => [no_deviation],
    )),
    #(upvote_system, Dict(
#    :rating_metric => metric_activation,
#    :user_opinion_function => [consensus],
#    :init_score => [30]
#    ))
    ]

seed_ = abs(rand(Int))

seed_ = 3

models = create_models(model_init_params;seed = seed_)
"""
model_dfs, corr_df = collect_model_data(
model_init_params,
default_model_properties,
default_evaluation_functions,
1)

export_rds(corr_df, model_dfs, "metrics")
"""
data = []
plots = []
rp = Plots.plot()
rpr = Plots.plot()




for model in models
    agent_df, model_df = run!(
        model,
        model.agent_step!,
        model.model_step!,
        model.steps;
        agent_properties = [],
        model_properties = default_model_properties
        )

        ab_model = model
        global ab_model
        global model_df

        p = Plots.plot()
        scores = post_data(model_df[!, :score])

        for i = 1:ncol(scores)
            plot!(
                model_df[!, :step],
                scores[!, i],
                linewidth = user_rating(
                    model.posts[i].quality,
                    ones(model.quality_dimensions),
                ),
                color = cgrad(:inferno)[sigmoid(user_rating(
                    model.posts[i].quality,
                    ones(model.quality_dimensions),
                ))],
            )
        end

        vp = Plots.plot()
        votes_relative = relative_post_data(model_df[!, :votes]) .- relative_post_data(model_df[!, :downvotes])
        for i = 1:ncol(votes_relative)
            plot!(
                model_df[!, :step],
                votes_relative[!, i],
                color = cgrad(:inferno)[model.posts[i].timestamp/model.posts[end].timestamp*1.5],
                linewidth = user_rating(
                    model.posts[i].quality,
                    ones(model.quality_dimensions),
                ),
            )
        end

        plot!(
            rp,
            model_df[!, :step],
            model_df[!, :ndcg],
            label = string(model.rating_metric) *
                    "_" *
                    string(model.agent_step!),
        )

        plot!(
            rpr,
            model_df[!, :step],
            model_df[!, :gini],
            label = string(model),
        )

        push!(data, (agent_df, model_df))
        push!(plots,p)
        #push!(plots, vp)
end

plot(plots...,layout = (length(plots), 1), legend = false)
