# [START import_module]
## Python tools library
from datetime import datetime

## Airflow core library
from airflow.decorators import dag, task_group
from tutorial_taskflow_reusing import add_task
# [END import_module]

# [START declare_taskgroup]
@task_group
def demo_group():
    """This docstring will become the tooltip for the TaskGroup."""
    task1 = add_task.override(task_id=f"add_task_1")(1, 2)
    task2 = add_task.override(task_id=f"add_task_2")(3, 4)

    task1 >> task2
# [END declare_taskgroup]

# [START declare_dag]
@dag(dag_id = "tutorial-TaskFlow-taskgroup", start_date=datetime(2022, 1, 1))
def use_taskgroup():
    start = add_task.override(task_id=f"start")(0, 1)
    end = add_task.override(task_id=f"end")(0, 1)

    start >> demo_group() >> end
# [END declare_dag]

# [START instantiate_dag]
use_taskgroup()
# [END instantiate_dag]
