setwd("/Users/JHY/Documents/2018SpringCourse/Applied Data Science/Spring2018-Project4-group-10")

########read data########
load("./output/train_data1.RData")
train_data1[is.na(train_data1)]<-0
load("./output/train_data2.RData")



weights_pearson_data1 <- cor(t(train_data1),t(train_data1),method="pearson")
weight_pearson_data2 <- cor(t(train_data2),t(train_data2),method="pearson")


#####calculate z score#####
z_score<-function(data,weight,neighbors){
  n_users<-nrow(data)
  n_items<-ncol(data)
  data_mean<-matrix(rep(rowMeans(data),n_items),nrow=n_users,ncol=n_items)
  rownames(data_mean)<-rownames(data)
  colnames(data_mean)<-colnames(data)
  for(i in 1:n_users){
    neighbors<-get_neighbors(weight[i,],threshold)
    k<-1/sum(weight[i,neighbors])
    weightsum_neighbors_score<-k*weight[i,neighbors]%*%(data[neighbors,]-data_mean[neighbors,])
    data_mean[i,]<-data_mean[i,]+weightsum_neighbors_score
  }
  z_score<-data_mean
  return(z_score)
}
