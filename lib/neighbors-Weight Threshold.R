#####select neighbors by Weight Threshold######
get_neighbors<-function(per_weight,threshold){
  neighbors_id<-names(per_weight[per_weight>threshold])
  return(neighbors_id)
}