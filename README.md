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
In this project, we implemented several collaborative filtering algorithm based on two datasets:
[1]Microsoft Website(implicit): user database with 4151 users and 269 websites, recording whether a user visited a website or not by binary 0-1;
[2]Each Movie(explicit): user database with 5055 users and 1619 movies, recording uses's votes if exist, which range from 1 to 5.
Goal: Evaulating the result of recommendation by [1]Memory-Based Algorithm, combined with several methods in calculating similarity weights, selecting neighbors by setting threshold, rating normalization to get the expected utility of the ranked list for implicit and MAE for explicit data and [2]Model-Based Algorithm, xxxxxxx.
	
**Contribution statement**: ([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

+ Ji, Hanying: Mainly took responsibility of Memory-Based Algorithm with MingMing, Liu. Focused on implicit Microsoft website dataset and wrote funtions for [1]reshaping data(transfer_1,transfer_1_test);[2]calculating similarity weight of pearson and spearman correlation(simweight);[3]selecting neighbors by weighting threshold and calculate coverage(get_neighbors_index);[4]predicting scores by scaling/no scaling(pred_1);[5]evaluating different combinations of methods by ranked list score(ranked_score).Collaborated with Zhang, Yiyi in writing the main.Rmd file.

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
