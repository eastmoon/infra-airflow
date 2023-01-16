# Airflow

**Apache Airflow是用於數據工程管道的開源工作流管理平台。它於2014年10月在Airbnb開始，作為管理公司日益複雜的工作流程的解決方案。通過創建Airflow，Airbnb可以通過編程方式編寫和計劃其工作流程，並通過內置的Airflow用戶界面進行監控。**
> [Apache Airflow wiki](https://en.wikipedia.org/wiki/Apache_Airflow)

Airflow 是一套用於開發、排程、監控批次處理工作流的開源軟體，其基於 Python 的延展框架令開發者可建置所需的工作流來串接各類技術與服務，監控面則基於 Web 介面來協助管理工作流狀態。

Airflow 的工作流是一套基於 Python 定義的工作流，稱為 Workflows as Code ( WaC )，其設計目的：
+ 動態化 ( Dynamic )：利用 Python 語言設計的工作流可以動態規劃流程，讓流程非固定階段與商業邏輯的規劃
+ 擴展性 ( Extensible )：Airflow 框架提供對各類技術服務提的操作元，任何 Airflow 的元件可輕易傳接服務至所需的流程環境
+ 靈活性 ( Flexible )：工作流運用 [Jinja](https://jinja.palletsprojects.com/en/3.1.x/) 模板來實踐流程參數化設計

## 架構

在 Airflow 中，工作流 ( Workflow ) 等同 [DAG](https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html) ( Directed Acyclic Graph ) ，其中包括數個個體工作單元 [Tasks](https://airflow.apache.org/docs/apache-airflow/stable/concepts/tasks.html)，DAG 負責描述 Tasks 間的依賴關係與執行順序，Tasks 則描述自身該做什麼，例如提取資料、分析數據等。

在 Airflow 安裝後，其服務包括一下單元：

+ [Scheduler](https://airflow.apache.org/docs/apache-airflow/stable/concepts/scheduler.html)，主要負責觸發排程中的工作流與提交任務給執行者運行
+ [Executor](https://airflow.apache.org/docs/apache-airflow/stable/executor/index.html)，負責任務的執行者，在預設中 Airflow 的執行是在 Scheduler 中，但在生產或產品環境中，多將任務交給 Worker 執行
+ Webserver，主要負責提供使用者介面來檢視、觸發與除錯 DAG 和 Tasks 的行為
+ DAG 目錄，DAG 檔案存放目錄以提供 Scheduler 與 Executor 讀取並執行
+ Metadata 資料庫，提供 Scheduler、Executor、Webserver 做狀態存儲

![軟體架構示意圖](./docs/img/arch-diag-basic.png)

## 安裝

## 設計

## 文獻

+ [Airflow Document](https://airflow.apache.org/docs/)
    - [Overview](https://airflow.apache.org/docs/apache-airflow/stable/index.html)
    - [Architecture Overview](https://airflow.apache.org/docs/apache-airflow/stable/concepts/overview.html)
    - [Quick Start](https://airflow.apache.org/docs/apache-airflow/stable/start.html)
+ Docker
    - [apache/airflow](https://hub.docker.com/r/apache/airflow)
    - [docker](https://hub.docker.com/_/docker)
    - [r-base](https://hub.docker.com/_/r-base)
    - [tensorflow](https://www.tensorflow.org/install/docker?hl=zh-tw)
    - [scikit-learn-intel](https://hub.docker.com/r/bitnami/scikit-learn-intel)
    - [pytorch](https://hub.docker.com/r/pytorch/pytorch)
