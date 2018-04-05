setwd("/Users/JHY/Documents/2018SpringCourse/Applied Data Science/Spring2018-Project4-group-10")
load("./output/train_data1.RData")

weights_pearson <- cor(t(train_data1), method = "pearson")
