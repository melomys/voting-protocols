using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :user => [user(),[(0.05, extreme_user(1)),(0.95, user())],[(0.1, extreme_user(1)),(0.9, user())],[(0.2, extreme_user(1)),(0.8, user())],[(0.1, extreme_user(1)),(0.8, user()),(0.1, extreme_user(-1))]]
        ),
    ),
]

export_data(model_init_params,"extreme_users")
