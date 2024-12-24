# source file  at: https://github.com/tvb-sz/thumbor
# docker image at: https://hub.docker.com/r/nmgsz/thumbor

# Define python version args
# Be used to base Image need before FROM
# if args used after FROM, should repeat define
ARG pythonVersion='3.12'

FROM python:${pythonVersion}-alpine

# docker build --build-arg pythonVersion='3.10' --build-arg thumborVersion='7.7.1' -t test-thumbor -f Dockerfile .

LABEL Maintainer="team tvb sz<nmg-sz@tvb.com>" Description="thumbor docker image base on alpine."

# define installed thumbor version args
ARG thumborVersion='7.7.0'

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# can rewrite by docker run command
ENV LOG_LEVEL="warning"
ENV PORT="8888"
ENV NUM_PROCESSES=0

# Enable jpegtran optimizer https://thumbor.readthedocs.io/en/latest/jpegtran.html#jpegtran
ENV OPTIMIZERS="['thumbor.optimizers.jpegtran']"

WORKDIR /app/

RUN set -eux \
    && apk update \
    && apk add --quiet --no-cache \
        bash \
        tzdata \
        nano \
        curl \
        iputils \
        tini \
        ## `gifsicle` is a Thumbor requirement for better processing of GIF images
        gifsicle \
        # jpegtran (libjpeg-turbo-utils) is a Thumbor requirement for optimizing JPEG images
        libjpeg-turbo-utils \
        curl-dev g++ \
    && apk add --quiet --no-cache --virtual .build-deps \
    # Thumbor
    && pip install --quiet --no-cache-dir --upgrade pip \
    && pip install --quiet --no-cache-dir \
        # python build tool
        setuptools \
        # Jinja2 and envtpl are required to work with environment variables
        Jinja2==3.1.* envtpl==0.7.* \
        # sentry is required for error tracking
        "sentry-sdk==1.*,>=1.39.1" \
        "numpy==1.*,>=1.26.3" \
        # pycurl is required for thumbor
        "pycurl==7.*,>=7.45.2" thumbor==${thumborVersion} cairosvg \
    # Cleanup
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* \
    # /data/ dir is used by thumbor
    && mkdir /data/ \
    && thumbor --version \
    && envtpl --help \
    && jpegtran -version \
    && gifsicle --version

# COPY ./thumbor.conf.tpl /usr/local/etc/thumbor.conf.tpl
COPY --chmod=0755 ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["thumbor"]

EXPOSE ${PORT}
HEALTHCHECK --timeout=15s CMD curl --silent --fail http://127.0.0.1:${PORT}/healthcheck
