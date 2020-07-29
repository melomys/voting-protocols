using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [(
        standard_model,
        Dict(
            :scoring_function => [scoring_view, scoring_hacker_news],
            :gravity => [0,1,2],
            :init_score => [0:10:70...],
            :user_rating_function => [user_rating_exp2],
            :deviation_function => [no_deviation, mean_deviation],
            #:vote_evaluation => [vote_difference, vote_partition, wilson_score],
            :relevance_gravity[0,1,2]
        ),
    ),
]

export_data(model_init_params,"init_score_gravity")
