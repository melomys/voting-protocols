using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :start_users => [50,100, 300],
            :start_posts => [50,100, 300],
            :new_posts_per_step => [1,5,10,20,30],


        ),
    ),
]


export_data(model_init_params,"start_user_posts")
