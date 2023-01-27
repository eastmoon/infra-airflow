# [START import_module]
## Python tools library
import pendulum

## Airflow core library
from airflow import DAG
from tutorial_common_task import add_task
# [END import_module]

# [START declare_subdag_function]
def subdag(parent_dag_name, child_dag_name, args) -> DAG:
    """
    Generate a DAG to be used as a subdag.

    :param str parent_dag_name: Id of the parent DAG
    :param str child_dag_name: Id of the child DAG
    :param dict args: Default arguments to provide to the subdag
    :return: DAG to use as a subdag
    """
    dag_subdag = DAG(
        dag_id=f"{parent_dag_name}.{child_dag_name}",
        default_args=args,
        start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
        catchup=False,
        schedule="@daily",
    )

    for i in range(5):
        add_task.override(task_id=f"{child_dag_name}_task_{i}", dag=dag_subdag, default_args=args)(i, i + 1)

    return dag_subdag
# [END declare_subdag_function]
