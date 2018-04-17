## Rank Score
rank_score <- function(predicted_test,true_test){
  ## function to calculate rank score of predicted value
  ## input: predicted_test - predicted value matrix of test data
  ##        true_test - test data matrix
  ## output: rank score
  d <- 0.02
  rank_mat_pred <- ncol(predicted_test)+1-t(apply(predicted_test,1,function(x){return(rank(x,ties.method = 'first'))}))
  rank_mat_test <- ncol(true_test)+1-t(apply(true_test,1,function(x){return(rank(x,ties.method = 'first'))}))
  vec = ifelse(true_test - d > 0, true_test - d, 0)
  R_a <- apply(1/(2^((rank_mat_pred-1)/4)) * vec,1,sum)
  R_a_max <- apply(1/(2^((rank_mat_test-1)/4)) * vec,1,sum)
  
  R <- 100*sum(R_a)/sum(R_a_max)
  return(R)
}

## ROC
evaluation.roc <- function(roc_value, mat, mat.true){
  mat.criterion <- matrix(roc_value, nrow = nrow(mat), ncol = ncol(mat))
  same_num <- sum((mat >= mat.criterion) == (mat.true >= mat.criterion), na.rm=TRUE)
  n <- sum(!is.na(mat))
  return(same_num/n)
}

## MAE
evaluation.mae <- function(pred.val, true.val){
  ## function to calculate mean absolute error of predicted value
  ## Input: pred.val - predicted value
  ##        true.val - test data matrix
  ## Output: MAE
  mae <- mean(abs(pred.val - true.val), na.rm = T)
  return(mae)
}

