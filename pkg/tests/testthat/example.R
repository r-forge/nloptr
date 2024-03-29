# Copyright (C) 2010 Jelmer Ypma. All Rights Reserved.
# This code is published under the L-GPL.
#
# File:   example.R
# Author: Jelmer Ypma
# Date:   10 June 2010
#
# Example showing how to solve the problem from the NLopt tutorial.
#
# min sqrt( x2 )
# s.t. x2 >= 0
#      x2 >= ( a1*x1 + b1 )^3
#      x2 >= ( a2*x1 + b2 )^3
# where
# a1 = 2, b1 = 0, a2 = -1, b2 = 1
#
# re-formulate constraints to be of form g(x) <= 0
#      ( a1*x1 + b1 )^3 - x2 <= 0
#      ( a2*x1 + b2 )^3 - x2 <= 0

library('nloptr')


# objective function
eval_f0 <- function( x, a, b ){ 
    return( sqrt(x[2]) )
}

# constraint function
eval_g0 <- function( x, a, b ) {
    return( (a*x[1] + b)^3 - x[2] )
}

# gradient of objective function
eval_grad_f0 <- function( x, a, b ){ 
    return( c( 0, .5/sqrt(x[2]) ) )
}

# jacobian of constraint
eval_jac_g0 <- function( x, a, b ) {
    return( rbind( c( 3*a[1]*(a[1]*x[1] + b[1])^2, -1.0 ), 
                   c( 3*a[2]*(a[2]*x[1] + b[2])^2, -1.0 ) ) )
}


# functions with gradients in objective and constraint function
# this can be useful if the same calculations are needed for
# the function value and the gradient
eval_f1 <- function( x, a, b ){ 
    return( list("objective"=sqrt(x[2]), 
                 "gradient"=c(0,.5/sqrt(x[2])) ) )
}

eval_g1 <- function( x, a, b ) {
    return( list( "constraints"=(a*x[1] + b)^3 - x[2],
                  "jacobian"=rbind( c( 3*a[1]*(a[1]*x[1] + b[1])^2, -1.0 ), 
                                    c( 3*a[2]*(a[2]*x[1] + b[2])^2, -1.0 ) ) ) )
}


# define parameters
a <- c(2,-1)
b <- c(0, 1)

# Solve using NLOPT_LD_MMA with gradient information supplied in separate function
res0 <- nloptr( x0=c(1.234,5.678), 
                eval_f=eval_f0, 
                eval_grad_f=eval_grad_f0,
                lb = c(-Inf,0), 
                ub = c(Inf,Inf), 
                eval_g_ineq = eval_g0,
                eval_jac_g_ineq = eval_jac_g0,                
                opts = list("algorithm"="NLOPT_LD_MMA"),
                a = a, 
				b = b )
print( res0 )
        
# Solve using NLOPT_LN_COBYLA without gradient information
res1 <- nloptr( x0=c(1.234,5.678), 
                eval_f=eval_f0, 
                lb = c(-Inf,0), 
                ub = c(Inf,Inf), 
                eval_g_ineq = eval_g0, 
                opts = list("algorithm"="NLOPT_LN_COBYLA", "check_derivatives"=TRUE),
                a = a, 
				b = b )
print( res1 )


# Solve using NLOPT_LD_MMA with gradient information in objective function
res2 <- nloptr( x0=c(1.234,5.678), 
                eval_f=eval_f1, 
                lb = c(-Inf,0), 
                ub = c(Inf,Inf), 
                eval_g_ineq = eval_g1, 
                opts = list("algorithm"="NLOPT_LD_MMA", "check_derivatives"=TRUE),
                a = a,
				b = b )
print( res2 )
