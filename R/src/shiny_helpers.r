library(tidyverse)

source("src/data_preparation.r")

df <- convert_to_tibble(read_rds("../data/df3.rds"))
model_dfs <- tibble(read_rds("../data/model_dfs3.rds"))

