using Plots
using Agents
using DataFrames
using Logging

LogLevel(-1000)

include("../src/models/model.jl")
include("../src/model_factory.jl")
include("../src/models/downvote_model.jl")
include("../src/models/activation_model.jl")
include("../src/models/view_model.jl")
include("../src/evaluation.jl")
include("../src/data_collection.jl")
include("../src/rating.jl")
include("../src/scoring.jl")

start_posts = 100
start_users = 100
iterations = 100

seed = abs(rand(Int))


model_params3 = [
    (
        model_initiation,
        Dict(
            :scoring_function => scoring_acitvation,
            :rating_factor => 0,
            :start_posts => start_posts,
            :start_users => start_users,
            :user_rating_function => [user_rating_exp],
            :init_score => 0,
        ),
    ),
    (
        downvote_model,
        Dict(:user_rating_function => user_rating_exp, :init_score => [20, 30]),
    ),
]

models3 = create_models(model_params3; seed = seed)

model_properties = [
    ranking_rating,
    ranking_rating_relative,
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity)
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

plotname = name_plot_function(model_params3)


for model in models3
    global model_df
    agent_df, model_df = run!(
        model,
        model.agent_step!,
        model.model_step!,
        iterations;
        agent_properties = agent_properties,
        model_properties = model_properties,
    )

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

    #corr_p = Plots.plot()
    #for i = 1:ncol(votes_relative)
    #    max_index = index_maximum_reached(votes_relative[!, i])
    #    scatter!(corr_p,
    #        [model.posts[i].timestamp],
    #        [votes_relative[max_index,i]/max_index],
    #        color = cgrad(:inferno)[sigmoid(user_rating(
    #            model.posts[i].quality,
    #            ones(quality_dimensions),
    #        ))],
    #    )
    #end


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


rat_fac = 2

model_init_params = [
    (
        model_initiation,
        Dict(
            :scoring_function => [scoring],
            :agent_step! => view_agent_step!,
            :PostType => ViewPost,
            :UserType => ViewUser,
            :rating_factor => rat_fac,
        ),
    ),
    (
        model_initiation,
        Dict(
            :scoring_function => [scoring_best, scoring_worst],
            :rating_factor => rat_fac,
        ),
    ),
]

evaluation_functions = [
    area_under_curve,
    model_df ->
        sign(model_df[2, :ranking_rating] - model_df[1, :ranking_rating]) *
        sign(model_df[end, :ranking_rating] - model_df[2, :ranking_rating]),
]

to_evaluate = map(
    x -> (init_result_dataframe(model_init_params), x),
    evaluation_functions,
)

results = init_result_dataframe(model_init_params)
first_full_corr = init_result_dataframe(model_init_params)

iterations = 0
models_arr = []
for i = 1:iterations
    seed = abs(rand(Int))
    models = create_models(model_init_params; seed = seed)

    push!(models_arr, models)

    result = []
    first_full_c = []

    evaluations = map(x -> [], to_evaluate)

    for j = 1:length(models)
        model = models[j]


        agent_df, model_df = run!(
            model,
            model.agent_step!,
            model.model_step!,
            30;
            agent_properties = agent_properties,
            model_properties = model_properties,
        )

        push!(result, trapezoidial_rule(model_df[!, :ranking_rating]))
        push!(
            first_full_c,
            sign(model_df[2, :ranking_rating] - model_df[1, :ranking_rating]) *
            sign(model_df[end, :ranking_rating] - model_df[2, :ranking_rating]),
        )
        for i = 1:length(to_evaluate)
            push!(evaluations[i], to_evaluate[i][2](model_df))
        end

    end

    for i = 1:length(evaluations)
        push!(to_evaluate[i][1], evaluations[i])
    end
    push!(results, result)
    push!(first_full_corr, first_full_c)

end


#for key in sort(collect(keys(results)))
#    println("$(key): $(mean(results[key]))")
#end


#plot(plots... ,layout = (length(plots), 1), legend = false)
Plots.plot(plots..., rpr, legend = false)
#Plots.plot(rpr,legend = :outertopright)
