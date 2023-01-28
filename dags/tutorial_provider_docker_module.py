# [START import_module]
## Python tools library
from datetime import datetime
from docker import APIClient, tls
from docker.constants import DEFAULT_TIMEOUT_SECONDS

## Airflow core library
from airflow.models import Variable
from airflow.decorators import dag, task
from airflow.providers.docker.hooks.docker import DockerHook

##
import logging
task_logger = logging.getLogger('airflow.task')
# [END import_module]

# [START declare_dag]
@dag(
    "tutorial-provider-docker-module",
    schedule=None,
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=["example", "docker"],
)
# [END declare_dag]
def tutorial_taskflow_api():
    """
    TaskFlow API for Docker Provider - run with docker module
    """

    # [START declare_task]
    @task
    def call_docker_hook():
        # Create tls object
        tls_config = tls.TLSConfig(
            ca_cert=Variable.get("DOCKER_CRET_CA"),
            client_cert=(Variable.get("DOCKER_CLIENT_CERT"), Variable.get("DOCKER_CLIENT_KEY")),
            verify=True,
        )

        client = APIClient(
            base_url=Variable.get("DOCKER_HOST"),
            tls=tls_config,
            version="auto",
            timeout=DEFAULT_TIMEOUT_SECONDS,
        )

        client.version()
        task_logger.info(client.version())

    # [END declare_task]

    # [START instantiate_task AND dependencies_task]
    call_docker_hook.override(task_id="call-docker-client")()
    # [END instantiate_task AND dependencies_task]

# [START instantiate_dag]
tutorial_taskflow_api()
# [END instantiate_dag]
