@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

@rem ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

@rem ------------------- declare CLI file variable -------------------
@rem retrieve project name
@rem Ref : https://www.robvanderwoude.com/ntfor.php
@rem Directory = %~dp0
@rem Object Name With Quotations=%0
@rem Object Name Without Quotes=%~0
@rem Bat File Drive = %~d0
@rem Full File Name = %~n0%~x0
@rem File Name Without Extension = %~n0
@rem File Extension = %~x0

set CLI_DIRECTORY=%~dp0
set CLI_FILE=%~n0%~x0
set CLI_FILENAME=%~n0
set CLI_FILEEXTENSION=%~x0

@rem ------------------- declare CLI variable -------------------

set BREADCRUMB=cli
set COMMAND=
set COMMAND_BC_AGRS=
set COMMAND_AC_AGRS=

@rem ------------------- declare variable -------------------

for %%a in ("%cd%") do (
    set PROJECT_NAME=%%~na
)
set PROJECT_ENV=dev
set VARNUMBER1=0
set VARNUMBER2=0
set VARTEST=0

@rem ------------------- execute script -------------------

call :main %*
goto end

@rem ------------------- declare function -------------------

:main
    set COMMAND=
    set COMMAND_BC_AGRS=
    set COMMAND_AC_AGRS=
    call :argv-parser %*
    call :main-args-parser %COMMAND_BC_AGRS%
    IF defined COMMAND (
        set BREADCRUMB=%BREADCRUMB%-%COMMAND%
        findstr /bi /c:":!BREADCRUMB!" %CLI_FILE% >nul 2>&1
        IF errorlevel 1 (
            goto cli-help
        ) else (
            call :main %COMMAND_AC_AGRS%
        )
    ) else (
        call :%BREADCRUMB%
    )
    goto end

:main-args-parser
    for /f "tokens=1*" %%p in ("%*") do (
        for /f "tokens=1,2 delims==" %%i in ("%%p") do (
            call :%BREADCRUMB%-args %%i %%j
            call :common-args %%i %%j
        )
        call :main-args-parser %%q
    )
    goto end

:common-args
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    if "%COMMON_ARGS_KEY%"=="-h" (set BREADCRUMB=%BREADCRUMB%-help)
    if "%COMMON_ARGS_KEY%"=="--help" (set BREADCRUMB=%BREADCRUMB%-help)
    goto end

:argv-parser
    for /f "tokens=1*" %%p in ("%*") do (
        IF NOT defined COMMAND (
            echo %%p | findstr /r "\-" >nul 2>&1
            if errorlevel 1 (
                set COMMAND=%%p
            ) else (
                set COMMAND_BC_AGRS=!COMMAND_BC_AGRS! %%p
            )
        ) else (
            set COMMAND_AC_AGRS=!COMMAND_AC_AGRS! %%p
        )
        call :argv-parser %%q
    )
    goto end

@rem ------------------- Main method -------------------

:cli
    goto cli-help

:cli-args
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    if "%COMMON_ARGS_KEY%"=="--prod" (set PROJECT_ENV=prod)
    goto end

:cli-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo If not input any command, at default will show HELP
    echo.
    echo Options:
    echo      --help, -h        Show more information with CLI.
    echo      --prod            Setting project environment with "prod", default is "dev"
    echo.
    echo Command:
    echo      dev               Ariflow development mode.
    echo      down              Airflow production mode.
    echo.
    echo Run 'cli [COMMAND] --help' for more information on a command.
    goto end

@rem ------------------- Common Command method -------------------

@rem ------------------- Command "dev" method -------------------

:cli-dev
    goto cli-dev-help

:cli-dev-args
    goto end

:cli-dev-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Startup Development mode
    echo.
    echo Command:
    echo      up                Startup Server.
    echo      down              Close down Server.
    echo      into              Into Server.
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    goto end


@rem ------------------- Command "dev"-"up" method -------------------

:cli-dev-up
    @rem create cache
    IF NOT EXIST %CLI_DIRECTORY%\cache (
        mkdir %CLI_DIRECTORY%\cache
    )
    IF NOT EXIST %CLI_DIRECTORY%\cache\logs (
        mkdir %CLI_DIRECTORY%\cache\logs
    )
    IF NOT EXIST %CLI_DIRECTORY%\cache\plugins (
        mkdir %CLI_DIRECTORY%\cache\plugins
    )
    @rem create server
    docker run -d --rm ^
        -p 8080:8080 ^
        -v %CLI_DIRECTORY%\dags:/opt/airflow/dags^
        -v %CLI_DIRECTORY%\cache\logs:/opt/airflow/logs^
        -v %CLI_DIRECTORY%\cache\plugins:/opt/airflow/plugins^
        --env "_AIRFLOW_DB_UPGRADE=true" ^
        --env "_AIRFLOW_WWW_USER_CREATE=true" ^
        --env "_AIRFLOW_WWW_USER_USERNAME=airflow" ^
        --env "_AIRFLOW_WWW_USER_PASSWORD=airflow" ^
        --name "devel-airflow" ^
        apache/airflow webserver
    goto end

:cli-dev-up-args
    goto end

:cli-dev-up-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Startup Server
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    goto end

@rem ------------------- Command "dev"-"down" method -------------------

:cli-dev-down
    docker rm -f devel-airflow
    goto end

:cli-dev-down-args
    goto end

:cli-dev-down-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Close down Server
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    goto end


@rem ------------------- Command "dev"-"into" method -------------------

:cli-dev-into
    docker exec -ti devel-airflow bash
    goto end

:cli-dev-into-args
    goto end

:cli-dev-into-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Close down Server
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    goto end



@rem ------------------- Command "prd" method -------------------

:cli-prd
    goto cli-prd-help

:cli-prd-args
    goto end

:cli-prd-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Startup Production mode
    echo.
    echo Command:
    echo      up                Startup Server.
    echo      down              Close down Server.
    echo      into              Into Server.
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    goto end

@rem ------------------- Command "prd"-"up" method -------------------

:cli-prd-up
    @rem create cache
    IF NOT EXIST %CLI_DIRECTORY%\cache (
        mkdir %CLI_DIRECTORY%\cache
    )
    IF NOT EXIST %CLI_DIRECTORY%\cache\logs (
        mkdir %CLI_DIRECTORY%\cache\logs
    )
    IF NOT EXIST %CLI_DIRECTORY%\cache\plugins (
        mkdir %CLI_DIRECTORY%\cache\plugins
    )

    @rem generate .env
    echo TAG=%PROJECT_NAME% > %CLI_DIRECTORY%\cache\.env
    echo SOURCE_DAGS_DIR=%CLI_DIRECTORY%dags >> %CLI_DIRECTORY%\cache\.env
    echo SOURCE_LAGS_DIR=%CLI_DIRECTORY%cache\logs >> %CLI_DIRECTORY%\cache\.env
    echo SOURCE_PLUG_DIR=%CLI_DIRECTORY%cache\plugins >> %CLI_DIRECTORY%\cache\.env
    echo AIRFLOW_IMAGE_NAME=apache/airflow >> %CLI_DIRECTORY%\cache\.env
    echo AIRFLOW_UID=50000 >> %CLI_DIRECTORY%\cache\.env


    @rem start server with docker-compose
    docker-compose ^
        --env-file %CLI_DIRECTORY%\cache\.env ^
        --file %CLI_DIRECTORY%\conf\prd\docker-compose.yaml ^
        up -d
    goto end

:cli-prd-up-args
    goto end

:cli-prd-up-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Startup Server
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    goto end

@rem ------------------- Command "prd"-"down" method -------------------

:cli-prd-down
    docker-compose ^
        --env-file %CLI_DIRECTORY%\cache\.env ^
        --file %CLI_DIRECTORY%\conf\prd\docker-compose.yaml ^
        down --volumes
    goto end

:cli-prd-down-args
    goto end

:cli-prd-down-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Close down Server
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    goto end

@rem ------------------- Command "prd"-"cli" method -------------------

:cli-prd-cli
    docker-compose ^
        --env-file %CLI_DIRECTORY%\cache\.env ^
        --file %CLI_DIRECTORY%\conf\prd\docker-compose.yaml ^
        run --rm airflow-cli "%AIRFLOW_PRD_CLI_CMD%"
    goto end

:cli-prd-cli-args
    set COMMON_ARGS_KEY=%1
    set COMMON_ARGS_VALUE=%2
    if "%COMMON_ARGS_KEY%"=="-c" (set AIRFLOW_PRD_CLI_CMD=%COMMON_ARGS_VALUE%)
    goto end

:cli-prd-cli-help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Close down Server
    echo.
    echo Options:
    echo      --help, -h        Show more information with UP Command.
    echo      -c                Execute command string.
    goto end

@rem ------------------- End method-------------------

:end
    endlocal
