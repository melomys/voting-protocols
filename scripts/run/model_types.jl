using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [(
        [standard_model, downvote_model
        Dict(
            :scoring_function => [scoring_view, scoring_hacker_news, scoring_reddit]
# muss noch richtig gesetzt werden            :init_score => [0:10:70],
# und gravität auch
            :user_rating_function => user_rating_exp2,
        ),
    ),
]

export_data(model_init_params,"model_types")
