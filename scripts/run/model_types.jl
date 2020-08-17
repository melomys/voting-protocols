using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [(
        [upvote_system, up_and_downvote_system
        Dict(
            :rating_metric => [metric_view, metric_hacker_news, scoring_reddit]
# muss noch richtig gesetzt werden            :init_score => [0:10:70],
# und gravität auch
            :user_opinion_function => consensus,
        ),
    ),
]

export_data(model_init_params,"model_types")
