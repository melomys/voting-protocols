using Plots
using Agents
using DataFrames
using Logging

LogLevel(-1000)

include("../src/models/model.jl")
include("../src/model_factory.jl")
include("../src/models/downvote_model.jl")
include("../src/models/view_model.jl")
include("../src/models/random_model.jl")
include("../src/evaluation.jl")
include("../src/data_collection.jl")
include("../src/rating.jl")
include("../src/scoring.jl")

start_posts = 100
start_users = 100
iterations = 100

seeed = abs(rand(Int))

model_dfs = []

model_params = [
    (
        view_model,
        Dict(
            :scoring_function => [scoring_reddit],
            :start_posts => start_posts,
            :start_users => start_users,
            :init_score => 0,
            :new_posts_per_step => [3,5],
            :user_rating_function => [user_rating_exp],
            :UserType => ViewUser,
            :sorted => 0,
            :equal_posts => false,
            :activity_voting_probability_distribution => MvNormal([-4, 0], [1.0 0.8; 0.8 1.0]) #kleiner erwartungswert für activity, so sind nicht alle user auf einmal aktiv
        ),
    ),
]

models = create_models(model_params; seed = seeed)

model_properties = [
    ranking_rating,
    ranking_rating_relative,
    @model_property_function(:model_id),
    @model_property_function(:scoring_function),
    @model_property_function(:seed),
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity),

]
agent_properties = [:vote_probability]


function name_plot_function(model_params)
    custom_parameters = Set()
    for pair in model_params
        if !isempty(keys(pair[2]))
            push!(custom_parameters, keys(pair[2])...)
        end
    end
    function plot_name(model)
        string(reduce(
            (x, y) -> x * "/" * y,
            map(
                x -> "$(string(x)):$(string(get(model.properties,x,"-")))",
                collect(custom_parameters),
            ),
        ))
    end
end


colors = Dict(
    "scoring_activation_agent_step!" => "blue",
    "scoring_agent_step!" => "orange",
    "scoring_best_agent_step!" => "green",
    "scoring_view_view_agent_step!" => "violet",
    "scoring_view_agent_step!" => "cyan",
    "scoring_view_no_time_view_agent_step!" => "red",
    "scoring_best_view_agent_step!" => "magenta",
    "scoring_worst_view_agent_step!" => "black",
)

data = []
plots = []
rp = Plots.plot()
rpr = Plots.plot()

plotname = name_plot_function(model_params)


for model in models
    ab_model = model
    global ab_model
    global model_df
    agent_df, model_df = run!(
        model,
        model.agent_step!,
        model.model_step!,
        iterations;
        agent_properties = agent_properties,
        model_properties = model_properties,
    )

    push!(model_dfs, model_df)

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
            title = plotname(model),
        )
    end

    vp = Plots.plot()
    votes_relative = relative_post_data(model_df[!, :votes])
    for i = 1:ncol(votes_relative)
        plot!(
            model_df[!, :step],
            votes_relative[!, i],
            color = cgrad(:inferno)[model.posts[i].timestamp/model.posts[end].timestamp*1.5],
            linewidth = user_rating(
                model.posts[i].quality,
                ones(model.quality_dimensions),
            ),
            title = plotname(model),
        )
    end

    plot!(
        rp,
        model_df[!, :step],
        model_df[!, :ranking_rating],
        label = string(model.scoring_function) *
                "_" *
                string(model.agent_step!),
    )

    plot!(
        rpr,
        model_df[!, :step],
        model_df[!, :ranking_rating_relative],
        label = string(model),
    )

    push!(data, (agent_df, model_df))
    push!(plots, p)
    push!(plots, vp)
    #push!(plots, corr_p)
end
#default(legend=false)
#plot(rp, legend = false)






#plot(plots... ,layout = (length(plots), 1), legend = false)
Plots.plot(plots...,rpr, legend = false)
#Plots.plot(rpr,legend = :outertopright)
