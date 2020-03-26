# Cluster-Analysis-for-Orthopedic-Materials-Sales
The objective of this study is to find ways to increase sales of orthopedic material from our company to hospitals in the United States.

### About the Data 

The data inlude 4000 hospital details. The columns are like :
- ZIP
- HID
- CITY
- STATE
- BEDS
- REHAB
and some more.


### Let's dig into it
The dataset is from all over the US but our products can sell only in NC and near by states of SC, VA, GA and TN. So first, we narrow down the dataset to the hospitals only in the required states.

Now, I *dropped some columns* like Zip, Hid, City, State, Trauma and Rehab as they are categorical variable where the value is discrete and it is not meaningful when calculating disctance.

Also, I *scaled down the data* we have a different range of scale in our variable and lareger scale will dominate how cluster will be defined. In this data, out-v is around million where on the other side max value in rbeds is 850 which is far less than out-v and hence out-v will dominate the clustering pattern and hence, scaling is the only solution.

After cleaning the data, lets work on the clustering models.

### CLustering models

#### **K- means**

I use "Within group SSE" to determine the number of clusters for k-means. Using the plot, we can use any value between 3-7 and according to me I choose k = 4 as my number of cluster.

![pic1](https://user-images.githubusercontent.com/13045656/77696105-3b07fe80-6f83-11ea-9b43-013b72d033a6.png)

Now, I will use the number of k I got from above graph and do ***K-means clustering*** on my data set.
The 2-D representation looks liek 

![pic2](https://user-images.githubusercontent.com/13045656/77696300-88846b80-6f83-11ea-893f-3aedfc0b03a8.png)

#### **Hierarchical clustering**

K-means is a very common clustering model but I wanted to try some other clustering models like Hierarchical clustering.
So, on the same data, I applied Hierarchical clustering with different modes and here is the representation :

![pic3](https://user-images.githubusercontent.com/13045656/77696473-d13c2480-6f83-11ea-9746-7aa20986fca4.png)

The different kind of modes in Hierarchical clustering is :
- single
- complete
- average
- ward D2

From all of these, I would prefer ward’s method as it seems more balanced than the other method. The objective of ward’s method is to minimise the within cluster SS. It is also better method in uncovering clusters of uneven physical sizes. 

Based on Hierarchical clustering, I found 3 clusters in the dataset on the base of the below dendogram. You can see red line cutting 3 lines seperately covering almost all of the datapoints, which is what I want.

![pic4](https://user-images.githubusercontent.com/13045656/77696699-2aa45380-6f84-11ea-951b-9d6d6ff4d37e.png)

#### **DBSCAN cluster analysis**

For using DBSCAN, first we need to determine minPts. The rule of thumb for minPts is the number of dimensions of the data + 1. For that, we will do PCA and find out the number of PCA that explains almost 85% of the variance in data. 
.

![pic5](https://user-images.githubusercontent.com/13045656/77698213-9edff680-6f86-11ea-9a07-3751d20d3a3d.png)

.

Now, looking at the Cumulative Proportiion for the PCA’s, I see that first four PCA is explaining the 89% variance of the data. Number of Dimension  = 4 and therefore, minPts = 4+1 = 5

After we have minPts, second thing we want to find out to do DBSCAN is eps and that one is find out from the plot of elbow curve.

![pic6](https://user-images.githubusercontent.com/13045656/77698713-773d5e00-6f87-11ea-8df1-53b8870362a3.png)

As we can see in the plot, the elbow is sharp at the value 4, and therefore I consider the value of eps = 4.

Now, it's the time to perform DBSCAN with eps and minPts that we have found above. 

![pic7](https://user-images.githubusercontent.com/13045656/77701131-f5036880-6f8b-11ea-8b94-730617b39d30.png)

we need to determine the cluster (based on pc_df) for each hospital where they belong. Then determine the value of "sales12","rbeds","hip12","knee12", and "femur12" for each cluster for each clustering method (e.g. k-means, hierarchical, DBSCAN). To do this, we need to run the following lines:

- pc_df$kmeans <- k.means.fit$cluster
- pc_df $hclust <- groups # these groups are created in hierarchical clustering
- pc_df $db <- db$cluster
- pc_df $hid <- nc_data$hid # Add hospital id to pc_df data
- final_data <- merge(x=pc_df, y=nc_data, key="hid")
- aggregate(final_data[,c("sales12","rbeds","hip12","knee12","femur12")], list(final_data$kmeans), mean)
- aggregate(final_data[,c("sales12","rbeds","hip12","knee12","femur12")], list(final_data$hclust), mean)
- aggregate(final_data[,c("sales12","rbeds","hip12","knee12","femur12")], list(final_data$db), mean)

I found reference of this from my Advanced Business Analytics course.

After running this, I use Sihouette to determine the quality of the respective clusters. 

![dbscan](https://user-images.githubusercontent.com/13045656/77701697-495b1800-6f8d-11ea-9614-66e9f3cbfd1d.png)
.
.
![kmeans](https://user-images.githubusercontent.com/13045656/77701699-49f3ae80-6f8d-11ea-87af-4e5245bff82e.png)
.
.
![hierar](https://user-images.githubusercontent.com/13045656/77701700-49f3ae80-6f8d-11ea-9d8a-72d4e856add4.png)
.
.
From the above plots I can see that the clusters that consists of maximum number of hospitals are:
- K-means: Cluster 1 424 out of 509
- Hierarchical: Cluster 1 474 out of 509
- DBSCAN: Cluster 1 463 out of 509
	
Looking at the aggregate of the above selected clusters in each method, we can clearly see that the cluster 1 in Hierarchical clustering method gives the highest values for sales12, rbeds, hip12, knee12, and femur12. Also, the average silhouette width is higher for hierarchical clustering (0.58) when compared to DBSCAN clustering (0.54). 

And that is how, we found our cluster to target for the orthopedic material sales.













































