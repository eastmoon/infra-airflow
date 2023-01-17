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

## 安裝與執行

參考 [Installation](https://airflow.apache.org/docs/apache-airflow/stable/installation/index.html) 文件，安裝 Airflow 的必要環境是 Apache 與 Python，且安裝文件是基於 Linux 環境，若要運用於不同作業系統，則可考慮使用 [Docker 映像檔](https://airflow.apache.org/docs/docker-stack/index.html) 以服務方式啟動於作業系統。

+ 下載映象檔 [Docker hub - airflow](https://hub.docker.com/r/apache/airflow)

```
docker pull apache/airflow
```

+ 啟動服務

```
docker run -it --rm apache/airflow airflow standalone
```

在 Docker 中，```AIRFLOW_HOME``` 預設在 ```/opt/airflow``` 中，其中 DAG 目錄在 ```/opt/airflow/dags``` 而執行記錄在 ```/opt/airflow/logs```。

+ 使用命令介面 [Command Line Interface Reference](https://airflow.apache.org/docs/apache-airflow/stable/cli-and-env-variables-ref.html)

```
docker exec -ti <container name> airflow info
```

在文獻中，對於 Docker 的運用分為兩篇文獻，一篇是如上所述的 [Docker 命令](https://airflow.apache.org/docs/docker-stack/entrypoint.html#entrypoint-commands) 的操作，適用於開發模式，另一篇為[使用 Docker-Compose 建立分散式應用服務](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)，建議使用於產品模式，其主要理由是建議將運算負責的 Executor、管理負責的 Scheduler、介面操作的 Webserver、工作觸法執行的 Triggerer、Metadata 資料庫、緩存服務全部改為獨立的服務容器並分開運作避免單一容器的效率降低與資安風險增加。

不過，對於 Docker-Compose 的設計，Executor、Scheduler、Webserver、Triggerer 實際都是 airflow 容器，以相同容器與設定區分開來運作，並在容器啟動時分別透過命令介面 ```airflow webserver```、```airflow scheduler```、```airflow celery worker```、```airflow triggerer``` 來啟動容器對應的服務內容。

關於單體與分散式運作概念，可以參考以下文獻說明：

+ [Airflow documnet : Celery Executor](https://airflow.apache.org/docs/apache-airflow/stable/executor/celery.html#architecture)
+ [Airflow document : Quick Start](https://airflow.apache.org/docs/apache-airflow/stable/start.html)
+ [Airflow: what do `airflow webserver`, `airflow scheduler` and `airflow worker` exactly do?](https://stackoverflow.com/questions/51063151)
+ [Apache Airflow：工作流程管理控制台](https://tech.hahow.in/4dc8e6fc1a6a)

![Airflow 元件通訊示意圖](./docs/img/airflow-celery-executor.png)
> Reference : [How Apache Airflow Distributes Jobs on Celery workers](https://medium.com/sicara/54cb5212d405)

由上圖與文獻所述，Airflow 的啟動是需要透過命令介面執行不同命令來開啟相對應服務，在適用開發模式的單體容器 ( Standalone )，雖然使用 ```airflow standalone```，但實際上內部仍是呼叫多個命令工作，而在產品模式的分散式結構中，則是各容器各自執行命令，在透過 Metadata 資料庫、Redis 緩存來進行 DAG 狀態改變，從而觸發各服務的運作。

基於前述，本專案在安裝與啟動設計也區分為二，並依據需要建立如下對應命令介面：

#### 開發模式

```
airflow dev up
airflow dev down
airflow dev into
```

#### 產品模式

```
airflow prd up
airflow prd down
airflow prd cli -c="airflow info"
```
> 產品模式使用的[設定檔](https://airflow.apache.org/docs/apache-airflow/2.5.0/docker-compose.yaml)來源於官方文件並進行適度修改，例如關閉下載範例、調整目錄位置等。

## 設計

#### 基礎設計

在 Airflow 文獻 [Fundamental Concepts](https://airflow.apache.org/docs/apache-airflow/stable/tutorial/fundamentals.html) 中描述了 DAG 的基礎設計，其中要點區分如下：

+ Workflow as Code
Airflow 中的 DAG 是一種設定檔 ( Configuration )，類似於 DevOps 中常提的 IaC ( Infrastructure as Code / Infrastructure as Configuration )，這樣的設計概念是基於單一語言來規劃與設計一個提供給系統運作的設定檔，而設定的內容、區塊會最終成為系統運作的依據與運行內容。

+ 匯入模組 ( Importing Modules )
DAG 是個基於 Python 語言的設定檔程式，因此，設定過程則基於主要的核心模組 ```from airflow import DAG``` 以及任務相關模組 ```from airflow.operators.bash import BashOperator``` 來構成，此外則依據程式設計需要匯入需要的運算模組。

+ DAG 實體 ( Instantiate a DAG )
Airflow 的工作流是基於 DAG 設定，因此不同於其他框架是基於類別繼承來繁生實例類別後在產生實體物件，Airflow 則是基於 DAG 類別，透過參數設定來生成實體物件，而工作流中的任務 ( Task )、相依 ( Dependencies ) 則是在 DAG 實體產生後的區塊中設定。

+ 任務 ( Tasks )
若用 [Pipe & Filter](https://www.oreilly.com/library/view/software-architecture-with/9781786468529/ch08s04.html) 來解釋 Workflow，則 Pipe 就是 DAG，而 Filter 就是 Task，因此，在 DAG 要執行的實際內容便是 Task 的實體物件，詳細如何運用與建置 Task 於後設計範例說明。

+ Jinja 樣板 ( Jinja Templating )
Airflow 框架中已安裝 [Jinja](https://jinja.palletsprojects.com/) 套件，這是個基於 Python 語言的樣板套件，讓一段文字描述經過套件轉換成可用的文字、腳本，是早期的 SSR ( Server Side Render ) 技術，但也常運用於產生電子書；Airflow 則是可用此套件來產生如 DAG、Task 的說明文、BashOperator 的執行腳本，可以預期也可以用來產生動態的報告等用途。

+ 設定相依 ( Setting up Dependencies )
若 Workflow 中是 DAG 工作的宣告與定義，Task 是工作要執行的內容，Dependencies 便是整個工作的流程定義，原則上 DAG 是無循環的圖，也因此各 Task 只需管理其 Downstream 與 Upstream 為何 Task，其詳細寫法可參考[文獻](https://docs.astronomer.io/learn/managing-dependencies)。

+ 除錯 ( Debug )
在 Airflow 開發模式時，可以進入容器內使用 Python 指令來確認腳本的正常與否，倘若程式本身無誤則不會顯示任何內容。
```
# 進入容器
airflow.bat dev into
# 除錯
python <DAG filename>
```

+ 驗證 ( Validation )
在 Airflow 中，若完成的 DAG 放置在 ```${AIRFLOW_HOME}/dags``` 則可以透過 Airflow 的命令介面驗證此服務內容。
```
# 顯示啟動的 DAG
airflow dags list
# 顯示指定 DAG 的 Task 清單
airflow tasks list <DAG id>
# 顯示指定 DAG 的 Task 樹狀結構
airflow tasks list <DAG id> --tree
```

+ 測試 ( Testing )
在 Airflow 中，可以透過命令介面測試指定 DAG 的指定 TASK 運行，```airflow tasks test <DAG id> <Task id> < (Optional) date>```，是否要加入時間視測試需要而定。

+ 回填 ( Backfill )
在 Airflow 中，測試屬於直接執行但並不會留存任何狀態於 Metadata 資料庫中，若要實際檢測，則需使用 Backfill，若使用此指令，則會實際讓 DAG 掛載後執行，並可在 Webserver 的介面中觀察執行進度
```
airflow dags backfill <DAG id \
    --start-date <YYYY-MM-DD> \
    --end-date <YYYY-MM-DD>
```

## 文獻

+ [Airflow Document](https://airflow.apache.org/docs/)
    - [Overview](https://airflow.apache.org/docs/apache-airflow/stable/index.html)
    - [Architecture Overview](https://airflow.apache.org/docs/apache-airflow/stable/concepts/overview.html)
        + [Concepts](https://airflow.apache.org/docs/apache-airflow/stable/concepts/index.html)
    - [Quick Start](https://airflow.apache.org/docs/apache-airflow/stable/start.html)
        + [Installation](https://airflow.apache.org/docs/apache-airflow/stable/installation/index.html)
+ Docker
    - [apache/airflow](https://hub.docker.com/r/apache/airflow)
    - [docker](https://hub.docker.com/_/docker)
    - [r-base](https://hub.docker.com/_/r-base)
    - [tensorflow](https://www.tensorflow.org/install/docker?hl=zh-tw)
    - [scikit-learn-intel](https://hub.docker.com/r/bitnami/scikit-learn-intel)
    - [pytorch](https://hub.docker.com/r/pytorch/pytorch)
