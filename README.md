# Multimodal Sub-City Real-Estate Forecasting

This repository contains the full codebase used in our study on multimodal forecasting of real-estate price dynamics. It includes data preparation modules, modeling notebooks, ablation experiments, and result generation scripts.

The goal of this release is to provide a transparent, reproducible pipeline for reviewers and researchers.

---

## 1. Environment Setup

The project was developed using Python 3.12.
All code runs in .ipynb
Common libraries used, and assumed already available in the kernel or install commands provided. 

---

## 2. Repository Structure

    /
    │
    ├── 1-transaction-data/          # Preprocessing scripts and transaction features
    ├── 2-sentiment-data/            # Text pipelines and sentiment feature construction
    ├── 3-satellite-data/            # SAR/NDBI pipelines and spatial feature generation
    ├── 4-interest-rate-data/        # Macroeconomic interest-rate feature processing
    │
    ├── experiments/                 # Saved experiment outputs (metrics, configs, logs)
    ├── parameter_search/            # Hyperparameter search runs used for model selection
    │
    ├── 0_data_prep_validate.ipynb   # Creates cached feature space required by all models
    │
    ├── 1_model_naive_mean.ipynb     # Baseline model (naive mean)
    ├── 2_model_ridge.ipynb          # Ridge regression
    ├── 3_model_knn.ipynb            # KNN nonparametric model
    ├── 4_model_lstm.ipynb           # LSTM sequence model
    ├── 5_model_rf.ipynb             # Random Forest model
    ├── 6_model_xgboost.ipynb        # XGBoost model
    ├── 7_model_arima.ipynb          # ARIMA model
    │
    ├── report_main_results.ipynb    # Generates all tables and figures used in the paper
    │
    ├── report_ablation_main.ipynb   
    ├── report_ablations_sentiment.ipynb    
    ├── report_ablations_satellite.ipynb    
    ├── report_out_of_sample_pred.ipynb   
    │
    ├── current_run.txt             
    │
    ├── extra                        # optional EDA material         
    │
    └── README.md

---

## 3. Reproducing Main Paper Results (Fast Path)

To reproduce all final figures and tables from the paper, run:

    report_main_results.ipynb

This notebook uses pre-computed experiment outputs stored under the experiments/ directory.  
Training is not required for this mode.

---

## 4. Running All Experiments From Scratch

To regenerate all experiment results from the raw preprocessed features, follow the steps below.

### Step 1 - Build cached feature space  
Before running any models, execute:

    0_data_prep_validate.ipynb

This notebook constructs and saves the cached feature matrices used by all model notebooks.  
The modeling pipeline will not function correctly without this step.

### Step 2 - Train and evaluate models  
Run the following notebooks *in order of preference or in parallel*:

1_model_naive_mean.ipynb  
2_model_ridge.ipynb  
3_model_knn.ipynb  
4_model_lstm.ipynb  
5_model_rf.ipynb  
6_model_xgboost.ipynb
7_model_arima.ipynb

Each notebook:

- Trains the corresponding model  
- Evaluates performance across all regions  
- Writes results into a new folder under experiments/  
- Updates metadata consumed by report_main_results.ipynb  

### Step 3 - Regenerate figures and tables

After completing all model notebooks, run:

    report_main_results.ipynb

This will regenerate all tables, summaries, and figures included in the paper.

---

## 5. Data Preparation Modules

This repository includes full pipelines for reconstructing all modalities used in the study.

### Transaction Data  
Directory: 1-transaction-data/  
Includes scripts for aggregating sub-city transactions, cleaning, and generating price/count features.

### Sentiment Data  
Directory: 2-sentiment-data/  
Contains preprocessing pipelines for text retrieval and sentiment scoring.

### Satellite (SAR/NDBI) Data  
Directory: 3-satellite-data/  
Includes instructions and scripts for downloading raw Sentinel-1 data, mosaicking, clipping, and computing spatial indices.

### Interest Rate Data  
Directory: 4-interest-rate-data/  
Scripts for producing macro-financial interest-rate indicators.

Each module provides its own explanation of preprocessing steps.

---

## 6. Parameter Search

The parameter_search/ directory contains:

- Hyperparameter exploration logs  
- Metrics and configuration files  
- Parameter sweeps used to select final model settings  

Running parameter search is optional and does not affect other parts of the code.  
The final experiment settings were selected based on this search.

---

## 7. Citation

If you use this repository in your work, please cite:

    [Citation will be added upon publication]
    [Pre-print availabe: https://arxiv.org/abs/2602.18572]

---

## 8. Contact

For questions or issues, please contact:

    baris.arat@ozu.edu.tr
