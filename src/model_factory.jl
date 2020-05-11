function grid_params(model_params::Dict)
        models = []
        function rec(rest_keys, values,dic,model)
                if isempty(rest_keys)
                        new_model = model(;values...)
                        push!(models, new_model)
                        return
                end
                next_key = rest_keys[1]
                new_rest_keys = filter(x -> x != next_key, rest_keys)
                vals = dic[next_key]
                if typeof(vals) <: Vector
                        for i in 1:length(vals)
                                new_values = vcat(values, next_key => vals[i])
                                rec(new_rest_keys,new_values, dic,model)
                        end
                else
                        new_values = vcat(values, next_key => vals)
                        rec(new_rest_keys,new_values, dic,model)
                end

        end

        for model in keys(model_params)
                params = model_params[model]
                rec(collect(keys(params)), [], params,model)
        end
        return models
end
