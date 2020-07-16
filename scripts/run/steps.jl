using Distributed
#@time using VotingProtocols
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [
    default_models...,
    (:all_models, Dict(:steps => [5, 10, 30, 50, 100, 300, 500])),
]

export_data(model_init_params,"steps")
