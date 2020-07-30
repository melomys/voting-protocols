

default_model_properties = [
    dcg,
    ndcg,
    gini,
    @top_k_gini(10),
    @top_k_gini(50),
    @top_k_gini(100),
    @model_property_function(:model_id),
    @model_property_function(:gravity),
    @model_property_function(:seed),
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
    @get_post_data(:quality, identity),
    @get_post_data(:downvotes, identity)
]


default_evaluation_functions = [
    @area_under(:ndcg),
    @area_under(:gini),
    @area_under(:gini_top_10),
    @area_under(:gini_top_50),
    @area_under(:gini_top_100),
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
    @model_property_function(:scoring_function),
    @model_property_function(:seed),
    @model_property_function(:sorted),
    @model_property_function(:start_posts),
    @model_property_function(:start_users),
    @model_property_function(:steps),
    @model_property_function(:gravity),
    @model_property_function(:relevance_gravity),
    @model_property_function(:user),
    @model_property_function(:user_rating_function),
    @model_property_function(:voting_probability_distribution),
    @model_property_function(:deviation_function),
    @model_property_function(:vote_evaluation),
    @rating_correlation(quality, end_position),
    @rating_correlation(timestamp_func, score_func),
    @model_df_column(:gini),
    @model_df_column(:dcg),
    @model_df_column(:ndcg),
]

sort!(default_evaluation_functions, by = x -> string(x))

"""
default_models = [
(
    downvote_model,
    Dict(
        :scoring_function => scoring_reddit_hot),
),
(
    standard_model,
    Dict(
        :scoring_function => [scoring_activation,scoring_hacker_news, scoring_view],
        :init_score => 20,
    )
),
( :all_models,
    Dict(
        :user_rating_function => [user_rating_exp2, user_rating_dist2],
        :relevance_gravity => [0,1.8],
        :deviation_function => [no_deviation, mean_deviation]
))]
"""
default_models = [
(
    downvote_model,
    Dict(
        :scoring_function => scoring_hacker_news,
        :init_score => 50,
        :vote_evaluation => vote_difference,
        :deviation_function => no_deviation,
        :gravity => 0,
        :relevance_gravity => 0,
        :user_rating_function => user_rating_exp2,
    ),
    ),(downvote_model,
    Dict(
        :scoring_function => scoring_hacker_news,
        :init_score => 50,
        :vote_evaluation => vote_difference,
        :deviation_function => mean_deviation,
        :gravity => 2,
        :relevance_gravity => 2,
        :user_rating_function => user_rating_exp2,
    )),(downvote_model,
    Dict(
        :scoring_function => scoring_hacker_news,
        :init_score => 50,
        :vote_evaluation => vote_difference,
        :deviation_function => mean_deviation,
        :gravity => 2,
        :relevance_gravity => 0,
        :user_rating_function => user_rating_dist2,
    )),(downvote_model,
    Dict(
        :scoring_function => scoring_hacker_news,
        :init_score => 50,
        :vote_evaluation => vote_difference,
        :deviation_function => mean_deviation,
        :gravity => 2,
        :relevance_gravity => 2,
        :user_rating_function => user_rating_dist2,
    )),
    (
        downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 20,
            :vote_evaluation => vote_difference,
            :deviation_function => mean_deviation,
            :gravity => 0,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_exp2,
        ),
        ),(downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => mean_deviation,
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_exp2,
        )),(downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => mean_deviation,
            :gravity => 2,
            :relevance_gravity => 0,
            :user_rating_function => user_rating_dist2,
        )),(downvote_model,
        Dict(
            :scoring_function => scoring_view,
            :init_score => 30,
            :vote_evaluation => wilson_score,
            :deviation_function => mean_deviation,
            :gravity => 2,
            :relevance_gravity => 2,
            :user_rating_function => user_rating_dist2,
        )),
        (
            downvote_model,
            Dict(
                :scoring_function => scoring_activation,
                :init_score => 10,
                :vote_evaluation => vote_difference,
                :deviation_function => no_deviation,
                :gravity => 2,
                :relevance_gravity => 0,
                :user_rating_function => user_rating_exp2,
            ),
            ),(downvote_model,
            Dict(
                :scoring_function => scoring_activation,
                :init_score => 30,
                :vote_evaluation => vote_difference,
                :deviation_function => mean_deviation,
                :gravity => 2,
                :relevance_gravity => 2,
                :user_rating_function => user_rating_exp2,
            )),(downvote_model,
            Dict(
                :scoring_function => scoring_activation,
                :init_score => 30,
                :vote_evaluation => vote_difference,
                :deviation_function => mean_deviation,
                :gravity => 2,
                :relevance_gravity => 0,
                :user_rating_function => user_rating_dist2,
            )),(downvote_model,
            Dict(
                :scoring_function => scoring_activation,
                :init_score => 30,
                :vote_evaluation => vote_difference,
                :deviation_function => mean_deviation,
                :gravity => 2,
                :relevance_gravity => 2,
                :user_rating_function => user_rating_dist2,
            )),
            (
                downvote_model,
                Dict(
                    :scoring_function => scoring_reddit_hot,
                    :init_score => 30000,
                    :vote_evaluation => vote_difference,
                    :deviation_function => no_deviation,
                    :relevance_gravity => 0,
                    :user_rating_function => user_rating_exp2,
                ),
                ),(downvote_model,
                Dict(
                    :scoring_function => scoring_reddit_hot,
                    :init_score => 30000,
                    :vote_evaluation => vote_difference,
                    :deviation_function => mean_deviation,
                    :relevance_gravity => 2,
                    :user_rating_function => user_rating_exp2,
                )),(downvote_model,
                Dict(
                    :scoring_function => scoring_reddit_hot,
                    :init_score => 30000,
                    :vote_evaluation => vote_difference,
                    :deviation_function => mean_deviation,
                    :relevance_gravity => 0,
                    :user_rating_function => user_rating_dist2,
                )),(downvote_model,
                Dict(
                    :scoring_function => scoring_reddit_hot,
                    :init_score => 30000,
                    :vote_evaluation => vote_difference,
                    :deviation_function => mean_deviation,
                    :relevance_gravity => 2,
                    :user_rating_function => user_rating_dist2,
                )),

)
]
