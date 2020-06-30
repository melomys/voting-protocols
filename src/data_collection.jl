import Base

include("evaluation.jl")

function collect_model_data(model_init_params, model_properties,evaluation_functions, iterations = 10)
    corr_df = init_correlation_dataframe(evaluation_functions)

    model_dfs = []

    for i = 1:iterations
        println("$((i-1)/iterations*100) %")
        seed = abs(rand(Int32))
        models = create_models(model_init_params; seed = seed)

        for j = 1:length(models)
            tmp_model = models[j]
            agent_df, model_df = run!(
                tmp_model,
                tmp_model.agent_step!,
                tmp_model.model_step!,
                steps;
                agent_properties = [],
                model_properties = model_properties,
            )

            push!(model_dfs, model_df)

            ab_model = tmp_model
            ab_model_df = model_df
            global ab_model
            global ab_model_df

            push!(
                corr_df,
                map(x -> x(ab_model, ab_model_df), evaluation_functions),
            )
        end
    end
    return model_dfs, corr_df
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
            if typeof(val) <: Function
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

function init_correlation_dataframe(functions)
    DataFrame(Dict(map(x -> (Symbol(x), []), functions)))
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

function unary_columns(df)
    df[!, filter(x -> (typeof(df[1, x]) <: Union{Float64,Int,Bool}), names(df))]
end

default_model_properties = [
    ranking_rating,
    ranking_rating_relative,
    model_id,
    @get_post_data(:score, identity),
    @get_post_data(:votes, identity),
]

default_view_model_properties =
    [default_model_properties..., @get_post_data(:views, identity)]



function generate_model_evaluation_parameters(model_init_params)
    models = create_models(model_init_params)
    parameters = sort(unique(reduce((a,b) -> [a...,b...],map(x-> keys(x.properties),models))))
    funcs = []
    l = [:a, :b, :c]
    for param in l
        func = eval(:(@model_init_property_function($param)))
        push!(funcs, func)
    end
    funcs
end

macro model_init_property_function(property, func = identity)
    #property = Symbol("",eval)
    println(property)
    println(typeof(property))
    if eval(func) === identity
        name = Symbol("", eval(property))
    else
        name = Symbol(func, "_", eval(property))
    end

    return :(function $name(model, model_df = Nothing)
        if hasproperty(model, Symbol($name))
            val = model.$(eval(property))
            if typeof(val) <: Function
                string(val)
            else
                $func(model.$(eval(property)))
            end
        else
            NaN
        end
    end)
end
