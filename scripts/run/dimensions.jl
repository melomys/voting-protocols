using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :quality_dimensions => [1,3,10,50],
        ),
    ),
]

export_data(model_init_params,"dimensions")
