# 群組化 ( Groups )

+ [TaskGroups](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html#taskgroups)
    - [範例程式 - taskgroups](../dags/tutorial_taskgroup.py)
+ [SubDAGs](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html#subdags)
    - [範例程式 - SubDAG-main](../dags/tutorial_subdag_main.py)
    - [範例程式 - SubDAG-sub](../dags/tutorial_subdag_sub.py)
+ [TaskGroups vs SubDAGs](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html#taskgroups-vs-subdags)

在 AirFlow 文獻中，雖然有提到如何複用任務 ( Task )，但除了任務外，工作流複用也是有其需要，例如與伺服器認證資訊、提取數據、匯出報告等流程，往往不會是單一任務，而是較為繁瑣的工作流；對此，AirFlow 提供了兩個方式 TaskGroups 與 SubDAGs。

+ TaskGroups
TaskGroups 顧名思義是任務群組化，參考文獻與範例程式，在設計需使用 ```task_group``` 便可在其函數內宣告任務並設計流程。

+ SubDAGs
SubDAGs 顧名思義是子 DAG，也可看成副流程，透過 ```SubDagOperator``` 物件來間接運行 SubDAG 運作，但在設計上有一些細節導致若使用 TaskFlow 撰寫並不容易，且在目前版本，測試腳本時會出現 **This class is deprecated**，並建議使用 TaskGroups。

對於這兩著比較，官方文獻有以下描述：

+ SubDagOperator 使用 Backfill 工作執行，這會導致忽略平行運行的設定
+ SubDAGs 可擁有自己的屬性，當 SubDAGs 的屬性與 ParentDAG 不同時，會導致無法預期的錯誤
+ 無法透過 DAG 的圖像來呈現所有流程中任務的關係，對於 SubDAGs 需要進入其中才可以觀察流程與狀態
+ SubDAGs 設計有各種細節需要注意，在開發與用戶體驗上並不良善

從文獻的建議與實驗來看，SubDAGs 在實務相對繁瑣且要注意設定差異，且諸多資訊必需透過參數傳遞，一個失誤便可能導致執行異常；且相較之下，TaskGroups 還能沿用 TaskFlow 的設計方式來已程式化的方案逐次抽象化工作與利用物件導向來規劃整體程式運作。
