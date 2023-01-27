# [START import_module]

## Airflow core library
from airflow.decorators import task
# [END import_module]

# [START declare_task]
@task
def add_task(x, y):
    print(f"Task args: x={x}, y={y}")
    return x + y
# [END declare_task]
