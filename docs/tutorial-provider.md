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

而依據上述文獻中 Provider 結構的描述，不同的 Provider 會提供不同的內容，但總體可分為下列四類。

### [Hook](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/connections.html)

+ [Airflow Hooks Explained 101: A Complete Guide](https://hevodata.com/learn/airflow-hooks/)
+ [Airflow hooks](https://docs.astronomer.io/learn/what-is-a-hook)

Hook 是一種擴增服務提供的通訊物件，常用於需要通訊的擴增服務，如 S3、Docker，在透過 UI 介面定義好的通訊資訊後，DAG 可以藉由定義時填寫的 HOOK_ID 來取回通訊物件，並藉由其提供的操作進行通訊以取回資訊；在運用上，Hook 所在的任務 ( Task ) 多半本身不作為通訊操作，而是在其運作流程中透過 Hook 進行通訊操作。

### [Operators](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/operators.html)

+ [101 Guide on Apache Airflow Operators](https://censius.ai/blogs/apache-airflow-operators-guide)

Operator 是 AirFlow 中創建任務的生成函數，在 AirFlow 系統中有諸多用於系統操作、檔案操作的 Operator，這些生成物件會將操作行為隱含在其中；因此，用於擴展功能的 Provider 也會提供隱含其操作的 Operator 來生成任務單元。

### [Sensors](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/sensors.html)

+ [Airflow Sensors : What you need to know](https://marclamberti.com/blog/airflow-sensors/)

Sensor 是一種在指定執行區間內，有條件執行的 Operator，常用於指定時間內檢查是否可以通訊，倘若條件失敗，在時間內仍會繼續嘗試連線；對於連線不穩定或需要等待時間的遠端服務來說，會以此種方式來避免因為一次性連線異常導致處理失敗。

### [Transfers](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/operators/transfer/index.html)

+ [Generic Airflow Transfers made easy](https://medium.com/apache-airflow/5fe8e5e7d2c2)

Transfer 是一種用來讓來源與目標間的資料傳輸的 Operator，會提供此類 Operator 的 Provider 主要是雲端存儲相關的服務，如 GCP、S3、HIVE。


### [Decorator](https://airflow.apache.org/docs/apache-airflow/stable/howto/create-custom-decorator.html)

有些 Provider 會提供裝飾函數，以便在 TaskFlow 中使用，其用途相似 Operators，但其用途應是使用裝飾的函數其內容是要直接引用到 Provider 內。
