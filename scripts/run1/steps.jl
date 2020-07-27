using Distributed
#@time using VotingProtocols
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [
    default_models...,
    (:all_models, Dict(:steps => [100, 300, 500, 1000, 3000])),
]

export_data(model_init_params,"steps")
