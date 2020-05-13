using Plots
using Agents
using DataFrames

include("../src/plot_helper.jl")
include("../src/model.jl")
include("../src/model_factory.jl")
include("../src/activation_model.jl")
include("../src/view_model.jl")

start_posts = 10
start_users = 100

function ranking_rating(model)
    rating = 0
    for i = 1:model.n
        rating +=
            1 / i * user_rating(
                model.posts[model.ranking[i]].quality,
                ones(quality_dimensions),
            )
    end
    return rating
end

seed = abs.(rand(Int, 1))

models2 = grid_params(
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
)

models3 = grid_params((
    model_initiation,
    Dict(
        :scoring_function =>
            [scoring_view],
        :agent_step! => view_agent_step!,
        :PostType => ViewPost,
        :UserType => ViewUser,
        :seed => seed,
        :rating_factor => [0.5,1,2]
    ),
))

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
        plot!(
            scores[!, i],
            linewidth = user_rating(
                model.posts[i].quality,
                ones(quality_dimensions),
            ),
        )
    end
    plot!(
        rp,
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
plot(plots..., rp, layout = (length(plots) + 1, 1), legend = false)
#plot(rp, legend = false)
