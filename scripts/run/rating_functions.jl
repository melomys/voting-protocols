using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :user_rating_function => [
                user_rating_exp,
                user_rating,
                user_rating_exp2,
                user_rating_dist1,
                user_rating_dist2
            ],
        ),
    ),
]
export_data(model_init_params,"rating_functions")
