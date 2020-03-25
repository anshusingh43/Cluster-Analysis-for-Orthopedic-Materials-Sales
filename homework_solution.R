install.packages("data.table")
library("data.table")
setwd("C:/Users/anshu/Desktop/UNCC Courses/Advanced Business Analytics/Homework3")
data <- fread("hospital_ortho.csv", sep=",", header=T, strip.white = T, na.strings = c("NA","NaN","","?"))
data

nc_data <- data[(data$state == "NC") | (data$state == "SC") | (data$state == "VA") | (data$state == "GA") | (data$state == "TN")]
nc_data

#nc_data <- drop(data$zip,data$hid,data$city,data$state,data$th,data$trauma,data$rehab)

nc_data <- subset(nc_data, select = -c(zip,hid,city,state,th,trauma,rehab))#dropped this column
nc_data

nc_data<- scale(nc_data)#scaling
nc_data

install.packages("cluster")
install.packages("clustertend")
install.packages("dbscan")

library("cluster")
library("clustertend")
library("dbscan")

#find the number of clusters
withinssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}

withinssplot(nc_data, nc=10)  

k.means.fit <- kmeans(nc_data, 4)

library(cluster)
clusplot(nc_data, k.means.fit$cluster, main='2D representation of the Cluster solution', color=TRUE, shade=TRUE, labels=2, lines=0)

k.means.fit$size

#--------------------------------------------------------------------------

#Hierarchical clustering

HC_data <- dist(nc_data, method = "euclidean")

H.single <- hclust(HC_data, method="single")
plot(H.single)

H.complete <- hclust(HC_data, method="complete")
plot(H.complete)

H.average <- hclust(HC_data, method="average")
plot(H.average)

H.ward <- hclust(HC_data, method="ward.D2")
plot(H.ward)

par(mfrow=c(2,2))#change plot area and include all the plot in one single view
plot(H.single)
plot(H.complete)
plot(H.average)
plot(H.ward)

par(mfrow=c(1,1))
groups <- cutree(H.ward, k=3)
plot(H.ward)
rect.hclust(H.ward, k=3, border="red") 


#-------------------------------------------------------

#DBSCAN 
df <- nc_data
pca <- prcomp(df, center = TRUE, scale. = TRUE) 
print(pca)
summary(pca)

library(dbscan)
kNNdistplot(df,k=5)#to find the eps, we plot the elbow curve
abline(h=4,col="red")

db <- dbscan(df, eps=4, minPts=5)
db

db$cluster

clusplot(df, db$cluster, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)

pca_data <- predict(pca, newdata = nc_data)
pc_df <- as.data.frame(scale(pca_data[,c(1:4)]))#4 is the number of PC I recommended above  
  
#--------------------------------------------------------------------

#again doing K-mean using 4 PC
withinssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}


withinssplot(pc_df, nc=15)  

k.means.fit <- kmeans(pc_df, 4)

library(cluster)
clusplot(nc_data, k.means.fit$cluster, main='2D representation of the Cluster solution', color=TRUE, shade=TRUE, labels=2, lines=0)

k.means.fit$size

#-------------------------------------------------

#repeating now for heirarchical clusters

HC_data_new <- dist(pc_df, method = "euclidean")

H.single <- hclust(HC_data_new, method="single")
plot(H.single)

H.complete <- hclust(HC_data_new, method="complete")
plot(H.complete)

H.average <- hclust(HC_data_new, method="average")
plot(H.average)

H.ward <- hclust(HC_data_new, method="ward.D2")
plot(H.ward)

groups <- cutree(H.ward, k=4)
plot(H.ward)
rect.hclust(H.ward, k=4, border="red") 

#-------------------------------------------------

#PCA again


#DBSCAN 
pc_df
df_new <- pc_df
pca <- prcomp(df_new, center = TRUE, scale. = TRUE) 
print(pca)
summary(pca)

library(dbscan)
kNNdistplot(pc_df,k=3)#cause PCA1+PCA3 = 90% so mtry = 2+1 to find the eps, we plot the elbow curve
abline(h=1.5,col="red")

db <- dbscan(pc_df, eps=1, minPts=3)
db

db$cluster

clusplot(pc_df, db$cluster, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)



#---------------------------------------------

#LAST QUESTION

pc_df$kmeans <- k.means.fit$cluster
groups <- cutree(H.ward,k=3)
pc_df $hclust <- groups # these groups are created in hierarchical clustering
pc_df $db <- db$cluster
pc_df $hid <- nc_data$hid # Add hospital id to pc_df data
final_data <- merge(x=pc_df, y=nc_data, key="hid")
aggregate(final_data[,c("sales12","rbeds","hip12","knee12","femur12")], list(final_data$kmeans), mean)
aggregate(final_data[,c("sales12","rbeds","hip12","knee12","femur12")], list(final_data$hclust), mean)
aggregate(final_data[,c("sales12","rbeds","hip12","knee12","femur12")], list(final_data$db), mean)


plot(silhouette(k.means.fit$cluster, HC_data_new))
plot(silhouette(groups, HC_data_new))
plot(silhouette(db$cluster, HC_data_new))


