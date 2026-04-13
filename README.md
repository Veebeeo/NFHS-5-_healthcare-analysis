# 🇮🇳 India Healthcare Analytics & Predictive Modeling (NFHS-5)

![Power BI](https://img.shields.io/badge/PowerBI-F2C811?style=for-the-badge&logo=Power%20BI&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Machine Learning](https://img.shields.io/badge/Machine%20Learning-FF6F00?style=for-the-badge&logo=scikit-learn&logoColor=white)

> An end-to-end Data Science and Business Intelligence project analyzing the National Family Health Survey (NFHS-5) data across 707 Indian districts to identify critical healthcare vulnerabilities and recommend data-driven policy interventions.

<img src="" width="100%" alt="Dashboard Hero Image">

## Project Overview
Despite massive improvements in maternal healthcare access—such as reaching a 90%+ institutional delivery rate—India continues to battle severe pediatric nutrition and systemic anaemia crises. 

This project bridges the gap between raw government health data and actionable public policy. By designing a complete data pipeline from **SQL-based data engineering** to **Machine Learning risk prediction**, this dashboard uncovers the hidden socio-economic determinants of health and flags critical districts for immediate intervention.

**Key Objectives:**
- **Examine the "Access Paradox":** Prove that high hospital delivery rates do not automatically guarantee positive pediatric nutritional outcomes.
- **Track the Anaemia Crisis:** Map the severity of anaemia across different demographics (children, pregnant women, and non-pregnant women).
- **Deploy Predictive Analytics:** Utilize Unsupervised (K-Means) and Supervised (XGBoost) Machine Learning to cluster health environments and rank the most critical predictors of child stunting.
- **Drive Policy Action:** Provide interactive, DAX-driven smart narratives that generate custom intervention strategies based on selected regions.

---

## Tech Stack & Architecture

**Data Engineering & Storage**
* **PostgreSQL:** Acted as the central data warehouse. Wrote custom SQL scripts to handle relational mapping, create optimized views (`vw_maternal_health`, `vw_child_nutrition`), and calculate initial composite health scores.
* **PgAdmin 4:** Database management and query execution.

**Exploratory Data Analysis (EDA) & Machine Learning**
* **Python 3:** Core language for scripting and modeling.
* **Pandas & NumPy:** Extensive data cleaning, handling missing government data, and feature engineering.
* **Scikit-Learn (K-Means):** Unsupervised clustering to group districts into 4 distinct health profiles based on infrastructure and medical access.
* **XGBoost & SHAP:** Supervised gradient boosting model to predict child stunting rates and extract feature importance (identifying Women's Education as the #1 predictor).

**Business Intelligence & UI**
* **Power BI:** Designed a 6-page interactive dashboard.
* **DAX:** Wrote dynamic, context-aware measures to create a customized "Smart Narrative" text generator that updates based on user filter selections without relying on premium features.
* **Power Query / Data Modeling:** Final data transformations, establishing a star-schema, and managing Many-to-Many relationship bypasses for geographical data quirks.

---

##  The Data Pipeline
1. **Extraction:** Ingested raw NFHS-5 survey data (707 districts, 100+ health indicators).
2. **Transformation (Python):** Cleaned null values, standardized naming conventions across states, and generated geospatial TopoJSON files for mapping.
3. **Loading (SQL):** Loaded structured data into a local PostgreSQL database. Built specific views to isolate maternal, pediatric, and infrastructure data.
4. **Modeling (Python):** Ran K-Means and XGBoost algorithms, exporting the predictions and feature importance back into the data model.
5. **Visualization (Power BI):** Connected directly to the PostgreSQL database, resolved complex cardinality issues, and deployed interactive UI/UX features including a custom navigation app-bar.

---

## 📊 Dashboard Architecture & Key Insights

The Power BI dashboard is divided into 6 interactive pages, guiding the user from a high-level national overview down to specific, data-driven policy recommendations.

### Page 1: Executive Summary
* **Features:** A custom TopoJSON "Hero Map" of India detailing Composite Health Scores by district, alongside dynamic KPI cards and Top/Bottom 10 filtering.
* **Functionality:** Acts as the main landing page, establishing the baseline geographical divide in healthcare outcomes.

### Page 2: Maternal & Child Health
* **Insight (The Access Paradox):** A scatter plot proves that while national institutional delivery rates have reached 90%+, this medical access has not successfully curbed pediatric malnutrition. 
* **Features:** Includes a Maternal Care Funnel Chart highlighting the severe drop-off in postnatal care retention.

### Page 3: The Anaemia Crisis
* **Insight:** Anaemia is a systemic crisis, not an isolated one. In several states, it affects over 60% of children, 55% of pregnant women, and 50% of non-pregnant women simultaneously.
* **Features:** A demographic cascade chart and a "Red Zone" matrix filtering the absolute worst-hit districts for immediate dietary intervention.

### Page 4: Social Determinants & Historical Trends
* **Insight (The "Social Vaccine"):** A trendline scatter plot conclusively demonstrates that as the percentage of women with 10+ years of schooling increases, child stunting drops dramatically (correlation of -0.59).
* **Features:** Clustered bar charts tracking district-level progress (or regression) between the NFHS-4 (2015-16) and NFHS-5 (2019-21) surveys.

### Page 5: Predictive Analytics (ML Insights)
* **XGBoost Feature Importance:** The supervised ML model visualization identifies *Women's Education* and *Basic Sanitation* as stronger predictors of pediatric health than direct medical interventions.
* **K-Means Clustering:** An unsupervised 100% stacked bar chart categorizes all 707 districts into 4 distinct health profiles, highlighting infrastructure gaps.

### Page 6: Strategic Interventions
* **Features:** A custom UI "App Navigation" bar and a **Dynamic DAX-driven Smart Narrative**.
* **Functionality:** The dashboard reads the user's active slicer selections and automatically generates a written, text-based paragraph recommending specific policy actions for that exact state or region.

---

## Repository Structure

```text
├── data/                   # Raw and processed NFHS-5 datasets, TopoJSON files
├── sql/                    # PostgreSQL scripts for schema, tables, and views
│   ├── 01_create_tables.sql
│   └── 02_create_views.sql
├── notebooks/              # Python EDA and Machine Learning pipelines
│   ├── 01_data_cleaning.ipynb
│   ├── 02_exploratory_analysis.ipynb
│   └── 03_ml_modeling.ipynb
├── dashboard/              # Power BI files and exported PDFs
│   ├── NFHS5_Healthcare_Dashboard.pbix
│   └── Dashboard_Screenshots/
└── README.md               # Project documentation
```

##  How to Run This Project

### 1. Database Setup
* Install PostgreSQL and PgAdmin 4 (or your preferred SQL client).
* Create a new local database (e.g., `nfhs_db`).
* Run the SQL scripts located in the `/sql/` folder sequentially to build the schema, import the raw data CSVs, and generate the reporting views.

### 2. Python Environment & Machine Learning
* Clone this repository to your local machine:
  ```bash
  git clone [https://github.com/Veebeeo/NFHS-5-_healthcare-analysis.git](https://github.com/Veebeeo/NFHS-5-_healthcare-analysis.git)
  ```
* Navigate to the project repository and install the required dependencies
```bash
pip install pandas numpy scikit-learn matplotlib xgboost seaborn
```
* Run the Jupyter Notebooks in the /notebooks/ directory to reproduce the exploratory data analysis, K-Means clustering, and XGBoost models.

### 3. Power BI and DashBoard Setup
* Download and install Power BI Desktop (Free version).

* Open the dashboard/NFHS5_Healthcare_Dashboard.pbix file.

* If the visuals do not load immediately, go to Home -> Transform Data -> Data source settings and update the PostgreSQL credentials to point to your local database instance.

* Click Refresh on the Home ribbon to pull in the live data and interact with the dashboard.

  





