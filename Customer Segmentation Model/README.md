# 🛍️ Customer Segmentation using RFM and K-Means Clustering

This project performs customer segmentation for a UK-based online retailer using **RFM analysis** (Recency, Frequency, Monetary) and **K-Means clustering**. The goal is to group customers based on purchasing behavior to enable **targeted marketing strategies**.

---

## 📊 Problem Statement

Businesses often have thousands of customers with varying purchasing behaviors. Identifying high-value, loyal, or inactive customers helps tailor campaigns, promotions, and customer retention efforts. This project leverages **RFM metrics** and **unsupervised learning** to segment the customer base into actionable groups.

---

## 🔧 Methodology

### 1. Data Cleaning & Preprocessing
- Loaded data from `online_retail_II.xlsx`
- Removed:
  - Rows with missing `CustomerID`
  - Canceled orders (`Invoice` starts with 'C')
  - Invalid `StockCode` and `Invoice` formats
  - Transactions with zero or negative `Quantity` and `Price`

### 2. Feature Engineering
- Calculated `SalesLineTotal = Quantity × Price`
- Computed RFM metrics:
  - **Recency**: Days since last purchase
  - **Frequency**: Count of unique invoices
  - **Monetary**: Total spend per customer

### 3. Outlier Detection
- Detected outliers in **Monetary** and **Frequency** using the **IQR method**
- Separated outliers for **specialized analysis** instead of removal

### 4. Data Scaling
- Applied `StandardScaler` to normalize feature ranges before clustering

### 5. K-Means Clustering
- Used **Elbow Method** and **Silhouette Score** to select `k = 4` clusters
- Performed K-Means clustering on non-outlier data
- Assigned cluster labels for each customer

### 6. Outlier Grouping
Manually grouped high-value outliers into:
- **PAMPER** → High Monetary, low Frequency
- **UPSELL** → High Frequency, low Monetary
- **DELIGHT** → High in both Monetary and Frequency

---

## 📌 Customer Segments

| Cluster | Segment Name | Characteristics            | Strategy                            |
|---------|--------------|-----------------------------|-------------------------------------|
| 0       | RE-ENGAGE    | Low M, Low F, High R        | Reactivate with win-back campaigns |
| 1       | RETAIN       | Mid M, Mid F, Mid R         | Loyalty programs, personalized offers |
| 2       | REWARD       | High M, High F, Low R       | Premium rewards, VIP treatment     |
| 3       | NURTURE      | Low M, Low F, Low R         | Educate and nurture growth         |
| -1      | PAMPER       | High M, Low F               | Luxury/seasonal targeting          |
| -2      | UPSELL       | High F, Low M               | Product bundling, cross-sells      |
| -3      | DELIGHT      | High M, High F              | Hyper-personalized VIP offers      |

---

## 📈 Visualizations

- 3D Scatter Plot of RFM Clusters  
- Violin Plots for R, F, M Distributions  
- Bar Charts of Customer Counts & Average RFM per Segment  

---

## 🛠️ Tech Stack

- Python: `Pandas`, `NumPy`, `Scikit-learn`, `Matplotlib`, `Seaborn`  
- Jupyter Notebook  
- Excel (Data Source)

---

## 📚 Dataset

Dataset: [`online_retail_II.xlsx`](https://archive.ics.uci.edu/ml/datasets/online+retail+ii)  
Source: UCI Machine Learning Repository

---

