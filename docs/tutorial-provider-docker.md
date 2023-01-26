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

對於本專案所需研究的是，在此架構下如何運用 Docker 引入不同的演算法容器，以避免套件安裝導致容器服務複雜化。

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

+ [範例程式](../dags/tutorial_provider_docker.py)

因上述範例僅有一個任務，可以使用 CLI 進行測試 ```airflow tasks test tutorial-provider-docker call-docker-container```，與一般文件設定不同。

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

## 執行 Docker
