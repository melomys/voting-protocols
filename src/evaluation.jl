function ranking_rating(model)
    rating = 0
    for i = 1:model.n
        rating +=
            1 / i * user_rating(
                model.posts[model.ranking[i]].quality,
                ones(quality_dimensions),
            )
    end
    return rating
end


function trapezoidial_rule(points)
    sum(points) - 1/2(points[1] + points[end])
end
