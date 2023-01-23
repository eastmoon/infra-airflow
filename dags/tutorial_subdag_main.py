# [START import_module]
## Python tools library
from datetime import datetime

## Airflow core library
from airflow import DAG
from airflow.operators.subdag import SubDagOperator
from tutorial_taskflow_reusing import add_task
from tutorial_subdag_sub import subdag
# [END import_module]

# [START instantiate_dag]
DAG_NAME = "tutorial-subdag-main"
with DAG (
    dag_id = DAG_NAME,
    start_date=datetime(2022, 1, 1),
    schedule="@once",
    tags=["example"]
) as dag:
    start = add_task.override(task_id=f"start")(0, 1)
    section1 = SubDagOperator (
        task_id="section-1",
        subdag=subdag(DAG_NAME, "section-1", dag.default_args)
    )
    middle = add_task.override(task_id=f"middle")(1, 2)
    section2 = SubDagOperator (
        task_id="section-2",
        subdag=subdag(DAG_NAME, "section-2", dag.default_args)
    )
    end = add_task.override(task_id=f"end")(2, 3)

    start >> section1 >> middle >> section2 >> end
# [END instantiate_dag]
