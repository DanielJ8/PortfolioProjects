🛍️ Customer Segmentation using RFM and K-Means Clustering
This project performs customer segmentation for a UK-based online retailer using RFM analysis (Recency, Frequency, Monetary) and K-Means clustering. The goal is to group customers based on purchasing behavior to enable targeted marketing strategies.

📊 Problem Statement
Businesses often have thousands of customers with varying purchasing behaviors. Identifying high-value, loyal, or inactive customers helps tailor campaigns, promotions, and customer retention efforts. This project leverages RFM metrics and unsupervised learning to segment the customer base into actionable groups.

🔧 Methodology 
1. Data Cleaning & Preprocessing
  Loaded data from online_retail_II.xlsx

  Removed:
  
  Rows with missing CustomerID
  
  Canceled orders (Invoice starts with 'C')
  
  Invalid StockCode and Invoice formats
  
  Zero or negative Quantity and Price entries

2. Feature Engineering
  Calculated SalesLineTotal = Quantity × Price
  
  Computed RFM metrics:
  
  Recency: Days since last purchase
  
  Frequency: Unique invoice count
  
  Monetary: Total spend

3. Outlier Detection
  Used IQR method to detect and isolate extreme values in Monetary and Frequency
  
  Outliers were retained and analyzed separately, recognizing their business value

4. Data Scaling
  Scaled features using StandardScaler to normalize value ranges before clustering

5. K-Means Clustering
  Used Elbow Method and Silhouette Score to determine optimal k=4 for non-outliers
  
  Applied K-Means clustering and labeled clusters

6. Outlier Grouping
  Grouped outliers manually into:
  
  High Monetary only → PAMPER
  
  High Frequency only → UPSELL
  
  Both → DELIGHT

📌 Customer Segments
| Cluster | Segment Name | Characteristics       | Strategy                              |
| ------- | ------------ | --------------------- | ------------------------------------- |
| 0       | RE-ENGAGE    | Low M, Low F, High R  | Reactivate with win-back campaigns    |
| 1       | RETAIN       | Mid M, Mid F, Mid R   | Loyalty programs, personalized offers |
| 2       | REWARD       | High M, High F, Low R | Premium rewards, VIP treatment        |
| 3       | NURTURE      | Low M, Low F, Low R   | Educate and nurture growth            |
| -1      | PAMPER       | High M, low F         | Luxury/seasonal targeting             |
| -2      | UPSELL       | High F, low M         | Product bundling, cross-sells         |
| -3      | DELIGHT      | High M & F            | Hyper-personalized VIP offers         |


📈 Visualizations
  3D scatter plot of RFM clusters
  
  Violin plots for feature distributions
  
  Bar charts of customer counts and average RFM values per segment

🛠️ Tech Stack
  Python (Pandas, NumPy, Scikit-learn, Matplotlib, Seaborn)
  
  Jupyter Notebook
  
  Excel (Data source)

📚 Dataset
online_retail_II.xlsx from UCI Repository
