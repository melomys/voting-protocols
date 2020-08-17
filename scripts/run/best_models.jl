using Distributed
println(nprocs())
@time @everywhere using VotingProtocols

model_init_params = [(
    [up_and_downvote_system],
    Dict(
        :rating_metric => [metric_hacker_news, metric_view, metric_activation],
        :init_score => [10, 20,30,40],
        :gravity => [0,0.5],
        :deviation_function => [no_deviation, mean_deviation],
        :vote_evaluation => [vote_difference, wilson_score],
        :relevance_gravity => 0,
        :user_opinion_function => consensus,
    )),(
    [up_and_downvote_system],
    Dict(
        :rating_metric => metric_reddit_hot,
        :init_score => 30000,
        :deviation_function => [no_deviation, mean_deviation],
        :vote_evaluation => [vote_difference, wilson_score],
        :relevance_gravity => 0,
        :user_opinion_function => consensus,
    )
    ),(
    [up_and_downvote_system, upvote_system],
    Dict(
        :rating_metric => [metric_hacker_news, metric_view, metric_activation],
        :init_score => [10, 20,30,40],
        :gravity => [2],
        :deviation_function => [no_deviation, mean_deviation],
        :vote_evaluation => [vote_difference, wilson_score],
        :relevance_gravity => 2,
        :user_opinion_function => consensus,
    )),(
    [up_and_downvote_system,upvote_system],
    Dict(
        :rating_metric => metric_reddit_hot,
        :init_score => 30000,
        :deviation_function => [no_deviation, mean_deviation],
        :vote_evaluation => [vote_difference, wilson_score],
        :relevance_gravity => 2,
        :user_opinion_function => consensus,
    )
    ),
]

model_properties = [
    dcg,
    ndcg,
    gini,
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity),
    @get_post_data(:downvotes, identity)
]


evaluation_functions = [
    @area_under(:ndcg),
    @area_under(:gini),
    vote_count,
    quality_sum,
    post_views,
    mean_user_view,
    mean_user_vote,
    posts_with_no_views,
    @model_property_function(:activity_distribution),
    @model_property_function(:concentration_distribution),
    @model_property_function(:init_score),
    @model_property_function(:new_posts_per_step),
    @model_property_function(:model_id),
    @model_property_function(:model_type),
    @model_property_function(:quality_dimensions),
    @model_property_function(:rating_metric),
    @model_property_function(:seed),
    @model_property_function(:sorted),
    @model_property_function(:start_posts),
    @model_property_function(:start_users),
    @model_property_function(:steps),
    @model_property_function(:gravity),
    @model_property_function(:relevance_gravity),
    @model_property_function(:user),
    @model_property_function(:user_opinion_function),
    @model_property_function(:voting_probability_distribution),
    @model_property_function(:deviation_function),
    @model_property_function(:vote_evaluation),
    @rating_correlation(quality, end_position),
    @rating_correlation(timestamp_func, score_func),
    @model_df_column(:gini),
    @model_df_column(:dcg),
    @model_df_column(:ndcg),
]

sort!(evaluation_functions, by = x -> string(x))



export_data(model_init_params,"model_specified";model_properties= model_properties, evaluation_functions= evaluation_functions, pack = 1)
