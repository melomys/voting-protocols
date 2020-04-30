using Plots
using Agents
using DataFrames

include("../src/plot_helper.jl")
include("../src/model.jl")

model = model_initiation(start_posts=10)

model_properties = [:ranking,@get_post_data(:score, identity),@get_post_data(:votes,identity)]
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


model = model_initiation(start_posts=10,scoring_function=hacker_news_scoring)


agent_df, model_df = run!(
    model,
    agent_step!,
    model_step!,
    30;
    agent_properties = agent_properties,
    model_properties = model_properties,
)

p3 = plot()
scores = unpack_data(model_df[!,:identity_score])
for i in 1:ncol(scores)
    plot!(scores[!,i], linewidth = user_rating(model.posts[i].quality,ones(quality_dimensions))*5)
end

p4 = plot()
ranking = unpack_data(model_df[!,:ranking])
for i in 1:ncol(ranking)
    plot!(ranking[!,i], linewidth = user_rating(model.posts[i].quality, ones(quality_dimensions))*2)
end


default(legend = false)
l = @layout [a;b;c;d]

plot(p1,p2,p3,p4; layout=l)
