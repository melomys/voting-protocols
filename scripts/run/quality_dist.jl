using Distributed
using Distributions
using LinearAlgebra
println(nprocs())
@time @everywhere using VotingProtocols


d1 = MvNormal(ones(3), I(3))
d2 = MvNormal([-4,0,5],[1 0.5 0.9; 0.5 1 0.1;0.9 0.1 1])
d3 = MvNormal([-4,0,5],[1 0.1 0; 0.1 1 0; 0 0 1])
d4 = MvNormal([0,0,0],[1 0.5 0.9; 0.5 1 0.1;0.9 0.1 1])

model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :quality_distribution => [d1,d2,d3,d4],
        ),
    ),
]


export_data(model_init_params,"quality_dists")
