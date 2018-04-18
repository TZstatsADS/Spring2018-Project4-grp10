# Project4: Collaborative Filtering

### Output folder

The output directory contains analysis output, processed datasets, logs, or other processed things.
+ **Model-Based Method (Cluster Model)**:  
  + [`CM.error.validation.RData`](CM.error.validation.RData): contains validation errors 
  + [`CM.pars.RData`](CM.pars.RData): contains parameters used in CM
  + [`CM.est.RData`](CM.est.RData): contains CM score estimation   
+ **Memory-Based Algorithms**:  
  + [`pearson_score.RData`](pearson_score.RData): contains ranked score for dataset1 using pearson correlation
  + [`pearson_score_noweighted.RData`](pearson_score_noweighted.RData): contains ranked score for dataset1 using pearson correlation(no weighted z-score)
  + [`spearman_score.RData`](spearman_score.RData): contains ranked score for dataset1 using spearman correlation
  + [`spearman_score_noweighted.RData`](spearman_score_noweighted.RData): contains ranked score for dataset1 using spearman correlation(no weighted z_score)
  + [`var_pear_score.RData`](var_pear_score.RData): contains ranked score for dataset1 using pearson correlation+variance weighting
  + [`var_pear_score_noweighted.RData`](var_pear_score_noweighted.RData): contains ranked score for dataset1 using pearson correlation+variance weighting(no weighted z_score)
  + [`simrank_score.RData`](simrank_score.RData): contains ranked score for dataset1 using simrank correlation
  + [`simrank_score_noweighted.RData`](simrank_score_noweighted.RData): contains ranked score for dataset1 using simrank(no weighted z-score)
