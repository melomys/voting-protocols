include("data_collection.jl")
include("evaluation.jl")


default_model_properties = [
    ranking_rating,
    ranking_rating_relative,
    dcg,
    ndcg,
    gini,
    @model_property_function(:model_id),
    @model_property_function(:votes_exp),
    @model_property_function(:time_exp),
    @model_property_function(:seed),
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity),
    @get_post_data(:downvotes, identity)
]


default_evaluation_functions = [
    area_under_curve,
    area_under_gini,
    vote_count,
    quality_sum,
    gain,
    sum_gradient,
    post_views,
    mean_user_view,
    mean_user_vote,
    @model_property_function(:activity_voting_probability_distribution),
    @model_property_function(:concentration_scale),
    @model_property_function(:init_score),
    @model_property_function(:new_posts_per_step),
    @model_property_function(:model_id),
    @model_property_function(:model_type),
    @model_property_function(:quality_dimensions),
    @model_property_function(:scoring_function),
    @model_property_function(:seed),
    @model_property_function(:start_posts),
    @model_property_function(:start_users),
    @model_property_function(:steps),
    @model_property_function(:time_exp),
    @model_property_function(:user_rating_function),
    @model_property_function(:votes_exp),
    @rating_correlation(quality, end_position),
    @rating_correlation(timestamp_func, score_func),
    @model_df_column(:gini),
    @model_df_column(:ranking_rating_relative),
    @model_df_column(:dcg),
    @model_df_column(:ndcg),
]

sort!(default_evaluation_functions, by = x -> string(x))
