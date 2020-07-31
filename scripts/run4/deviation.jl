using VotingProtocols
using Distributed

model_init_params = [default_models...,
    (:all_models,
    Dict(
        :deviation_function => [no_deviation, mean_deviation, std_deviation]
    ))

]





export_data(model_init_params,"deviation")
