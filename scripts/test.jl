using Plots
using Agents
using DataFrames

include("/home/ludwig/Bachelorarbeit/voting-protocols/src/plot_helper.jl")
include("/home/ludwig/Bachelorarbeit/voting-protocols/src/model.jl")
include("/home/ludwig/Bachelorarbeit/voting-protocols/src/model_factory.jl")
include("/home/ludwig/Bachelorarbeit/voting-protocols/src/activation_model.jl")
include("/home/ludwig/Bachelorarbeit/voting-protocols/src/view_model.jl")
include("/home/ludwig/Bachelorarbeit/voting-protocols/src/evaluation.jl")

start_posts = 10
start_users = 100

seed = abs(rand(Int))

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
        :scoring_function => [scoring_view],
        :agent_step! => view_agent_step!,
        :PostType => ViewPost,
        :UserType => ViewUser,
        :rating_factor => [0.5],
    ),
)]

models3 = create_models(model_params3; seed = seed)

model_properties = [
    ranking_rating,
    ranking_rating_relative,
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
    "scoring_best_view_agent_step!" => "magenta",
    "scoring_worst_view_agent_step!" => "black",
)

data = []
plots = []
rp = plot()
rpr = plot()

mmodel = nothing

for model in models3
    mmodel = model
    global model_df
    agent_df, model_df = run!(
        model,
        model.agent_step!,
        model.model_step!,
        30;
        agent_properties = agent_properties,
        model_properties = model_properties,
    )

    p = plot()
    scores = post_data(model_df[!, :identity_score])
    for i = 1:ncol(scores)
        start_index = findfirst(x -> x != 0, scores[!,i])-1
        plot!(
            model_df[start_index:end, :step],
            scores[start_index:end, i],
            linewidth = user_rating(
                model.posts[i].quality,
                ones(quality_dimensions),
            ),
            color = cgrad(:inferno)[sigmoid(user_rating(
                model.posts[i].quality,
                ones(quality_dimensions),
            ))],
        )
    end

    vp = plot()
    votes_relative = relative_post_data(model_df[!, :identity_votes])
    for i = 1:ncol(votes_relative)
        plot!(
            model_df[!, :step],
            votes_relative[!, i],
            linewidth = model.posts[i].timestamp / 4,
            color = cgrad(:inferno)[sigmoid(user_rating(
                model.posts[i].quality,
                ones(quality_dimensions),
            ))],
        )
    end

    plot!(
        rp,
        model_df[!, :step],
        model_df[!, :ranking_rating],
        label = string(model.scoring_function) *
                "_" *
                string(model.agent_step!),
        color = colors[string(model.scoring_function)*"_"*string(model.agent_step!)],
    )

    plot!(
        rpr,
        model_df[!, :step],
        model_df[!, :ranking_rating_relative],
        label = string(model.scoring_function) *
                "_" *
                string(model.agent_step!),
        color = colors[string(model.scoring_function)*"_"*string(model.agent_step!)],
    )

    push!(data, (agent_df, model_df))
    push!(plots, p)
    push!(plots, vp)
end
#default(legend=false)
#plot(rp, legend = false)

function columnname(model_params)
    string(reduce(
        (x, y) -> x * "_" * y,
        map(x -> string(model_params[x]), collect(keys(model_params))),
    ))
end

function init_result_dataframe(models_params)
    DataFrame(Dict(map(
        x -> (columnname(Dict(x)), []),
        get_params(model_init_params),
    )))
end

rat_fac = 2

model_init_params = [
    (
        model_initiation,
        Dict(
            :scoring_function => [scoring_custom],
            :agent_step! => view_agent_step!,
            :PostType => ViewPost,
            :UserType => ViewUser,
            :votes_exp => [1:10...],
            :time_exp => [0.1:0.1:1...],
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


plot(plots..., layout = (length(plots), 1), legend = false)
