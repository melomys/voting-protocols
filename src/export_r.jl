using RCall
using Distributed

function export_data(model_init_params, name;
    model_properties = default_model_properties,
    evaluation_functions = default_evaluation_functions,
    iterations = 1000,
    pack = 5)
    @time begin
    @sync @distributed for i=1:iterations

    model_dfs, corr_df = collect_model_data(
        model_init_params,
        model_properties,
        evaluation_functions,
        pack)
        export_rds(corr_df, model_dfs, name)
        end
    end

end




function export_rds(df, model_dfs, keyword = "")
    files = cd(readdir,"data")
    numbers = map(x -> parse(Int32,match(r"([0-9]+).rds",x)[1]),files)

    if length(numbers) == 0
        no = 1
    else
        no = maximum(numbers) + 1
    end

    no = rand(1:2147483647)


    if keyword == ""
        df_file = "data/df$(no).rds"
        model_dfs_file = "data/model_dfs$(no).rds"
    else
        df_file = "data/df_$(keyword)_$(no).rds"
        model_dfs_=ile = "data/model_dfs_$(keyword)_$(no).rds"
    end



    R"""
    saveRDS($(robject(df)), file = $df_file)
    """
    #R"""
    #saveRDS($(robject(cat_model_dfs(model_dfs))), file = $model_dfs_file)
    #"""

end

function col_names(model_dfs)
    max_length = 1
    max_model_df =  model_dfs[1]
    for model_df in model_dfs
        for col_name in names(model_df)
            l = length(model_df[end, col_name])
            if l > max_length
                max_length = l
                max_model_df = model_df
            end
        end
    end


    ret_names = Symbol[]
    for col_name in names(max_model_df)
        el = max_model_df[end,col_name]
        l = length(el)
        if l == 1
            push!(ret_names,col_name)
        else
            for i in 1:l
                push!(ret_names, Symbol("$(string(col_name))$i"))
            end
        end
    end
    return ret_names
end


function add_model_df(all_model_df, model_df)
    new_df = copy(all_model_df)

end

function cat_model_dfs(model_dfs)
    df = DataFrame()

    max_length = 1
    for model_df in model_dfs
        for col_name in names(model_df)
            l = length(model_df[end, col_name])
            if l > max_length
                max_length = l
            end
        end
    end

    i = 0
    for model_df in model_dfs
         i = i + 1
         println(i)
        tmp_df = DataFrame()
        for col_name in names(model_df)
            el = model_df[end,col_name]
            l = length(el)
            if l == 1 || (typeof(el) <: String)
                tmp_df = hcat(tmp_df, model_df[!, col_name];makeunique = true)
            else
                to_cat = Matrix(post_data(model_df[!, col_name]))
                if l < max_length
                    for i in 1:(max_length-l)
                        to_cat = hcat(to_cat, ones(size(to_cat)[1])*NaN)
                    end
                end
                tmp_df = hcat(tmp_df, DataFrame(to_cat); makeunique = true)

            end
        end
        df = vcat(df, tmp_df)
    end
    rename!(df, col_names(model_dfs))
    return df
end
