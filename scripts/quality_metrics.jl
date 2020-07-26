push!(LOAD_PATH, "/home/ludwig/Bachelorarbeit/Agents.jl/src")

using Plots
using LinearAlgebra


create_quality_matrix(n, dim) = rand(dim,n)


dim = 2
n_users = 1
n_posts = 4

posts = create_quality_matrix(n_posts,dim)
#posts = [0.4 0.3 0.9 0.8; 0.1 0.8 0.7 0.2]
#users = create_quality_matrix(n_users,dim)
users = [0.3; 0.0]

p = plot(posts[1,:],posts[2,:], seriestype = :scatter, title = "Quality of Posts",legend=false)
plot!(users[1,:], posts[2,:], seriestype = :scatter)


skalarprodukt1 = transpose(users) * posts
skalarprodukt2 = transpose(users.^2) * posts
skalarprodukt3 = (transpose(users.^2) * posts.^2)

for i in 1:n_posts
    plot!([posts[1,i],skalarprodukt1[i]],[posts[2,i],0], c="green")
    plot!([posts[1,i],skalarprodukt2[i]],[posts[2,i],0], c="red")
    plot!([posts[1,i],skalarprodukt3[i]],[posts[2,i],0], c="blue")
    #norm2 = norm(users - posts[:,i],5
    #plot!([posts[1,i],2-norm2],[posts[2,i],0], c="red")
end
display(p)
