FROM jupyter/scipy-notebook
COPY ./jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py
COPY ./flake8 /home/jovyan/.flake8
RUN pip install papermill black s3fs
