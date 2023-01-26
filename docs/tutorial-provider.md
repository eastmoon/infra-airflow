# 供應者 ( Provider )

+ [Providers](https://airflow.apache.org/docs/apache-airflow-providers/)
+ [Providers packages references](https://airflow.apache.org/docs/apache-airflow-providers/packages-ref.html)

在 AirFlow 2.0 其架構採用模組化設計，因此除了核心 ( Core ) 系統外，還有諸多額外的供應者 ( Provider ) 以插件架構的型式來擴增整個 AirFlow 的系統功能；而從前述的 Providers 清單中，可以看出其主要提供的是對外部第三方軟體的操作封裝，其中主要有雲端存儲服務、RMDB 或 NoSQL 資料庫服務、資料傳輸協定服務、社群服務網站等，其設計目的是透過封裝對服務操作的腳本，來簡化 DAG 撰寫，將冗長的操作流程抽象化至提供參數即可運用的程度。

因此，在文件中對於 Provider 的擴增總結有以下用途：

+ Auth backends，以 Provider 針對特定需要授權的後端服務封裝
+ Custom connections，以 Provider 針對特定的通訊連結型態、行為進行封裝
+ Extra links，以 Provider 針對特定擴增連結進行封裝
+ Logging，以 Provider 對連線、操作行為流程定義額外的記錄封裝，以便日後追蹤問題
+ Secret backends，以 Provider 對需加密的隱私操作進行封裝

依據文獻所述，Apache 目前對 Providers 列表中多達 60 個項目持續進行維護，而此些項目皆可透過 ```pip install <provider-name>``` 方式下載。

但對於有客製需求的人，可以參考下列文件自行設計 Provider，並以 ```pip install -e /path/to/my-package``` 方式讓客製專案安裝。

+ [Community Providers](https://airflow.apache.org/docs/apache-airflow-providers/howto/create-update-providers.html)
    - [Airflow Sample Provider](https://github.com/astronomer/airflow-provider-sample)
