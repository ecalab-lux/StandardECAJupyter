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

# Install packages one by one to take advantage of docker caching
RUN pip3 install --user gensim==3.8.3 # numpy, scipy, smart-open, six
RUN pip3 install --user pandas # python-dateutil, pytz
RUN pip3 install --user nltk # tqdm, regex, joblib, click
RUN pip3 install --user spacy # Downgrades smart-open to 3.0.0, installed by gensim, includes urllib3, idna, chardet, certifi, requests, murmurhash, cymem, catalogue, wasabi, typer, srsly, pyparsing, pydantic, preshed, MarkupSafe, blis, thinc, spacy-legacy, pathy, packaging, jinja2
RUN pip3 install --user beautifulsoup4 # soupsieve
RUN pip3 install --user Flask # Werkzeug, itsdangerous
RUN pip3 install --user fuzzywuzzy
RUN pip3 install --user langid
RUN pip3 install --user lxml
RUN pip3 install --user networkx # decorator
RUN pip3 install --user openpyxl # jdcal, et-xmlfile
RUN pip3 install --user pdfminer.six PyPDF2 camelot-py # pycparser, cffi, sortedcontainers, cryptography
RUN pip3 install --user Pillow
RUN pip3 install --user python-docx
RUN pip3 install --user requests
RUN pip3 install --user scikit-learn scikit-image # threadpoolctl
RUN pip3 install --user SQLAlchemy pyodbc
RUN pip3 install --user Unidecode
RUN pip3 install --user XlsxWriter
RUN pip3 install --user jupyterlab jupytext
RUN pip3 install --user matplotlib # kiwisolver, cycler
RUN pip3 install --user seaborn
RUN pip3 install --user bokeh
RUN pip3 install --user sentence-transformers

# Download language models 
RUN python3 -m spacy download en_core_web_lg

# Download necessary nltk_data (for sentence splitting)
RUN python -m nltk.downloader punkt

# Generate self-signed SSL certificates
RUN openssl req -batch -x509 -nodes -days 730 -newkey rsa:2048 -keyout mykey.key -out mycert.pem -subj "/C=LU/ST=Luxembourg/O=ECALab"

RUN mkdir Notebooks
WORKDIR /home/jupyter/Notebooks
