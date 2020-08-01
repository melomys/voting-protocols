using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :start_users => [50,100, 300, 500],
        ),
    ),
]



export_data(model_init_params,"start_users")
