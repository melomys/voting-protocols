function activation_agent_step!(user,model)
    for i in 1:rand(model.rng, 1:model.n)
        post = model.posts[model.ranking[i]]
        if model.user_rating_function(post.quality, user.quality_perception) > user.vote_probability && !in(post, user.voted_on)
            push!(user.voted_on,post)
            post.votes += 1
        end
    end
end


function activation_model_step!(model)
    for i in 1:model.new_posts_per_step
        push!(model.posts, model.PostType(model.rng, model.time))
        model.n += 1
    end

    if rand(model.rng) < model.new_user_probability
        add_agent!(
            model,
            rand(model.rng,quality_distribution),
            rand(model.rng) / model.vote_probability,
            rand(model.rng,1:10)
        )
    end

    model.time += 1

    for i = 1:model.n
        model.posts[i].score = model.posts[i].votes
        model.posts[i].votes = 0
    end

    model.ranking = sortperm(map(x -> -x.score , model.posts))
end
