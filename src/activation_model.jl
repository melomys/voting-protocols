


function activation_model(;
    start_posts = 100,
    start_users = 100,
    new_user_probability = 0,
    vote_probability_scale = 1,
    frontpagesize = 10,
    new_posts_per_step = 3,
    scoring_function = scoring,
    user_rating_function = user_rating,
    seed = 0,
    agent_step! = agent_step!,
    model_step! = model_step!,
)
    rng = MersenneTwister(seed)
    posts = Post[]
    for i = 1:start_posts
        push!(posts, Post(rand(rng,quality_distribution), 0, 0, 0))
    end

    n = start_posts
    ranking = [1:start_posts...]
    time = 0

    properties = @dict(
        n,
        posts,
        new_user_probability,
        vote_probability_scale,
        new_posts_per_step,
        frontpagesize,
        ranking,
        scoring_function,
        user_rating_function,
        time,
        agent_step!,
        model_step!,
        rng
    )
    model = ABM(User; properties = properties)
    for i = 1:start_users
        add_agent!(
            model,
            rand(rng,quality_distribution),
            rand(rng) / vote_probability_scale,
            rand(rng,1:10),
        )
    end
    return model
end


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
        push!(model.posts, Post(rand(model.rng,quality_distribution), 0, model.time, 0))
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
