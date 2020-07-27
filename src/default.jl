

default_model_properties = [
    ranking_rating,
    ranking_rating_relative,
    dcg,
    ndcg,
    gini,
    @top_k_gini(10),
    @top_k_gini(50),
    @top_k_gini(100),
    spearman,
    @model_property_function(:model_id),
    @model_property_function(:gravity),
    @model_property_function(:seed),
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity),
    @get_post_data(:downvotes, identity)
]


default_evaluation_functions = [
    area_under_curve,
    area_under_gini,
    @area_under_gini_top_k(10),
    @area_under_gini_top_k(50),
    @area_under_gini_top_k(100),
    area_under_spearman,
    vote_count,
    quality_sum,
    gain,
    sum_gradient,
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
    @model_property_function(:scoring_function),
    @model_property_function(:seed),
    @model_property_function(:sorted),
    @model_property_function(:start_posts),
    @model_property_function(:start_users),
    @model_property_function(:steps),
    @model_property_function(:gravity),
    @model_property_function(:user),
    @model_property_function(:user_rating_function),
    @model_property_function(:voting_probability_distribution),
    @model_property_function(:deviation_function),
    @rating_correlation(quality, end_position),
    @rating_correlation(timestamp_func, score_func),
    @model_df_column(:gini),
    @model_df_column(:ranking_rating_relative),
    @model_df_column(:dcg),
    @model_df_column(:ndcg),
]

sort!(default_evaluation_functions, by = x -> string(x))


# vielleicht noch ein rating_dist mit reinhauen um das anzuschauen??
default_models = [(
    standard_model,
    Dict(
        :deviation_function => [no_deviation, mean_deviation],
        :scoring_function => [scoring_hacker_news, scoring_view],
    ),
),
(
    downvote_model,
    Dict(:scoring_function => [scoring_reddit_hot],
    :model_step! => [model_step!, random_model_step!]),
),
(
    [standard_model],
    Dict(
        :deviation_function => [no_deviation, mean_deviation],
        :scoring_function => [scoring_activation],
        :init_score => 30
    )
),
( :all_models, Dict(
    :user_rating_function => [user_rating_exp2, user_rating_dist2]
))]
