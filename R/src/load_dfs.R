
df_full_model = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_full_model/data", "full_model")

grouped_full_model = df_full_model %>% 
  mutate(scoring_function = factor(scoring_function)) %>%
  group_by(scoring_function, init_score, deviation_function, vote_evaluation,gravity, relevance_gravity, user_rating_function, model_type) %>% 
  dplyr::summarise(area_under_gini = mean(area_under_gini), area_under_ndcg = mean(area_under_ndcg), posts_with_no_views = mean(posts_with_no_views),rho = mean(rho), n = n()) 


df_specified_model = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_specified_model/data", "model_specified")


df_deviation = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_dev_votes_per_step/","deviation") %>% 
  mutate(quality_dimensions = factor(quality_dimensions)) %>% 
  filter(user_rating_function == "Konsens")


grouped_deviation = df_deviation %>% 
  mutate(scoring_function = factor(scoring_function)) %>%
  #group_by(scoring_function, init_score, deviation_function, vote_evaluation, gravity)
  group_by(scoring_function, init_score, deviation_function, vote_evaluation,gravity, relevance_gravity, user_rating_function, model_type) %>% 
  dplyr::summarise(area_under_gini = mean(area_under_gini), area_under_ndcg = mean(area_under_ndcg), posts_with_no_views = mean(posts_with_no_views),rho = mean(rho), n = n()) 


df_conc = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_conc_per_step/data","concentration") %>% 
  filter(user_rating_function == "Konsens")

df_userprob = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_not_users/","activity_voting") %>% 
  filter(user_rating_function == "Konsens")

df_userprob$voting_probability_distribution = revalue(x = df_userprob$voting_probability_distribution, c("Distributions.Beta{Float64}(α=2.5, β=5.0)" = "Beta(2.5,5)", "Distributions.Beta{Float64}(α=1.0, β=5.0)" = "Beta(1,5)", "Distributions.Beta{Float64}(α=1.0, β=10.0)" = "Beta(1,10)","Distributions.Beta{Float64}(α=2.5, β=10.0)" = "Beta(2.5,10)"))

df_userprob$activity_distribution = revalue(x = df_userprob$activity_distribution,c("Distributions.Beta{Float64}(α=2.5, β=5.0)" = "Beta(2.5,5)", "Distributions.Beta{Float64}(α=1.0, β=5.0)" = "Beta(1,5)", "Distributions.Beta{Float64}(α=1.0, β=10.0)" = "Beta(1,10)","Distributions.Beta{Float64}(α=2.5, β=10.0)" = "Beta(2.5,10)"))

df_start_posts = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_extreme_and_more","start_post")

df_start_users = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_dev_votes_per_step/","start_user") %>% 
  filter(user_rating_function == "Konsens")

df_posts_per_step = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_conc_per_step/data","posts_per_step") %>% 
  filter(user_rating_function == "Konsens")


df_init = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_specified_model/data","specified")

df_gravity = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_gravity/data","model") %>% 
  mutate(quality_dimensions = factor(quality_dimensions)) %>% 
  filter(user_rating_function == "Konsens")

df_steps = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_steps/data","step")


df_dims = combine_dfs("/home/ludwig/Bachelorarbeit/voting-protocols/data_cluster/data_not_users/","dimensions") %>% 
  mutate(quality_dimensions = factor(quality_dimensions))

