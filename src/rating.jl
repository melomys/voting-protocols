function user_rating(post_quality, user_quality_perception)
    sum((post_quality) .* (user_quality_perception))
end

function user_rating_exp(post_quality, user_quality_perception)
    reduce(*,sigmoid.(post_quality).^(sigmoid.(user_quality_perception)))
end
