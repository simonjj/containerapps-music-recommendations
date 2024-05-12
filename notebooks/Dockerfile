# ds_build_s
#FROM quay.io/jupyter/base-notebook
# ds_build_m
FROM quay.io/jupyter/pytorch-notebook

ENV TRANSFORMERS_CACHE=/tmp/.cache
ENV TOKENIZERS_PARALLELISM=true

# Add RUN statements to install packages as the $NB_USER defined in the base images.

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.

#USER root
USER ${NB_UID}

COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/
RUN pip install --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

COPY --chown=${NB_UID}:${NB_GID} start.ipynb "${HOME}"
COPY --chown=${NB_UID}:${NB_GID} import.ipynb "${HOME}"
COPY --chown=${NB_UID}:${NB_GID} recommend.ipynb "${HOME}"
COPY --chown=${NB_UID}:${NB_GID} data_prep.ipynb "${HOME}/data/"
COPY --chown=${NB_UID}:${NB_GID} data/ "${HOME}/data/"

#RUN fix-permissions "/home/${NB_USER}"

#USER ${NB_UID}
WORKDIR "${HOME}"
ENTRYPOINT ["start-notebook.sh"]
