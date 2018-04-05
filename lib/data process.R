setwd("/Users/JHY/Documents/2018SpringCourse/Applied Data Science/Spring2018-Project4-group-10")
train_data_1<-read.csv("./data/MS_sample/data_train.csv")[,-1]
test_data_1<-read.csv("./data/MS_sample/data_test.csv")[,-1]

train_data_2<-read.csv("./data/eachmovie_sample/data_train.csv")[,-1]
test_data_2<-read.csv("./data/eachmovie_sample/data_test.csv")[,-1]

user_item_transfer_1<-function(data){
  user_id<-data[data$V1=="C",2]
  Vroot<-unique(data[data$V1=="V",2])
  user_item_1<-matrix(NA,nrow =length(user_id) ,ncol=length(Vroot))
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
train_data1<-user_item_transfer_1(train_data_1)
test_data1<-user_item_transfer_1(test_data_1)
save(train_data1,file="./output/train_data1.RData")
save(test_data1,file="./output/test_data1.RData")



user_item_transfer_2<-function(data){
  user_id<-unique(data$User)
  movie<-unique(data$Movie)
  default<-0
  user_item_2<-matrix(default,nrow =length(user_id) ,ncol=length(movie))
  rownames(user_item_2)<-user_id
  colnames(user_item_2)<-movie<-unique(data$Movie)
  for(i in 1:length(user_id)){
    movie_user_i<-data[data$User==user_id[i],"Movie"]
    score_user_i<-data[data$User==user_id[i],"Score"]
    user_item_2[i,which(movie%in%movie_user_i)]<-score_user_i
  }
  return(user_item_2)
}
train_data2<-user_item_transfer_2(train_data_2)
test_data2<-user_item_transfer_2(test_data_2)
save(train_data2,file="./output/train_data2.RData")
save(test_data2,file="./output/test_data2.RData")
