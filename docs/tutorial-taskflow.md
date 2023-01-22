# 任務流 ( TaskFlow )

+ [範例程式 - 基礎宣告](../dags/tutorial-taskflow.py)
+ [範例程式 - 複用函數](../dags/tutorial-taskflow-reusing.py)
+ [範例程式 - 引用複用函數](../dags/tutorial-taskflow-reusing.py)
+ [範例程式 - 動態 DAG 宣告與執行](../dags/tutorial-taskflow-reusing.py)
    - [Naming Airflow dags other then the python callable when using taskflow api](https://stackoverflow.com/questions/70270658)

在 Airflow 文獻 [Working with TaskFlow](https://airflow.apache.org/docs/apache-airflow/stable/tutorial/taskflow.html) 中描述了以 Dag 與 Task 的裝飾函數 ( [decorated function](https://realpython.com/primer-on-python-decorators/) ) 構成的函數導向程式設計，其中要點區分如下：

+ 裝飾函數 ( decorated function )
所謂裝飾函數是[Decorator Pattern](https://zh.wikipedia.org/zh-tw/%E4%BF%AE%E9%A5%B0%E6%A8%A1%E5%BC%8F)的函數化，其用途是在執行既有函數前執行一另外一個函數或行為，以此做到擴增既有函數行為的設計模式；在 TaskFlow 中則會使用 Dag 與 Task 兩個裝飾函數，以此產生 DAG 與 Task 物件。
```
@dag(
    ...
)
def tutorial_taskflow_api():
    @task()
      def extract():
```

+ 主流程 ( Main flow )
既然採用函數化設計，在流程管理也自然會以此方式建置，相比 DAG 物件中的導向符號 ```>>``` 或 ```Downstream``` 函數，在 TaskFlow 中的寫法很接近一般函數執行，利用回傳物件作為串接的流程的方式。
```
order_data = extract()
order_summary = transform(order_data)
load(order_summary["total_order_value"])
```
而其中對於 DAG 的執行，更是直接執行 ```tutorial_taskflow_api``` 函數來啟動流程。

+ Jinja 樣板 ( Jinja Templating )
不同於 DAG 定義，若要使用 Jinja 樣板來導入說明要使用 ```<task>.doc_md = <Jinja>``` 來指定，在此則是於函數的前段宣告，TaskFlow 會將其視為 ```doc_md``` 變數匯入。
```
@task()
def transform(order_data_dict: dict):
    """
    #### Transform task
    A simple Transform task which takes in the collection of order data and
    computes the total order value.
    """
    ...
```

+ 複用函數 ( Reusing function )
函數化設計其優勢是可以利用事前宣告，讓不同的 DAG 可以共用相同的函數來做到相同的動作，以此減少重複性程式並提高維護效率，相關範例參考前述範例程式；需要注意 ```<task function>.override( ... )```，透過這個函數可以改寫或補充對 Task 的設定，但此函數並不存在於 Dag 的裝飾函數，因此 Dag 的設定屬於不可動態修改，若有要動態產生 Dag 則可參考前述的動態宣告與執行方式。

+ 複雜 Python 環境相依 ( complex/conflicting Python dependencies )
在 Airflow 的架構中，每個任務都是獨立執行在 Worker 中，因此在執行任務時可依據需要引用不同的 Python 環境庫。
```
# 宣告要執行的環境，並匯入需要的相依庫 requirements
@task.virtualenv( task_id="virtualenv_python", requirements=["colorama==0.4.0"], system_site_packages=False )
def callable_virtualenv():

# 宣告要執行的環境，並引用已經封裝好的 Python 環境
@task.external_python(task_id="external_python", python=PATH_TO_PYTHON_BINARY)
def callable_external_python():
```
在相依環境中還有 ```task.docker``` 與 ```task.kubernetes```，但文件說明中提到在 airflow 2.2、2.4 版本後這兩個功能已經被移除，改由 provider 替代。

+ 多重輸出 ( Multiple outputs )
在 TaskFlow 中若函數回應為複數內容，如 dict 物件，則透過函數宣告，會自動偵測並將 ```multiple_outputs``` 設為 true；此數值本身可自行設定於 task 宣告中，但若自行設定，則自動偵測將會關閉。
```
@task
def identity_dict(x: int, y: int) -> dict[str, int]:
    return {"x": x, "y": y}
```

+ 相依於傳統任務
在原理上，TaskFlow 中使用 Task 裝飾函數宣告的函數執行後，實際會生成任務物件，這與 BashOperator 或 FileSensor 等傳統任務產生的物件應為相同的基礎物件，因此可以透過 TaskFlow 的相依方式建立流程。
```
# 宣告任務
@task()
def extract_from_file():
    ...

# 建立任務物件
file_task = FileSensor(task_id="check_file", filepath="/tmp/order_data.csv")
order_data = extract_from_file()

# 建立工作流
file_task >> order_data
```
