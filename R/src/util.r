library(tidyverse)
library(cowplot)
library(GGally)
library(ggstatsplot)
library(reshape2)
library(hexbin)
library(rlist)
library(ggcorrplot)
library(openssl)
library(plyr)
library(dplyr)
library(extrafont)

#font_import(pattern = "lmodern*")
#loadfonts(device = "postscript")
#par(family = "LM Roman 10")
ggplot_cus = function(element)
{
  element %>% 
  ggplot() + 
  theme(text=element_text(family="Computer Modern")) + 
  scale_shape_manual(values=c(19,3,4,5))
    
}

ggplot_scatter = function(element)
{
  element %>% 
    ggplot_cus() + 
    labs(x = "T(G)", y = "T(nDCG)", size = expression(P["v=0"])) 
}



import_df = function(str)
{
  df = read_rds(str)
  df = tibble(df)
  df = df %>% 
    mutate(relevance_gravity = factor(relevance_gravity))
  df$user_rating_function = revalue(x = df$user_rating_function, c("user_rating_exp2" = "Konsens", "user_rating_dist2" = "Dissens"),warn_missing = FALSE)
  df$vote_evaluation = revalue(x = df$vote_evaluation, c("vote_difference" = "Differenz" , "vote_partition" = "Anteil", "wilson_score" = "Wilson Score"),warn_missing = FALSE)
  df$scoring_function = revalue(x = df$scoring_function, c("scoring_activation" = "Aktivität","scoring_hacker_news"="Verallg. Hacker News", "scoring_view" = "View", "scoring_reddit_hot" = "Reddit Hot"),warn_missing = FALSE)
  df$model_type = revalue(x = df$model_type, c("standard_model" = 1, "downvote_model" = 2),warn_missing = FALSE)
  df$deviation_function = revalue(x = df$deviation_function, c("no_deviation" = "0", "mean_deviation" = "μ", "std_deviation" = "σ"),warn_missing = FALSE)
  df$relevance_gravity = revalue(x = df$relevance_gravity, c("0" = "Q&A", "2" = "News"), warn_missing = FALSE)
  df %>% 
   # filter(user_rating_function == "Konsens") %>% 
    mutate(ρ = 0.5 -(area_under_ndcg/2 - area_under_gini/4 - posts_with_no_views/4)) %>% 
    mutate(seed = factor(seed)) %>% 
    mutate(model_id = factor(model_id)) %>% 
    mutate(init_score = factor(init_score)) %>% 
    mutate(relevance_gravity = factor(relevance_gravity)) %>% 
    mutate(gravity = factor(gravity)) %>% 
    mutate(steps = factor(steps)) %>% 
    mutate(concentration_distribution = factor(concentration_distribution)) %>% 
    mutate(scoring_function = factor(scoring_function)) %>% 
    mutate(user_rating_function = factor(user_rating_function)) %>% 
    # mutate(activity_distribution = factor(activity_distribution)) %>% 
    mutate(voting_probability_distribution = factor(voting_probability_distribution))
}

cust_filter <- function(x,func)
{
  ret = c()
  for (s in x)
  {
    if (func(s))
    {
      ret = append(ret, s)
    }
  }
  ret
}

combine_dfs = function(path,name)
{
  l = cust_filter(list.files(path, full.names = TRUE),function(x){grepl(name,x)})
  reduce(map(l,import_df), bind_rows)
}

corr_matrix = function(df, feature)
{
  df = df %>% 
    filter(user_rating_function == "Konsens")
  gaga = tibble(.rows = nrow(df)/nrow(unique(df[,feature])))
  for (name in unlist(unique(df[,feature])))
  {
    tmp_df = df %>% 
      filter(!!sym(feature) == name)
   gaga = add_column(gaga, !!sym(toString(name)) := tmp_df[,"ρ"])
  }
  gaga
  #cor(gaga, method= "spearman")
  #spear_tib = tibble(s50 = spear_50$ρ, s100 = spear_100$ρ, s300 = spear_300$ρ, s500 = spear_500$ρ)
  
}
