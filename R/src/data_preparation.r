library(tidyverse)

# Dieser komplizierte Umweg muss genommen werden, wenn die exportierten als Spaltentype "Any" Besitzen
convert_to_tibble <- function(df)
{
  mat = matrix(ncol = ncol(df), nrow = nrow(df))
  factors = c()
  for (i in 1:ncol(df))
  {
    if(is.character(unlist(df[1,i])))
    {
      factors <- append(factors, i)
    }
    else if(length(unlist(df[,i])) == nrow(df))
    {
      mat[,i] <- unlist(df[,i])
    }
  }
  tib = tibble(data.frame(mat))
  colnames(tib) <- colnames(df)
  for (i in factors)
  {
    tib[,colnames(tib)[i]] <- unlist(map(df[,colnames(df)[i]],factor))
  }
  tib
}


relative_post_data <- function(df)
{
  tib = tibble(.rows = nrow(df))
  for (name in colnames(df))
  {
    dropped_na <- df[,name] %>% 
      drop_na()
    
    if(nrow(dropped_na) < nrow(df))
    {
      dropped_na <- dropped_na %>% 
        add_column(dummy = 1:nrow(dropped_na)) %>% 
        add_row(dummy = 1:(nrow(df) - nrow(dropped_na)))
      
      to_add <- dropped_na %>% select(-dummy)
    }else
    {
      to_add = dropped_na
    }
    tib = add_column(tib, to_add)
    
  }
  tib
}