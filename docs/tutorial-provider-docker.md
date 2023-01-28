# Docker 供應者 ( Docker Provider )

+ [apache-airflow-providers-docker](https://airflow.apache.org/docs/apache-airflow-providers-docker/stable/index.html)
+ [example - github](https://github.com/apache/airflow/tree/providers-docker/3.4.0/tests/system/providers/docker)
    - [Using Apache Airflow DockerOperator with Docker Compose](https://towardsdatascience.com/57d0217c8219)
+ [Docker in Docker](https://hub.docker.com/_/docker)

## 簡介

Docker 供應者是 Apache AirFlow 中的一個 Provider，其主要用途是讓 DAG 的任務可以用 docker 運行，讓執行環境保持乾淨，其中有幾個主要內容

+ ```@task.docker``` 裝飾函數
+ DockerHook
+ DockerOperator
+ DockerSwarmOperator

對於本專案所需研究的是，在此架構下如何運用 Docker 引入不同演算法容器，以避免套件安裝導致容器服務複雜化。

## 建立 Docker in Docker

由於本專案的開發與產品環境是採用 Dcoker 服務啟用 AirFlow，因此，需額外添加一個 Docker 服務啟用給當前的 AirFlow 使用；由於關於 Docker in Docker 有兩種方式，在此以 Docker:dind 的版本為主。

+ 建立憑證快取目錄
```
mkdir %cd%\cache\docker-crets\ca
mkdir %cd%\cache\docker-crets\client
```

+ 建立私有網路
```
docker network create --driver=bridge airflow-dev-network
```

+ 啟動 Docker 服務
```
docker run -d --rm ^
    --privileged ^
    -e DOCKER_TLS_CERTDIR=/certs ^
    -v %cd%\cache\docker-crets\ca:/certs/ca ^
    -v %cd%\cache\docker-crets\client:/certs/client ^
    --network airflow-dev-network ^
    --network-alias docker ^
    docker:dind
```

+ 啟動 AirFlow 並銜接 Docker 服務
```
docker run -d --rm ^
    -e DOCKER_HOST=tcp://docker:2376 ^
    -e DOCKER_CERT_PATH=/certs/client ^
    -e DOCKER_TLS_VERIFY=1 ^
    -v %cd%\cache\docker-crets\client:/certs/client:ro ^
    --network airflow-dev-network ^
    --network-alias airflow ^
    --name "devel-airflow" ^
    apache/airflow standalone
```

+ 進入 AirFlow 容器並檢查資訊
```
docker exec -ti devel-airflow bash -c "docker version"
```

## 執行 DockerOperator

+ [範例程式 - 執行 DockerOperator](../dags/tutorial_provider_docker_run.py)
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-build call-docker-run```。

```
DockerOperator(
    docker_url="tcp://docker:2376",
    tls_ca_cert="/certs/client/ca.pem",
    tls_client_cert="/certs/client/cert.pem",
    tls_client_key="/certs/client/key.pem",
    command="ls -al /",
    image="centos:latest",
    task_id="call-docker-container"
)
```

由於使用 Docker 啟用服務，其運作的網址需使用 TLS 加密通訊，對此參考文獻設定需額外提供諸如 ```tls_ca_cert```、```tls_client_cert```、```tls_client_key``` 的檔案位置；若僅使用 ```docker_url```，會出現對 HTTPS 協定使用 HTTP 協定的錯誤警告。

此外，由於很多文獻會以 ```docker.sock``` 掛入目錄的方式，讓程式使用預設位置 ```unix://var/run/docker.sock``` 來執行，在此亦可以採用共享的方式取得；但考慮產品環境中各執行容器的分離，以及可能使用第三方服務主機，還是以遠端加密通訊的方式設定。

## 編譯 Dockerfile

+ [範例程式 - Bash 與 DockerOperator](../dags/tutorial_provider_docker_build.py)
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-build call-docker-build```。
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-build call-docker-run-with-bash```。
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-build call-docker-run-with-docker```。
+ [範例程式 - TaskFlow 與 docker module](../dags/tutorial_provider_docker_module.py)
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-module call-docker-client```。

透過 DockerOperator 操作時，若欲執行的服務映象檔不存在目標 Docker Daemon 服務器中，則會自行前往官方 Docker Registry ( Docker Hub ) 下載後才運行；但實務上，更多服務會需要透過 Dockerfile 下載服務映象檔後安裝額外的功能，而這就會需要對目標 Docker Daemon 執行 ```docker build``` 指令。

然而 AirFlow 中的 Docker provider 並沒有提供建置的 API 操作，因此，有三個設計方式參考

+ 利用 AirFlow 的 BashOperator 執行 ```docker``` 指令並對目標 Docker Daemon 操作。

```
BashOperator(task_id="call-docker-build", bash_command="docker build -t test-docker ${AIRFLOW_HOME}/docker/bash")
```

+ 利用 Pythom 匯入 DockerOperator 封裝的操作模組，並執行[建置介面](BashOperator(task_id="call-docker-build", bash_command="docker build -t test-docker ${AIRFLOW_HOME}/docker/bash"))

這部分操作需建立一個 TaskFlow 並直接操作 docker 模組的連線建立，再依據此連線服務來操控對應的介面。

+ 利用 Docker 服務器建立時，一次性完成所需的服務映象檔

這部分操作假設 Docker Daemon 為 docker-in-docker 或可以自行管理的服務主機，在流程執行前事先完成服務映像檔建置。

## 執行 Docker 掛載目錄

+ [範例程式 - 掛載目錄](../dags/tutorial_provider_docker_build.py)
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-run-with-voulme create-tmpfile```。
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-run-with-voulme call-docker-run-with-bash```。
    - CLI 進行測試 ```airflow tasks test tutorial-provider-docker-run-with-voulme call-docker-run-with-docker```。

對於遠端控制的 Docker Daemon，不論是 docker-in-docker 或是遠端伺服器，當你宣告掛載目錄時，都是以目標服務器的目錄來掛載，因此，在使用時需要注意以下幾點

+ 若使用 ```docker run -v /local-path:/container-path``` 指令，掛載目錄必須本地與遠端皆存在。

在使用以上指令時，由於會檢查本地目錄，若存在才會將命令通知遠端主計並掛起目錄，因此，在 docker-in-docker 中也可以讓 AirFlow 與 Docker Daemon 共享相同目錄來達成操作。

+ 使用 ```docker run --mount``` 指令，僅需遠端存在目錄。

此操作放式也是 DockerOperator 中所描述的動作。

**If you know you run DockerOperator with remote engine or via docker-in-docker you should set ``mount_tmp_dir`` parameter to False. In this case, you can still use ``mounts`` parameter to mount already existing named volumes in your Docker Engine to achieve similar capability where you can store files exceeding default disk size of the container**

若換成指令則如下所示

```
from docker.types import Mount
DockerOperator(
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
```
