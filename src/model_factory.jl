function grid_params(model_params...)
        println("model_params")
        println(model_params)
        println(typeof(model_params))
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

        for model in model_params
                println("MODEL")
                println(typeof(model))
                rec(collect(keys(model[2])), [], model[2],model[1])
        end
        return models
end
