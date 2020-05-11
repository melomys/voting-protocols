using Plots
using Agents
using DataFrames

include("../src/plot_helper.jl")
include("../src/model.jl")
include("../src/model_factory.jl")

start_posts = 10
start_users = 8000

function ranking_rating(model)
    rating = 0
    for i in 1:model.n
        rating += 1/i * user_rating(model.posts[model.ranking[i]].quality,ones(quality_dimensions))
    end
    return rating
end


models = grid_params(Dict(model_initiation => Dict(:scoring_function => [scoring, scoring_hacker_news, scoring_best, scoring_random])))

model_properties = [:ranking,ranking_rating,@get_post_data(:score, identity),@get_post_data(:votes,identity),@get_post_data(:quality,identity)]
agent_properties = [:vote_probability]

data = []
plots = []
rp = plot()
for model in models
    agent_df, model_df = run!(model,model.agent_step!, model.model_step!,30;agent_properties= agent_properties,model_properties=model_properties)

    p = plot()
    scores = unpack_data(model_df[!,:identity_score])
    for i in 1:ncol(scores)
        plot!(scores[!,i], linewidth = user_rating(model.posts[i].quality,ones(quality_dimensions)))
    end
    plot!(rp,model_df[!,:ranking_rating],label=string(model.scoring_function))

    push!(data,(agent_df, model_df))
    push!(plots,p)
end

#plot(plots...,rp,layout = (length(plots)+1,1))
default(legend=true)
plot(rp)
