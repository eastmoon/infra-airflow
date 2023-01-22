# [START import_module]
## Python tools library
from datetime import datetime

## Airflow core library
from airflow.decorators import dag
from tutorial_taskflow_reusing import add_task
# [END import_module]

# [START declare_dag]
@dag(dag_id = "reusing_dag_from_import_task", start_date=datetime(2022, 1, 1))
def use_add_task():
    start = add_task.override(priority_weight=3)(1, 2)
    for i in range(3):
        start >> add_task.override(task_id=f"new_add_task_{i}", retries=4)(start, i)
# [END declare_dag]

# [START instantiate_dag]
use_add_task()
# [END instantiate_dag]
