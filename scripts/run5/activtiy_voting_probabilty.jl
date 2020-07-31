using Distributed
println(nprocs())
@time @everywhere using VotingProtocols
using Distributions


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
        :activity_distribution => [Beta(2.5,5), Beta(1,5), Beta(1, 10), Beta(2.5,10)],
        :voting_probability_distribution => [Beta(2.5,5), Beta(1,5), Beta(1, 10), Beta(2.5,10)]
        ),
    ),
]

export_data(model_init_params,"activity_voting_probability")
