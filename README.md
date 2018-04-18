
# Project 4: Collaborative Filtering

### [Project Description](doc/project4_desc.md)

Term: Spring 2018

+ Team #10
+ Projec title: Collaborative Filtering
+ Team members
	+ Dong, Jiaqi
	+ Ji, Hanying
	+ Liu, Mingming
	+ Zhang, Yiyi
+ Project summary: 
In this project, We have examined two classes of collaborative filtering algorithms, i.e., the model-based algorithm (cluster model) and the memory-based algorithms. The algorithms have been evaluated for both the implicity and the explicity voting databases as follows:

	+ Data Set 1 Microsoft Web Data: an implicity dataset with 4,151 users and 269 websites that captures individual visits to various areas in the Microsoft corporate website, recording whether a user visited a website or not by binary 0-1. 
	+ Data Set 2 EachMovie, an explicity dataset with 5,055 users and 1,619 movies that captures individual ratings ranged in value from 1 to 6 on various movies.  

In addition to implementing the memory-based algorithm (with Pearson or Spearman correlation, with and without variance weighting, and selecting neighbours) to both datasets, we have implemented SimRank to Data Set 1 and the model-based algorithm (cluster model) to Data Set 2. To compare the predictive accuracy of the various methods, we have applied ranked scoring and mean absolute error (MAE) to Data Set 1 and Data Set 2 respectively. As results shown, the SimRank correlation has outperformed other correlation for Data Set 1 and the Memory-Based Model (with pearson correlation, threshold=0.2) has outperformed the Cluster Model. The Variance Weighting has improved the performance for Data Set 1, while has lowered the performance for Data Set 2. The best threshold is 0.2 for both datasets.

[**`main.Rmd`**](doc/main.Rmd)/[**`main.nb.html`**](doc/main.nb.html): project report   
[**`ads_project4_group10.pptx`**](doc/ads_project4_group10.pptx): presentation slides    

![image](figs/3.png)

![image](figs/2.png)

![image](figs/1.png)

**Contribution statement**:  
+ Jiaqi, Dong: [1] Write up the Evaluation functions. [2] Write up the table_function. [3] Construct the evaluation part in the main.Rmd file. [4] Do the prediction and evaluate the MAE score of spearman method.  

+ Ji, Hanying: Mainly took responsibility of Memory-Based Algorithm with Liu, MingMing. Focused on implicit Microsoft website dataset and wrote funtions for [1]reshaping data(transfer_1,transfer_1_test);[2]calculating similarity weight of pearson and spearman correlation(simweight);[3]selecting neighbors by weighting threshold and calculate coverage(get_neighbors_index);[4]predicting scores by scaling/no scaling(pred_1);[5]evaluating different combinations of methods by ranked list score(ranked_score). Collaborated with Zhang, Yiyi in writing the main.Rmd file.  

+ Liu, Mingming: Presenter in this project. Mainly responsible for Memory-Based Algorithm with Ji, Hanying. Foucused on explicit Movie dataset and wrote functions for \n[1] reshaping data2; [2] calculating pearson correlation, spearman correlation, simrank and vaiance weighting correlation; [3] replacing NA with numbers in each correlation; [4] writing prediction function for dataset2 by scaling/ no scaling; [5] evaluating different combinations of methods by MAE score; [6] designing ppt.  

+ Yiyi, Zhang: Built and implemented the Cluster Model to Data Set 2. Constructed the notebook structure and wrote ToC, Introduction, Step 1&2, and the cluster model part of Step 3 in the main.Rmd file. Downloaded the datasets and reference papers, and organized the repository including the READMEs. 

 PS: Some similiarity weighting matrix is too large and can't be upload to github so we upload it to google drive. The link is:
 https://drive.google.com/drive/folders/1iWA7Y9CbPxi3Ryml_B-eXpTQsQ7G1RYx?usp=sharing
 
 Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
