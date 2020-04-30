using Plots
using Agents
using DataFrames

include("../src/plot_helper.jl")
include("../src/model.jl")

model = model_initiation(start_posts=10)


function ranking_rating(model)
    rating = 0
    for i in 1:model.n
        rating += 1/i * user_rating(model.posts[model.ranking[i]].quality,ones(quality_dimensions))
    end
    return rating
end

model_properties = [:ranking,ranking_rating,@get_post_data(:score, identity),@get_post_data(:votes,identity)]
agent_properties = [:vote_probability]

agent_df, model_df = run!(
    model,
    agent_step!,
    model_step!,
    30;
    agent_properties = agent_properties,
    model_properties = model_properties,
)
p1 = plot()
scores = unpack_data(model_df[!,:identity_score])
for i in 1:ncol(scores)
    plot!(scores[!,i], linewidth = user_rating(model.posts[i].quality,ones(quality_dimensions))*5)
end

p2 = plot()
ranking = unpack_data(model_df[!,:ranking])
for i in 1:ncol(ranking)
    plot!(ranking[!,i], linewidth = user_rating(model.posts[i].quality, ones(quality_dimensions))*2)
end


model2 = model_initiation(start_posts=10,scoring_function=scoring_brrt)


agent_df, model2_df = run!(
    model2,
    agent_step!,
    model_step!,
    30;
    agent_properties = agent_properties,
    model_properties = model_properties,
)

p3 = plot()
scores = unpack_data(model2_df[!,:identity_score])
for i in 1:ncol(scores)
    plot!(scores[!,i], linewidth = user_rating(model2.posts[i].quality,ones(quality_dimensions))*5)
end

p4 = plot()
plot!(model_df[:ranking_rating])
plot!(model2_df[:ranking_rating])

default(legend = false)
l = @layout [a;b;c]

plot(p1,p3,p4; layout=l)
