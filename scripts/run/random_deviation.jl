using Distributed
println(nprocs())
@time @everywhere using VotingProtocols



#Default models sind die aus init_score_gravity ergebenen
model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :deviation_function => [no_deviation, mean_deviation, std_deviation],
        ),
    ),
]

export_data(model_init_params,"random_deviation")
