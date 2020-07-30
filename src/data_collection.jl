import Base
using Logging
using Distributed

function collect_model_data(
    model_init_params,
    model_properties,
    evaluation_functions,
    iterations = 10,
)

    run_id = rand(1:2147483647)
    models = create_models(model_init_params)
    df = init_correlation_dataframe(
        evaluation_functions,
        models,
        model_properties,
    )


    model_dfs = []
    try
        for i = 1:iterations
            @info "$((i-1)/iterations*100) % | $(myid())"
            seed = abs(rand(Int32))
            models = create_models(model_init_params; seed = seed)

            for j = 1:length(models)
                @info "Step $i: $j"
                tmp_model = models[j]
                agent_df, model_df = run!(
                    tmp_model,
                    tmp_model.agent_step!,
                    tmp_model.model_step!,
                    tmp_model.steps;
                    agent_properties = [],
                    model_properties = model_properties,
                )

                push!(model_dfs, model_df)

                ab_model = tmp_model
                ab_model_df = model_df
                push!(df, map(x -> x(ab_model, ab_model_df), evaluation_functions))
            end

            if i%100 == 0
                export_rds(df, model_dfs, "$(i)_$(run_id)_tmp")
            end
        end
    catch e
        if isa(e, InterruptException)
            @info "Interrupted"
        else
            throw(e)
        end
    finally
        return model_dfs, df
    end
end


function Base.getproperty(value, name::Symbol, default_value)
    if hasproperty(value, name)
        return getproperty(value, name)
    else
        return default_value
    end
end

"""
macro to create function, that collects post data over the given aggretation function
    the name function is namend after the collected post property and the given aggregation function
        the returned function can be given to the run! function
"""
macro get_post_data(property, func)
    if eval(func) === identity
        name = Symbol("", eval(property))
    else
        name = Symbol(func, "_", eval(property))
    end
    return :(
        function $name(model)
            collected = map(x -> getproperty(x, $property, NaN), model.posts)
            $func(collected)
        end
    )
end


"""
macro to create a function to return the given property from a model,
    the function is named after the porperty
"""
macro model_property_function(property, func = identity)
    if eval(func) === identity
        name = Symbol("", eval(property))
    else
        name = Symbol(func, "_", eval(property))
    end

    return :(function $name(model, model_df = Nothing)
        if hasproperty(model, Symbol($name))
            val = model.$(eval(property))
            if typeof(val) <: Union{Function,Distribution}
                string(val)
            else
                $func(model.$(eval(property)))
            end
        else
            NaN
        end
    end)
end


""" returns dataframe, each row holds the given parameter over time of one post.
    time in the dataframe is relative to the creation of the post.
    the dataframe is right-padded with the last value of each post/NaN.
"""
function relative_post_data(data)
    padding = NaN
    ncols = maximum(map(length, data))
    left_padded = [
        vcat(data[i], ones(ncols - length(data[i])) * padding)
        for i = 1:length(data)
    ]
    left_padded_transformed =
        [map(x -> x[i], left_padded) for i = 1:length(left_padded[1])]
    filter_padding(x) = filter(!isnan, x)
    right_padded = map(
        x -> vcat(
            filter_padding(x),
            ones(length(data) - length(filter_padding(x))) * padding,
        ),
        left_padded_transformed,
    )
    DataFrame(right_padded)
end

""".
returns dataframe, each column holds the given parameter over time of one post.
the dataframe ist left-padded with NaN.
"""
function post_data(data)
    padding = NaN
    ncols = maximum(map(length, data))
    DataFrame(
        Matrix(DataFrame([
            vcat(data[i], ones(ncols - length(data[i])) * padding)
            for i = 1:length(data)
        ]))',
    )
end



function columnname(model_params)
    string(reduce(
        (x, y) -> x * "_" * y,
        map(x -> string(model_params[x]), collect(keys(model_params))),
    ))
end

function init_result_dataframe(models_params)
    DataFrame(Dict(map(
        x -> (columnname(Dict(x)), []),
        get_params(model_init_params),
    )))
end

function init_correlation_dataframe(functions, models, model_properties)
    tmp_model = models[1]
    agent_df, model_df = run!(
        tmp_model,
        tmp_model.agent_step!,
        tmp_model.model_step!,
        1;
        agent_properties = [],
        model_properties = model_properties,
    )

    corr_dict = Dict()
    for func in functions
        r = func(tmp_model, model_df)
        #if typeof(r) <: Union{Int, Float64, Array, Symbol, String}
        if typeof(r) <: Int
            corr_dict[Symbol(func)] = Float64[]
        else
            corr_dict[Symbol(func)] = typeof(r)[]
        end
        #else
        #    corr_dict[Symbol(func)] = String[]
        #end
    end

    return DataFrame(corr_dict)
end

macro post_property_function(property)
    name = Symbol("", eval(property))
    return :(function $name(post, model, model_df)
        post.$name
    end)
end


macro rating_correlation(function1, function2)
    name = Symbol("corr_", eval(function1), "_", eval(function2))
    return :(function $name(model, model_df)
        v1 = []
        v2 = []
        for post in model.posts
            push!(v1, $function1(post, model, model_df))
            push!(v2, $function2(post, model, model_df))
        end
        return cor(v1, v2)
    end)
end

macro model_df_column(col)
    name = Symbol(eval(col), "_all")
    return :(function $name(model, model_df)
    model_df[!,$col]
    end)
end

function unary_columns(df)
    df[!, filter(x -> (typeof(df[1, x]) <: Union{Float64,Int,Bool}), names(df))]
end


"""
Default Parameters
"""

timestamp_func = @post_property_function(:timestamp)
score_func = @post_property_function(:score)
