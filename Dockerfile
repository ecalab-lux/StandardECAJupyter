# This Dockerfile creates a jupyter lab server that includes all the libraries used at the ECA
FROM python:3.9.7-slim-buster
ARG TARGET_MACHINE # This variable will be used to decide the UID/GID of the internal user to match the host. Important: after the FROM!!!
RUN TZ=Europe/Luxembourg ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install gnupg2 curl wget
# Microsoft repository for ODBC
#RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
#RUN apt-get -y update
#RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN apt-get install -y g++ unixodbc-dev
# Create a non-root user
# Please match this with host machine desired uid and gid
RUN if [ "$TARGET_MACHINE" = 'ecadockerhub' ]; then echo "\n\033[0;32mBuilding for ecadockerhub\n\033[0;97m"; else echo "\n\033[0;32mBuilding for localhost\n\033[0;97m"; fi
# 901/954 for ecadockerhub, 1000/1000 for black
RUN if [ "$TARGET_MACHINE" = 'ecadockerhub' ]; then groupadd -r --gid 901 jupyter; else groupadd -r --gid 1000 jupyter; fi
RUN if [ "$TARGET_MACHINE" = 'ecadockerhub' ]; then useradd --no-log-init --uid 954 -r -m -g jupyter jupyter; else useradd --no-log-init --uid 1000 -r -m -g jupyter jupyter; fi
USER jupyter
WORKDIR /home/jupyter
ENV PATH=$PATH:/home/jupyter/.local/bin
COPY requirements.txt /home/jupyter/
RUN pip3 install --user -r requirements.txt
# Download language models 
RUN python3 -m spacy download en_core_web_lg
# Download necessary nltk_data
RUN python -m nltk.downloader punkt
RUN mkdir Notebooks
WORKDIR /home/jupyter/Notebooks
