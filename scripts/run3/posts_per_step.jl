using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [default_models...,
    (
        :all_models,
        Dict(
            :new_posts_per_step => [0,5,10,50,100],
        ),
    ),
]


export_data(model_init_params,"posts_per_step")
