using Plots

using VotingProtocols
using Agents
using DataFrames
using LinearAlgebra

model_init_params = [
    (:all_models, Dict(
    :steps => 100,
    )),
    (
        [downvote_model],
        Dict(:scoring_function => [scoring_reddit_hot],

        :user_rating_function => [user_rating_exp],
    )),
    (standard_model, Dict(
    :scoring_function => scoring_activation,
    :user_rating_function => [user_rating_exp],
    :init_score => [30]
    ))
    ]


seed_ = abs(rand(Int))


models = create_models(model_init_params)

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
            label = string(model.scoring_function) *
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
        push!(plots, p)
        push!(plots, vp)
end

plot(plots...,rpr,rp ,layout = (length(plots) + 2, 1), legend = false)
