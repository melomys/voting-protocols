function user_rating(post_quality, user_quality_perception)
    sum(sigmoid.(post_quality) .* sigmoid.(user_quality_perception))
end

function user_rating_exp(post_quality, user_quality_perception)
    reduce(*,sigmoid.(post_quality).^(sigmoid.(user_quality_perception)))
end

function user_rating_exp2(post_quality, user_quality_perception)
    sum(sigmoid.(post_quality).^(sigmoid.(user_quality_perception)))/length(post_quality)

end

function user_rating_dist1(post_quality, user_quality_perception)
    1 - sum(abs.(sigmoid.(post_quality) - sigmoid.(user_quality_perception)))/length(post_quality)
end

function user_rating_dist2(post_quality, user_quality_perception)
    1 - sqrt(sum((sigmoid.(post_quality) - sigmoid.(user_quality_perception)).^ 2))/sqrt(length(post_quality))
end
