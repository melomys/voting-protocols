function grid_params(model_params; seed = 1)
        models = []
        function rec(rest_keys, values, dic, model)
                if isempty(rest_keys)
                        values_with_seed = vcat(values, :seed => seed)
                        push!(models, model => values_with_seed)
                        return
                end
                next_key = rest_keys[1]
                new_rest_keys = filter(x -> x != next_key, rest_keys)
                vals = dic[next_key]
                if typeof(vals) <: Vector
                        for i = 1:length(vals)
                                new_values = vcat(values, next_key => vals[i])
                                rec(new_rest_keys, new_values, dic, model)
                        end
                else
                        new_values = vcat(values, next_key => vals)
                        rec(new_rest_keys, new_values, dic, model)
                end

        end

        all_models = Dict{Symbol,Any}()

        for model in model_params
                if model[1] == :all_models
                        for key in keys(model[2])
                                all_models[key] = model[2][key]
                        end
                end
        end

        model_params = filter(x -> !(typeof(x[1]) <: Symbol), model_params)
        for model in model_params

                if typeof(model[1]) <: Vector
                        for m in model[1]
                                props = add_dicts(model[2], all_models)
                                rec(collect(keys(props)), [], props, m)
                        end
                else
                        props = add_dicts(model[2], all_models)
                        rec(collect(keys(props)), [], props, model[1])
                end
        end
        return models
end




create_models(model_params; seed = 1) =
        map(x -> x[1](; x[2]...), grid_params(model_params; seed = seed))

get_params(model_params) = map(x -> x[2], grid_params(model_params))



function param_count(param)
        if typeof(param) <: Vector
                length(param)
        else
                1
        end
end

function model_count(model_params)
        sum(map(
                x -> reduce(*, map(param_count, collect(values(x)))),
                map(x -> x[2], model_params),
        ))
end


function add_dicts(d_model, d_default)
        d_ret = copy(d_default)
        for key in keys(d_model)
                d_ret[key] = d_model[key]
        end
        return d_ret
end
