# source file  at: https://github.com/tvb-sz/thumbor
# docker image at: https://hub.docker.com/r/nmgsz/thumbor

# Define python version args
# Be used to base Image need before FROM
# if args used after FROM, should repeat define
ARG pythonVersion='3.12'

FROM python:${pythonVersion}-alpine

# docker build --build-arg pythonVersion='3.10' --build-arg thumborVersion='7.7.1' -t test-thumbor -f Dockerfile .
# docker run -p 8888:8881 --env THUMBOR_PORT=8881 -v ${PWD}/.env:/app/.env -v ${PWD}/thumbor.conf.tpl:/app/thumbor.conf.tpl test-thumbor

LABEL Maintainer="team tvb sz<nmg-sz@tvb.com>" Description="thumbor docker image base on alpine."

# define installed thumbor version args
ARG thumborVersion='7.7.0'

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# can rewrite by docker run command
ENV LOG_LEVEL="warning"
ENV THUMBOR_PORT="8888"
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
        # cairosvg dependencies
        cairo-dev cairo cairo-tools \
        # pillow dependencies
        jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev \
    && apk add --quiet --no-cache --virtual .build-deps \
    # Thumbor
    && pip install --quiet --no-cache-dir --upgrade pip setuptools \
    && pip install --quiet --no-cache-dir \
        # Jinja2 and envtpl are required to work with environment variables
        Jinja2==3.1.* envtpl==0.7.* \
        "numpy==1.*,>=1.26.3" \
        # pycurl is required for thumbor
        "pycurl==7.*,>=7.45.2" \
        thumbor==${thumborVersion} \
        thumbor-aws==0.8.* \
        google-cloud-storage thumbor-gcs \
        thumbor-icon-handler \
        cairosvg \
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

EXPOSE ${THUMBOR_PORT}
HEALTHCHECK --timeout=15s CMD curl --silent --fail http://127.0.0.1:${THUMBOR_PORT}/healthcheck
