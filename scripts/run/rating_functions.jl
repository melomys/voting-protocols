using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :user_opinion_function => [
                consensus,
                dissent
            ],
        ),
    ),
]
export_data(model_init_params,"rating_functions")
