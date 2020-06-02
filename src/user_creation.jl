function users()
    function add_users!(model, quality_distribution, rng)
        for i = 1:n
            add_agent!(
                model,
                rand(rng, quality_distribution),
                sigmoid(rand(rng)),
                rand(rng, 1:30),
            )
        end
    end
end


function extreme_users(n, percent, exremeness)
    function add_users!(model, quality_distribution, rng)
        n_extreme = round(percent * n)
        for i = 1:n_extreme
            add_agent!(
                model,
                rand(rng, quality_distribution) .- extremeness,
                rand(rng, [1]),
                rand(rng, [n]),
            )
        end
        for i = 1:(n-n_extreme)
            add_agent!(
                model,
                rand(rang, quality_distribution),
                sigmoid(rand(rng)),
                rand(rng, 1:30),
            )
        end
    end
end

function boring_users()
    function add_users!(model, quality_distribution, rng)
        for i = 1:n
            add_agent!(
            model,
            rand(rng, [mean(quality_distribution)]),
            sigmoid(rang,rng),
            rand(rng,1:30),
            )
        end
    end
end
