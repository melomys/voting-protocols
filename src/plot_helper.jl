function unpack_data(data;padding=0)
    ncols = maximum(map(length, data))
    nrows = nrow(model_df)
    DataFrame(Matrix(DataFrame([vcat(data[i], ones(ncols - length(data[i]))*padding) for i in 1:length(data)]))')
end
