from jupyter/minimal-notebook

RUN mkdir -p /home/jovyan/notebooks ; chown -R jovyan /home/jovyan/notebooks
VOLUME ["/home/jovyan/notebooks"]
USER jovyan