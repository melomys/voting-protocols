using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [defaul_models...,
    (
        :all_models,
        Dict(
            :concentration_distribution => [Poisson(3), Poisson(10), Poisson(50), Poisson(100)],
        ),
    ),
]

export_data(model_init_params,"concentration")
