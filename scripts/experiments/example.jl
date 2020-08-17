model_configs = [
    (
        up_and_downvote_system,
        &Dict&(
            &:rating_metric& => metric_reddit_hot,
            &:deviation_function& => [
                no_deviation,
                std_deviation],
        ),
    ),
    (
        [upvote_system, up_and_downvote_system],
        &Dict&(
            &:rating_metric& => [
                metric_activation,
                metric_hacker_news],
            &:gravity& => [$0.5$, $1.0$, $1.5$, $2.0$],
        ),
    ),
    (
        &:all_models&,
        &Dict&(
            &:user_opinion_function& => consensus
        ),
    ),
]
