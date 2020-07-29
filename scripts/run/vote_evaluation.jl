using Distributed
println(nprocs())
@time @everywhere using VotingProtocols



#Default models sind die aus init_score_gravity ergebenen
model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :vote_evaluation => [vote_difference, vote_partition, wilson_score],
        ),
    ),
]

export_data(model_init_params,"vote_evaluation")
