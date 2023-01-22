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

# [START execute_dynamic_dag]
config = [("dynamic_dag_1", 1, 2), ("dynamic_dag_2", 3, 4)]
for dag_name, dag_input_1, dag_input_2 in config:

    # [START declare_dag]
    @dag(dag_id = dag_name, start_date=datetime(2021, 1, 1))
    def dag_template():
        start = add_task.override(task_id="start")(dag_input_1, dag_input_2)
    # [END declare_dag]

    # [START instantiate_dag]
    dag_template()
    # [END instantiate_dag]
# [END execute_dynamic_dag]
