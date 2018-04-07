##### data transform #####
## For MS data
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


##### similarity weighting #####
simweight<-function(data,cor_method){
  weight_mat <- matrix(NA,nrow=nrow(data),ncol=nrow(data))
  rownames(weight_mat)<-rownames(data)
  colnames(weight_mat)<-rownames(data)
  if(sum(is.na(data))==0){
    weight_mat<-cor(t(data),t(data),method=cor_method)
  }
  else{
    for(i in 1:nrow(data)){
      weight_mat[i,]<-apply(data,1,function(x){
        both_voted_index<-(!is.na(x))&(!is.na(data[i,]))#items that user a and i both vote
        if(sum(both_voted_index)==0){#no common item
          return(0)#cor is zero
        }
        else{
          return(cor(data[i,index],x[index],method=cor_method))
        }
      })
    }
  }
  return(weight_mat)
}

##### neighbor selection by weight threshold #####
get_neighbors_index<-function(sim_weight,threshold=0.5){
  neighbors_by_threshold<-vector("list",nrow(sim_weight))
  names(neighbors_by_threshold)<-rownames(sim_weight)
  user_id_cover<-c()
  for(i in 1:nrow(sim_weight)){
    neighbors_by_threshold[[i]]<-names(which((abs(sim_weight[i,])>threshold) & (sim_weight[i,]!=1)))#whose absolute cor weight larger than threshold(exclude user itself)
    if(sum(neighbors_by_threshold[[i]] %in% user_id_cover)<length(neighbors_by_threshold[[i]])){#some of this user's neighbors are not in coverage
      user_id_cover <- c(user_id_cover,neighbors_by_threshold[[i]][which(!(neighbors_by_threshold[[i]] %in% user_id_cover))])
    }
  }
  coverage<-length(user_id_cover)
  return(list(top.neighbors=neighbors_by_threshold,coverage_num=coverage))
}

##### Produce a prediction #####
## For MS data
pred_1<-function(train,test,sim_weight,top.neighbors){
  #Assumption: All users rate on approximately the same distribution
  #the differences in spread between users' rating distributions by coverting rates to z-scores and computing a weighted average of the z-scores
  #dev_method:  az: average z-score;    adm: average deviation from mean
  pred.mat<-matrix(0,nrow=nrow(test),ncol=ncol(test))
  rownames(pred.mat)<-rownames(test)
  colnames(pred.mat)<-colnames(test)
  for(a in 1:nrow(test)){
    mean_user_a<-mean(train[rownames(train)==rownames(test)[a],])
    sd_user_a<-sd(train[rownames(train)==rownames(test)[a],])
    i<-colnames(test)[colnames(test)%in%names(which(train[rownames(train)==rownames(test)[a],]==0))]#item_id which a haven't score yet but in the test data
    a_neighbors<-top.neighbors[[which(names(top.neighbors)==rownames(test)[a])]]
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
    weight_a_neighbor<-sim_weight[rownames(sim_weight)==rownames(test)[a], a_neighbors]
    numerator<-weight_a_neighbor%*%z_score
    denominator<-sum(weight_a_neighbor)
    for(j in 1:length(i)){
      pred.mat[a,colnames(pred.mat)==i[j]]<-(mean_user_a+sd_user_a*(numerator/denominator))[j]
    }
  }
  return(pred.mat)
}

##### Evaluation #####
## For MS data
# precision & recall
function(predict,test,rank_precentage_threshold)

# 

  

