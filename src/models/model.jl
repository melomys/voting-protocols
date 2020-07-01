

#export User, Post, model_initiation, agent_step!, model_step!, @get_post_data
using DrWatson

using Agents
using DataFrames
using Statistics
using Distributions
using LinearAlgebra
using Random

include("../user_creation.jl")




abstract type AbstractPost end
abstract type AbstractUser <: AbstractAgent end

mutable struct Post <: AbstractPost
    quality::Array
    votes::Int64
    downvotes::Int64
    views::Int64
    timestamp::Int64
    score::Float64
end

function Post(rng::MersenneTwister, quality_distribution, time, init_score = 0)
    Post(rand(rng, quality_distribution), 0, 0,0, time, init_score)
end

function EqualPost(
    quality,
    rng,
    quality_distribution,
    time,
    PostType,
    init_score = 0,
)
    rand(rng, quality_distribution)
    PostType(quality, 0, 0, 0, time, init_score)
end

mutable struct User <: AbstractUser
    id::Int
    quality_perception::Array
    vote_probability::Float64
    activity_probability::Float64
    concentration::Int64
    voted_on::Array{AbstractPost}
    viewed::Array{AbstractPost}
end

function User(
    id::Int,
    quality_perception::Array{Float64},
    vote_probability::Float64,
    activity_probability::Float64,
    concentration::Int64,
)
    User(
        id,
        quality_perception,
        vote_probability,
        activity_probability,
        concentration,
        AbstractPost[],
        AbstractPost[],
    )
end


function standard_model(;
    activity_voting_probability_distribution = Distributions.MvNormal(
        [-2, 0],
        [2 0.9; 0.9 2],
    ),
    agent_step! = agent_step!,
    concentration_scale = 30:70,
    equal_posts = false,
    init_score = 0,
    model_step! = model_step!,
    model_type = standard_model,
    new_posts_per_step = 10,
    new_users_per_step = 0,
    PostType = Post,
    quality_dimensions = 3,
    quality_distribution = Distributions.MvNormal(
        zeros(quality_dimensions),
        I(3),
    ),
    scoring_function = scoring,
    seed = 0,
    sorted = 0,
    start_posts = 100,
    start_users = 100,
    steps = 100,
    user = user(),
    UserType = User,
    user_rating_function = user_rating,
    time_exp = 0.5,
    vote_evaluation = upvotes
    qargs...,
)


    rng_user_posts = MersenneTwister(seed - 1) # nur für user und post generierung
    rng_model = MersenneTwister(seed) # für alles andere


    posts = PostType[]
    if !equal_posts
        for i = 1:start_posts
            push!(posts, PostType(rng_user_posts, quality_distribution, 0))
        end
    else
        quality = [0.7, 0.6, 0.7]
        for i = 1:start_posts
            push!(
                posts,
                EqualPost(
                    quality,
                    rng_user_posts,
                    quality_distribution,
                    0,
                    PostType,
                ),
            )
        end
    end


    n = start_posts
    ranking = [1:start_posts...]
    time = 0

    user_ratings = []

    if sorted > 0
        tmp_properties = @dict(user_rating_function, time, quality_dimensions)
        tmp_model = ABM(UserType; properties = tmp_properties)
        scores = []
        for i = 1:start_posts
            push!(scores, scoring_best(posts[i], tmp_model.time, tmp_model))
        end
        ranking = sortperm(map(x -> x, scores))
        ranking = partial_shuffle(rng_model, ranking, 1 - sorted)
    end

    model_id = rand(1:2147483647)

    properties = @dict(
        activity_voting_probability_distribution,
        agent_step!,
        concentration_scale,
        init_score,
        model_id,
        model_step!,
        model_type,
        n,
        new_posts_per_step,
        new_users_per_step,
        posts,
        PostType,
        quality_dimensions,
        quality_distribution,
        ranking,
        rng_model,
        rng_user_posts,
        scoring_function,
        seed,
        start_posts,
        start_users,
        steps,
        time,
        time_exp,
        user,
        UserType,
        user_ratings,
        user_rating_function,
    )

    for qarg in qargs
        properties[qarg[1]] = qarg[2]
    end


    model = ABM(UserType; properties = properties)


    #user creation
    if typeof(user) <: Array
        @assert sum(map(x -> x[1], user)) == 1 "user_creation percentages sum is not equal to 1!"
        for p in user
            for i = 1:p[1]*start_users
                p[2](model)
            end
        end
    else
        for i = 1:start_users
            user(model)
        end
    end

    return model
end


# < user.activity
# und > 1 - user.vote_probability. Bsp vp = 0.3, dann muss urf > 0.7 sein
function agent_step!(user, model)
    if rand(model.rng_user_posts) < user.activity_probability
        for i = 1:minimum([user.concentration, model.n])
            post = model.posts[model.ranking[i]]
            if model.user_rating_function(
                post.quality,
                user.quality_perception,
            ) > 1 - user.vote_probability && !in(post, user.voted_on)
                push!(user.voted_on, post)
                post.votes += 1

                push!(
                    model.user_ratings,
                    model.user_rating_function(
                        post.quality,
                        user.quality_perception,
                    ),
                )

            end
        end
    end
end

function model_step!(model)
    for i = 1:model.n
        model.posts[i].score =
            model.scoring_function(model.posts[i], model.time, model)
    end

    for i = 1:model.new_posts_per_step
        push!(
            model.posts,
            model.PostType(
                model.rng_user_posts,
                model.quality_distribution,
                model.time,
                model.init_score,
            ),
        )
        model.n += 1
    end

    for i = 1:model.new_users_per_step
        model.user()(model)
    end

    model.ranking = sortperm(map(x -> -x.score, model.posts))
    model.time += 1

end


function partial_shuffle(rng, v::AbstractArray, percent)
    amount = round(Int, length(v) * percent)
    indeces = [1:length(v)...]
    ret = copy(v)
    rand_numbers = []
    for i = 1:amount
        new_rand_number = rand(rng, indeces)
        indeces = filter(x -> x != new_rand_number, indeces)
        push!(rand_numbers, new_rand_number)
    end

    for i = 1:2*length(rand_numbers)
        a = rand(rng, rand_numbers)
        b = rand(rng, rand_numbers)
        ret[a], ret[b] = ret[b], ret[a]
    end
    ret
end
