using Logging



kv = [1.0 2.0 3.0; 2.0 1.0 4.0; 3.0 4.0 1.0]
g = MvNormal(zeros(3), kv)


n = rand(g,20000)


sigmoid(x) = 1/(1+ℯ^((1/(2*g.σ))*(x)))

#n[:,2] = sigmoid.(n[:,2])
#histogram(n[:,2])

"""
@info "Normal"
@info "Mean: $(mean(n[:,1]))"
@info "Std: $(std(n[:,1]))"
@info "Sigmoid"
@info "Mean: $(mean(n[:,2]))"
@info "Std: $(std(n[:,2]))"
"""

histogram(n[1,:])
