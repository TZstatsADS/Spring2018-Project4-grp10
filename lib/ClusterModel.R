####################################################################################################
### Author: Yiyi Zhang
### Project 4, Group 10
### ADS Spring 2018

### cluster.cv -- Perfom K-Fold Cross-Validation
### cluster.em -- Learn Parameters Using EM Algorithm
### cluster.score -- Compute Score Estimation 
### cluster.pi -- Compute Responsibilities 
####################################################################################################

####################################################################################################
########## BEGIN cluster.cv ##########
cluster.cv <- function(df, C.list, fold.n=5, tau=0.5, seed=123){
  # Perform K-Fold Cross-Validation
  # Input-- df: dataframe (User x Movie)
  #         C.list: a list of C (number of classes)
  #         fold.n: number of folds
  #         tau: convergence threshold 
  #         seed: seed of ramdom sampling
  # Output-- validation errors
  set.seed(seed)
  obs.n <- sum(!is.na(df))
  fold.size <- floor(obs.n/fold.n)
  fold.i <- sample(rep(seq(fold.n), 
                       c(rep(fold.size,fold.n-1),obs.n-fold.size*(fold.n-1))))
  fold.I <- df
  fold.I[!is.na(fold.I)] <- fold.i
  error.validation <- matrix(NA, fold.n, length(C.list))
  
  for (c in seq(length(C.list))) {
    for (i in seq(fold.n)) {
      print(paste0("C = ", C.list[c], " (fold ", i, "): "))
      df.training <- df
      df.training[fold.I==i] <- NA
      df.validation <- df
      df.validation[fold.I!=i] <- NA
      pars <- cluster.em(df.training, C.list[c], tau)
      df.est <- cluster.score(df.training, pars)
      error.validation[i,c] <- sum(abs(df.est-df.validation),na.rm = T)/sum(!is.na(df.est-df.validation))
      print(paste0("error.validation = ", error.validation[i,c]))
    }
  }
  return(error.validation)
}
########## END cluster.cv ##########
####################################################################################################

####################################################################################################
########## BEGIN cluster.em ##########
cluster.em <- function(df, C, tau, seed=123) {
  # Learn Parameters Using EM Algorithm
  # Input-- df: dataframe (User x Movie)
  #         C: number of classes
  #         tau: convergence threshold
  #         seed: seed of random sampling
  # Output-- list(mu, gamma) parameters of the cluster model 
  #     mu (C x 1): probability that user belongs to c
  #     gamma (Class x Movie x Score): probability of the score for a movie in a given class
  
  # Step 0: Define Variables
  users <- rownames(df) # i  
  movies <- colnames(df) # j
  scores <- unique(unlist(df))
  scores <- sort(scores[!is.na(scores)]) # k
  N <- length(users) # number of users
  M <- length(movies) # number of movies
  K <- length(scores) # number of scores
  
  # Step 1: Initilize Paramenters
  set.seed(seed)
  mu <- runif(C)
  mu <- mu/sum(mu)
  gamma <- array(runif(C*M*K), c(C,M,K)) # Class x Movie x Score 
  for (k in seq(K)) {
    gamma[,,k] <- gamma[,,k]/rowSums(gamma[,,], dims = 2)
  }    
  
  iter <- 0
  repeat{  
    iter <- iter + 1
    pars <- list(mu=mu, gamma=gamma)
    # Step 2: Expectation
    # compute repsonsibilities for each user i
    Pi <- cluster.pi(df, pars) # User x Class
    
    # Step 3: Maximization
    # update parameters 
    mu.new <- colSums(Pi)/N
    I.all <- ifelse(is.na(df),0,1) # User x Movie
    I <- array(0, c(N,M,K)) # User x Movie x Score
    gamma.new <-  array(NA, c(C,M,K))
    for (k in seq(K)){
      I[,,k] <- ifelse((df!=k|is.na(df)),0,1)
      gamma.new[,,k] <- (t(Pi)%*%I[,,k])/(t(Pi)%*%I.all)
    }
    gamma.new[is.na(gamma.new)] <- 1/K
    gamma.new[gamma.new==0] <- min(gamma.new[gamma.new!=0])
    
    # Step 4: Iteration
    # stop if converge
    change.mu <- mean(abs(mu.new-mu))
    change.gamma <- norm(as.matrix(gamma.new-gamma), "f")
    print(paste0("  iter ", iter,
                 ": change.mu = ", round(change.mu,4), 
                 ", change.gamma = ", round(change.gamma,4)))
    
    if ((change.mu<tau) & (change.gamma<tau)){break} 
    mu <- mu.new
    gamma <- gamma.new
  }     
  return(pars)
}
########## END cluster.em ##########
####################################################################################################

####################################################################################################
########## BEGIN cluster.score ##########
cluster.score <- function(df, pars){
  # Compute Score Estimation
  # Input-- df: dataframe (User x Movie)
  #         pars: list(mu, gamma) parameters of cluster model
  # Output-- a dataframe of estimated scores (User x Movie)
  
  # Define Variables
  mu <- pars$mu
  gamma <- pars$gamma
  K <- dim(gamma)[3] # number of scores
  C <- dim(gamma)[1] # number of classes  
  
  # Compute Pi
  Pi <- cluster.pi(df, pars) # User x Class
  
  # Estimate Score
  I.all <- ifelse(is.na(df),1,0) # User x Movie
  score.est <- 0
  for (k in seq(K)) {
    prob <- (Pi%*%gamma[,,k])*I.all 
    score.est <- score.est + k*prob # User x Movie
  }
  score.est[!is.na(df)] <- NA
  return(score.est)
}
########## END cluster.score ##########
####################################################################################################

####################################################################################################
########## BEGIN cluster.pi ##########
cluster.pi <- function(df, pars){
  # Compute Responsibilities 
  # Input-- df: dataframe (User x Movie)
  #         pars: list(mu, gamma) parameters of cluster model
  # Output-- responsibilities Pi (User x Class)
  
  # Define Variables
  mu <- pars$mu
  gamma <- pars$gamma
  N <- nrow(df) # number of users
  M <- ncol(df) # number of movies 
  K <- dim(gamma)[3] # number of scores
  C <- dim(gamma)[1] # number of classes  
  
  # Compute pi
  I <- array(0, c(N,M,K)) # User x Movie x Score
  phi <- matrix(0, N, C) # User x Class  
  for (k in seq(K)) {
    I[,,k] <- ifelse((df!=k|is.na(df)),0,1)
    phi <- phi + I[,,k]%*%t(log(gamma[,,k]))
  }
  phi <- exp(phi) #phi <- exp(mpfr(phi))  #exp(-745.13)==0 False; exp(-745.14)==0 True
  w <- phi*rep(mu, each=N) # User x Class
  w[w==0] <- min(w[w!=0])
  Pi <- w/rowSums(w) # User x Class
  return(Pi)
}
########## END cluster.pi ##########
####################################################################################################
