function unpack_data(data;padding=0)
    ncols = maximum(map(length, data))
    DataFrame(Matrix(DataFrame([vcat(data[i], ones(ncols - length(data[i]))*padding) for i in 1:length(data)]))')
end
