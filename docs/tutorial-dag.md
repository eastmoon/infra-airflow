# DAG ( Directed Acyclic Graph )

+ [範例程式](../dags/tutorial_dag.py)

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
airflow dags backfill <DAG id> \
    --start-date <YYYY-MM-DD> \
    --end-date <YYYY-MM-DD>
```
