using Distributed
println(nprocs())
@time @everywhere using VotingProtocols


model_init_params = [
    (
        [standard_model],
        Dict(
            :scoring_function => [scoring_hacker_news,scoring_activation],
            :init_score => [-10, 0, 10, 20, 30],
            :steps => [5, 10, 30, 50, 100, 300, 500],
            :start_users => [50,100, 300],
            :start_posts => [50,100, 300],
            :new_posts_per_step => [1,5,10,20,30],
            :deviation_function => [no_deviation, mean_deviation]
        ),
    ),
]

export_data(model_init_params,"hacker_news")
