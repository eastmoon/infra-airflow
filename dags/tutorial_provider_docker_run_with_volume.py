# [START import_module]
## Python tools library
from datetime import datetime
from docker.types import Mount

## Airflow core library
from airflow.models import Variable
from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from airflow.providers.docker.operators.docker import DockerOperator
# [END import_module]

# [START declare_dag]
@dag(
    "tutorial-provider-docker-run-with-voulme",
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
    t1 = BashOperator(task_id="create-tmpfile", bash_command="echo 'hello world!!' >> /var/local/docker/tmp")
    t2 = BashOperator(task_id="call-docker-run-with-bash", bash_command="docker run --rm -v /var/local/docker:/tmp2 bash -c 'ls -al /tmp2'")
    t3 = DockerOperator(
        task_id="call-docker-run-with-docker",
        docker_url=Variable.get("DOCKER_HOST"),
        tls_ca_cert=Variable.get("DOCKER_CRET_CA"),
        tls_client_cert=Variable.get("DOCKER_CLIENT_CERT"),
        tls_client_key=Variable.get("DOCKER_CLIENT_KEY"),
        command="ls -al /tmp2",
        image="bash",
        auto_remove="success",
        mount_tmp_dir=False,
        mounts=[
            Mount(
                source='/var/local/docker',
                target='/tmp2',
                type='bind'
            )
        ],
    )

    t1 >> t2 >> t3
    # [END instantiate_task AND dependencies_task]

# [START instantiate_dag]
tutorial_taskflow_api()
# [END instantiate_dag]
