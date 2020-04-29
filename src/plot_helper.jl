function create_plot_data_score(model_df)
    scores = model_df[!,:identity_score]
    ncols = maximum(map(length,scores))
    nrows = nrow(model_df)
    df = DataFrame([Vector{Float64}(zeros(nrows)) for i in 1:ncols])
    for i in 1:length(scores), j in  1:length(scores[i])
        df[i,j] = scores[i][j]
    end
    return df
end
