function scoring(post, time, model)
    (post.votes)^1 / (time - post.timestamp + 1)^(0.3)
end

function scoring_custom(post,time,model)
    (post.votes+1)^model.votes_exp / (time - post.timestamp + 1)^model.time_exp
end

function scoring_hacker_news(post, time, model)
    (post.votes - 1)^8 / (time - post.timestamp + 1)^1.8
end

function scoring_random(post, time, model)
    rand()
end

function scoring_best(post, time, model)
    model.user_rating(post.quality, ones(model.quality_dimensions))
end

function scoring_worst(post, time, model)
    - scoring_best(post, time,model)
end


function scoring_acitvation(post, time,model)
    (post.votes - post.score) / (time -post.timestamp + 1)^(0.3)
end
