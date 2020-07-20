using Distributed
#@time using VotingProtocols
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [
    default_models...,
    (:all_models, Dict(
        :sorted => [-1,0,1]
    )),
]

export_data(model_init_params,"pre_sort")
