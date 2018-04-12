#For MS
transfer_1<-function(data){
  user_id<-data[data$V1=="C",2]
  Vroot<-unique(data[data$V1=="V",2])
  user_item_1<-matrix(0,nrow =length(user_id) ,ncol=length(Vroot))
  user_id_index<-which(data$V1=="C")
  user_id_index<-c(user_id_index,nrow(data)+1)
  for(i in 1:(length(user_id))){
    Vroot_user_i<-data[(user_id_index[i]+1):(user_id_index[i+1]-1),"V2"]
    user_item_1[i,which(Vroot%in%Vroot_user_i)]<-1
  }
  rownames(user_item_1)<-user_id
  colnames(user_item_1)<-Vroot
  return(user_item_1)
}


transfer_1_test<-function(data,train){
  user_id<-data[data$V1=="C",2]
  Vroot<-colnames(train)
  user_id_index<-which(data$V1=="C")
  user_id_index<-c(user_id_index,nrow(data)+1)
  user_item_1_test<-matrix(0,nrow=length(user_id),ncol=ncol(train))
  for(i in 1:length(user_id)){
    Vroot_user_i<-data[(user_id_index[i]+1):(user_id_index[i+1]-1),"V2"]
    user_item_1_test[i,which(Vroot%in%Vroot_user_i)]<-1
  }
  rownames(user_item_1_test)<-as.character(user_id)
  colnames(user_item_1_test)<-Vroot
  return(user_item_1_test)
}



## For Movie data
transfer_2<-function(data){
  user_id<-unique(data$User)
  movie<-unique(data$Movie)
  default<-0
  user_item_2<-matrix(default,nrow =length(user_id) ,ncol=length(movie))
  rownames(user_item_2)<-user_id
  colnames(user_item_2)<-movie
  for(i in 1:length(user_id)){
    movie_user_i<-data[data$User==user_id[i],"Movie"]
    score_user_i<-data[data$User==user_id[i],"Score"]
    user_item_2[i,which(movie%in%movie_user_i)]<-score_user_i
  }
  return(user_item_2)
}
###other method
#train_data2 <- acast(train_mv,User~Movie,value.var="Score")
#test_data2 <- acast(test_mv,User~Movie,value.var="Score")






##### similarity weighting #####
#simweight<-function(data,cor_method){
#  weight_mat <- matrix(NA,nrow=nrow(data),ncol=nrow(data))
#  rownames(weight_mat)<-rownames(data)
#  colnames(weight_mat)<-rownames(data)
#  if(sum(is.na(data))==0){
#    weight_mat<-cor(t(data),t(data),method=cor_method)
#   }
#   else{
#     for(i in 1:nrow(data)){
#       weight_mat[i,]<-apply(data,1,function(x){
#         both_voted_index<-(!is.na(x))&(!is.na(data[i,]))#items that user a and i both vote
#         if(sum(both_voted_index)==0){#no common item
#           return(0)#cor is zero
#         }
#         else{
#           return(cor(data[i,index],x[index],method=cor_method))
#         }
#       })
#     }
#   }
#   return(weight_mat)
# }

simweight<-function(data,cor_method){
  weight_mat <- matrix(NA,nrow=nrow(data),ncol=nrow(data))
  weight_mat<-cor(t(data),use = "pairwise.complete.obs", method=cor_method)
  return(weight_mat)
}

######fill in NA
rmna <- function(data,train_data){
  n <- nrow(data)
  loc <- which(is.na(data))
  for (i in loc){
    a <- (i%/%n + 1)
    b <- i%%n
    x <- which(!is.na(train_data[a,]))
    y <- which(!is.na(train_data[b,]))
    x__y <- intersect(x,y)
    #print(x__y)
    if (length(x__y)< 1){
      data[a,b] <- 0
    }
    else{
      x_y <- union(x,y)
      datax <- train_data[c(a,b),x_y]
      datax[1,is.na(datax[1,])] <- mean(datax[1,],na.rm=T)
      datax[2,is.na(datax[2,])] <- mean(datax[2,],na.rm=T)
      corr <- cor(t(datax),method ="pearson")
      cor <- corr[1,2]
      data[a,b] <- cor
      #print(cor)
      rm(a,b,datax)
    }
  }
  return(data)
}



##### variance weighting #####
var_weight <- function(data,method){ 
  data <- train_data2[,-1]  
  data <- matrix(as.numeric(data),nrow=nrow(data))
  variance <- apply(data,2,var,na.rm=T)
  maxv <- max(variance,na.rm=T)
  minv <- min(variance,na.rm=T)
  v <- (variance-minv)/maxv
  datav <- t(data)*v^0.5 
  var_cor <- cor(datav,use="pairwise.complete.obs",method=method)
  return(var_cor)
}


##### neighbor selection by weight threshold #####
get_neighbors_index<-function(sim_weight,threshold=0.5){
  neighbors_by_threshold<-vector("list",nrow(sim_weight))
  names(neighbors_by_threshold)<-rownames(sim_weight)
  user_id_cover<-c()
  for(i in 1:nrow(sim_weight)){
    neighbors_by_threshold[[i]]<-colnames(sim_weight)[(abs(sim_weight[i,])>threshold) & (sim_weight[i,]!=1)]#whose absolute cor weight larger than threshold(exclude user itself)
    if(sum(neighbors_by_threshold[[i]] %in% user_id_cover)<length(neighbors_by_threshold[[i]])){#some of this user's neighbors are not in coverage
      user_id_cover <- c(user_id_cover,neighbors_by_threshold[[i]][which(!(neighbors_by_threshold[[i]] %in% user_id_cover))])
    }
  }
  coverage_pre<-length(user_id_cover)/nrow(sim_weight)
  return(list(top.neighbors=neighbors_by_threshold,coverage_pre=coverage_pre))
}

##### simrank
simrank <- function(train_data, iter=6, c=0.8){
  n <- nrow(train_data)
  m <- ncol(train_data)
  I_u <- apply(train_data,1,sum)
  I_w <- apply(t(train_data),1,sum)
  i_u <- train_data/I_u
  i_w <- t(train_data)/I_w
  #calculate the weighting
  weight_user <- matrix(0,nrow=n,ncol=n)
  weight_net <- matrix(0,nrow=m,ncol=m)
  weight_useru <- cbind(weight_user,i_u)
  weight_netw <- cbind(i_w,weight_net)
  weight_all <- rbind(weight_useru,weight_netw)
  ####weighting function for nodes
  R <- matrix(0,nrow=m+n,ncol=m+n)
  for (i in 1:iter){
    Rold <- R
    R <- c*(weight_all%*%Rold%*%t(weight_all))
    diag(R) <- 1
  }
  R_final <- R[1:n,1:n]
  rownames(R_final) <- rownames(train_data)
  colnames(R_final) <- rownames(train_data)
  return(list(R_final))
}

##### Produce a prediction #####
## For MS data(only to active user)
pred_1<-function(train,test,sim_weight,top.neighbors){
  #Assumption: All users rate on approximately the same distribution
  #the differences in spread between users' rating distributions by coverting rates to z-scores and computing a weighted average of the z-scores
  #dev_method:  az: average z-score;    adm: average deviation from mean
  pred.mat<-matrix(0,nrow=nrow(test),ncol=ncol(train))
  rownames(pred.mat)<-rownames(test)
  colnames(pred.mat)<-colnames(train)
  for(a in 1:nrow(test)){
    mean_user_a<-mean(train[rownames(test)[a],])
    sd_user_a<-sd(train[rownames(test)[a],])
    #i<-colnames(test)[colnames(test)%in%names(which(train[rownames(train)==rownames(test)[a],]==0))]#item_id which a haven't score yet but in the test data
    #i<-colnames(train)[which(train[a,]!=1)]  #the index of item a didn't go before and need to predict
    a_neighbors<-top.neighbors[[rownames(test)[a]]]
    neighbors_score<-train[a_neighbors,]
    if(length(a_neighbors)<=1){
      if(length(a_neighbors)==0){
        pred.mat[a,]<-0#if a has no neighbor, then pred score is zero
        break
      }
      else{
        sd<-sd(neighbors_score)
        neighbors_score<-t(neighbors_score)
      }
    }
    else{
      sd<-apply(neighbors_score,1,sd)
    }
    z_score<-(1/sd)*(neighbors_score-rowMeans(neighbors_score))
    weight_a_neighbor<-sim_weight[rownames(test)[a],a_neighbors]
    numerator<-weight_a_neighbor%*%z_score
    denominator<-sum(weight_a_neighbor)
    pred.mat[a,]<-(mean_user_a+sd_user_a*(numerator/denominator))
    pred.mat[a,which(train[rownames(test)[a],]==1)]<-0#for those a had already scores,we predict them as 0
  }
  return(pred.mat)
}

##For movie data
pred_2 <- function(train_data,test_data,cor){
  test_data <- matrix(as.numeric(test_data),nrow=nrow(test_data))
  n <- nrow(test_data)
  m <- ncol(test_data)
  test_user <- rownames(test_data)
  rownames(test_data) <- c(1:n)
  test_index <- apply(!is.na(test_data),1,which)
  user_mean <- rowMeans(test_data,na.rm=T)
  rownames(cor) <- c(1:nrow(train_data))
  colnames(cor) <- c(1:nrow(train_data))
  data <- matrix(as.numeric(train_data),nrow=nrow(train_data))
  scale_data <- scale(data,center=T,scale=T)
  rownames(scale_data) <- c(1:nrow(train_data))
  variance <- apply(data,2,var,na.rm=T)
  user_var <- apply(data,1,var,na.rm=T)
  pred.matrix <- matrix(NA,nrow=n,ncol=m)
  for (a in 1:n){
    for (i in test_index[[a]]){
      pred.matrix[a,i] <- user_mean[a]+(sum(scale_data[,i]*cor[a,],na.rm=T)*sqrt(user_var[a])/sum(cor[a,]*(!is.na(scale_data[,i])),na.rm=T))
    }
  }
  return(prediction= pred.matrix)
}


#Evaluation for MS data
# expected utility of ranked list
rank_score <- function(predict,test){
  d <- 0
  alpha<-10
  #predict<-predict[rownames(predict)%in%rownames(test),]#colnames(predict)%in%colnames(test)
  rank_mat_pred <- ncol(predict)+1-t(apply(predict,1,function(x){return(rank(x,ties.method = 'first'))}))
  rank_mat_test <- ncol(test)+1-t(apply(test,1,function(x){return(rank(x,ties.method = 'first'))}))
  vec_pred <- ifelse(predict - d > 0, predict - d, 0)
  vec_test <- ifelse(test - d > 0, test - d, 0)
  R_a <- apply(1/(2^((rank_mat_pred-1)/(alpha-1))) * vec_pred,1,sum)
  R_a_max <- apply(1/(2^((rank_mat_test-1)/(alpha-1))) * vec_test,1,sum)
  R <- 100*sum(R_a)/sum(R_a_max)
  return(R)
}


