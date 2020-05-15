using Plots
using Agents
using DataFrames

include("../src/plot_helper.jl")
include("../src/model.jl")
include("../src/model_factory.jl")
include("../src/activation_model.jl")
include("../src/view_model.jl")
include("../src/evaluation.jl")

start_posts = 10
start_users = 100

seed = abs.(rand(Int,1))

models2 = grid_params([
    (
        model_initiation,
        Dict(
            :scoring_function => [scoring],
            :model_step! => activation_model_step!,
            :agent_step! => activation_agent_step!,
            :seed => seed,
        ),
    ),
    (
        model_initiation,
        Dict(:scoring_function => [scoring, scoring_best], :seed => seed),
    ),
    (
        model_initiation,
        Dict(
            :scoring_function => [scoring_view],
            :agent_step! => view_agent_step!,
            :PostType => ViewPost,
            :UserType => ViewUser,
            :seed => seed,
        ),
    ),
])


model_params3 = [(
    model_initiation,
    Dict(
        :scoring_function =>
            [scoring_view,scoring],
        :agent_step! => view_agent_step!,
        :PostType => ViewPost,
        :UserType => ViewUser,
        :seed => seed,
        :rating_factor => [0.5]
    ),

),(model_initiation,
Dict(
:scoring_function => [scoring_view, scoring, scoring_best],
:rating_factor => [1:3...]
))]

models3 = grid_params(model_params3)

model_properties = [
    :ranking,
    ranking_rating,
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity)
]
agent_properties = [:vote_probability]



colors = Dict(
    "scoring_activation_agent_step!" => "blue",
    "scoring_agent_step!" => "orange",
    "scoring_best_agent_step!" => "green",
    "scoring_view_view_agent_step!" => "violet",
    "scoring_view_agent_step!" => "cyan",
    "scoring_view_no_time_view_agent_step!" => "red",
    "scoring_best_view_agent_step!" => "magenta"
)

data = []
plots = []
rp = plot()
for model in models3
    agent_df, model_df = run!(
        model,
        model.agent_step!,
        model.model_step!,
        30;
        agent_properties = agent_properties,
        model_properties = model_properties,
    )

    p = plot()
    scores = unpack_data(model_df[!, :identity_score])
    for i = 1:ncol(scores)
        plot!(model_df[!,:step],
            scores[!, i],
            linewidth = user_rating(
                model.posts[i].quality,
                ones(quality_dimensions),
            ),
        )
    end
    plot!(
        rp,
        model_df[!,:step],
        model_df[!, :ranking_rating],
        label = string(model.scoring_function) *
                "_" *
                string(model.agent_step!),
        color = colors[string(model.scoring_function)*"_"*string(model.agent_step!)],
    )

    push!(data, (agent_df, model_df))
    push!(plots, p)
end
#default(legend=false)
#plot(rp, legend = false)

iterations = 1

results = Dict()
for i in 1:iterations
    seed = abs.(rand(Int,1))
    models = grid_params([(
        model_initiation,
        Dict(
            :scoring_function =>
                [scoring_view,scoring_best,scoring, scoring_hacker_news],
            :agent_step! => view_agent_step!,
            :PostType => ViewPost,
            :UserType => ViewUser,
            :seed => seed,
            :rating_factor => [0.5,1,2,5]
        ),
    )])
    for j in 1:length(models)
        model = models[j]
        identifier = string(model.scoring_function) * "_" * string(model.rating_factor)

        if i == 1
            results[identifier] = []
        end


        agent_df, model_df = run!(
            model,
            model.agent_step!,
            model.model_step!,
            30;
            agent_properties = agent_properties,
            model_properties = model_properties,
        )
        push!(results[identifier], trapezoidial_rule(model_df[!,:ranking_rating]))
    end
end


println("")
for key in sort(collect(keys(results)))
    println("$(key): $(mean(results[key]))")
end


plot(plots..., rp, layout = (length(plots) + 1, 1), legend = false)
