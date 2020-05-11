

mutable struct ViewPost <: APost
    quality::Array
    votes::Int64
    views::Int64
    timestamp::Int64
    score::Float64
end

function ViewPost(rng)
    ViewPost(rand(rng, quality_distribution), 0, 0, 0, 0)
end

function ViewPost(rng,time)
    ViewPost(rand(rng, quality_distribution),0,0,time,0)
end

function view_model(;
    start_posts = 100,
    start_users = 100,
    new_user_probability = 0,
    vote_probability_scale = 1,
    frontpagesize = 10,
    new_posts_per_step = 3,
    scoring_function = scoring_view,
    user_rating_function = user_rating,
    seed = 0,
    agent_step! = view_agent_step!,
    model_step! = model_step!,
    PostType = ViewPost,
    UserType = User,
)
    rng = MersenneTwister(seed)
    posts = PostType[]
    for i = 1:start_posts
        push!(posts, PostType(rng))
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
        rng,
        PostType,
        UserType
    )
    model = ABM(User; properties = properties)
    for i = 1:start_users
        add_agent!(
            model,
            rand(quality_distribution),
            rand() / vote_probability_scale,
            rand(1:10),
        )
    end
    return model
end

function view_agent_step!(user, model)
    for i = 1:rand(model.rng, 1:model.n)
        post = model.posts[model.ranking[i]]
        if model.user_rating_function(post.quality, user.quality_perception) >
           user.vote_probability && !in(post, user.voted_on)
            push!(user.voted_on, post)
            post.votes += 1
            post.views += 1
        elseif !in(post,user.voted_on)
            post.views += 1
        end
    end
end


function scoring_view(post, time)
    (post.votes / post.views)^2 / (time - post.timestamp)^(0.1)
end
