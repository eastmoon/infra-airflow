# [START import_module]
## Python tools library
from datetime import datetime

## Airflow core library
from airflow.models import Variable
from airflow.decorators import dag
from airflow.providers.docker.operators.docker import DockerOperator
# [END import_module]

# [START declare_dag]
@dag(
    "tutorial-provider-docker-run",
    schedule=None,
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=["example", "docker"],
)
# [END declare_dag]
def tutorial_taskflow_api():
    """
    TaskFlow API for Docker Provider - run with DockerOperator
    """

    # [START declare_task]
    # [END declare_task]

    # [START instantiate_task AND dependencies_task]
    t = DockerOperator(
        task_id="call-docker-run",
        docker_url=Variable.get("DOCKER_HOST"),
        tls_ca_cert=Variable.get("DOCKER_CRET_CA"),
        tls_client_cert=Variable.get("DOCKER_CLIENT_CERT"),
        tls_client_key=Variable.get("DOCKER_CLIENT_KEY"),
        command="ls -al /",
        image="bash",
        auto_remove="success",
    )
    # [END instantiate_task AND dependencies_task]

# [START instantiate_dag]
tutorial_taskflow_api()
# [END instantiate_dag]
