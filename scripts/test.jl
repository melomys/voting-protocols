using Plots
using Agents
using DataFrames

include("../src/plot_helper.jl")
include("../src/model.jl")

model = model_initiation()

model_properties = [@get_post_data(:votes, maximum),@get_post_data(:score, identity),@get_post_data(:votes,identity)]
agent_properties = [:vote_probability]

default(legend = false)

agent_df, model_df = run!(
    model,
    agent_step!,
    model_step!,
    30;
    agent_properties = agent_properties,
    model_properties = model_properties,
)
p = plot()
scores = create_plot_data_score(model_df)
for i in 1:ncol(scores)
    p = plot!(scores[!,i], linewidth = user_rating(model.posts[i].quality,ones(quality_dimensions))*5)
end

display(p)
