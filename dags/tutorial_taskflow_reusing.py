# [START import_module]
## Python tools library
from datetime import datetime

## Airflow core library
from airflow.decorators import dag, task
# [END import_module]

# [START declare_task]
@task
def add_task(x, y):
    print(f"Task args: x={x}, y={y}")
    return x + y
# [END declare_task]

# [START declare_dag]
@dag(dag_id = "reusing_dag_1", start_date=datetime(2022, 1, 1))
def mydag1():
    start = add_task.override(task_id="start")(1, 2)
    for i in range(3):
        start >> add_task.override(task_id=f"add_start_{i}")(i, i+1)

@dag(dag_id = "reusing_dag_2", start_date=datetime(2022, 1, 1))
def mydag2():
    start = add_task(1, 2)
    for i in range(3):
        start >> add_task.override(task_id=f"new_add_task_{i}")(i, i+2)
# [END declare_dag]

# [START instantiate_dag]
mydag1()
mydag2()
# [END instantiate_dag]
