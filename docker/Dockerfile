FROM jupyter/scipy-notebook
USER root
RUN rm -rf /home/jovyan/work
COPY ./jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py
COPY ./flake8 /home/jovyan/.flake8
COPY ./utils/lint.sh /usr/local/bin/lint
RUN chmod +x /usr/local/bin/lint
RUN pip install papermill \
    black \
    s3fs \
    sphinx \
    cookiecutter \
    flake8 && \
    rm -rf /home/jovyan/.cache/pip
