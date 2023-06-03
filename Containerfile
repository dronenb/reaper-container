FROM ubuntu:22.04

ARG \
    REAPER_VERSION=6.80 \
    ARCH=aarch64 \
    REAPER_USER=reaper \
    REAPER_GROUP=reaper \
    REAPER_UID=1001 \
    REAPER_GID=1001

ENV \
    GDK_BACKEND=x11
RUN \
    set -ex && \
    ################################################################
    ## Install prereqs
    ################################################################
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libasound2 \
        libfontconfig-dev \
        libgl1 \
        libgtk-3-dev \
        libx11-dev \
        libxi6 \
        xorg \
        xz-utils && \
    ################################################################
    ## Install REAPER
    ################################################################
    REAPER_VERSION_NODOT=$( \
        echo "${REAPER_VERSION}" | \
        sed 's/\.//' \
    ) && \
    REAPER_MAJOR_VERSION=$( \
        echo "${REAPER_VERSION}" | \
        sed -E 's/([[:digit:]]+)\.([[:digit:]]+)/\1/'\
    ) && \
    FILENAME="reaper${REAPER_VERSION_NODOT}_linux_${ARCH}.tar.xz" && \
    URL="https://www.reaper.fm/files/${REAPER_MAJOR_VERSION}.x/${FILENAME}" && \
    mkdir -p /tmp/reaper/ && \
    cd /tmp/reaper && \
    curl \
        --location \
        --output "${FILENAME}" \
        --progress-bar \
        --retry "${CURL_RETRY:-5}" \
        --retry-delay "${CURL_RETRY_DELAY:-0}" \
        --retry-max-time "${CURL_RETRY_MAX_TIME:-60}" \
        --show-error \
        --url "${URL}" && \
    tar -vxf "${FILENAME}" && \
    rm "${FILENAME}" && \
    cd "reaper_linux_${ARCH}" && \
    ./install-reaper.sh --install /opt && \
    cd /opt/REAPER && \
    rm -rf /tmp/reaper && \
    #################################################################
    # Add user and group first to make sure their IDs get assigned consistently
    ################################################################
    groupadd \
        --system \
        --gid "${REAPER_GID}" \
        "${REAPER_GROUP}" && \
    useradd \
        --comment "REAPER user" \
        --no-log-init \
        --uid "${REAPER_UID}" \
        --gid "${REAPER_GID}" \
        --groups audio \
        --shell /bin/bash \
        --home-dir "/opt/REAPER" \
        "${REAPER_USER}" && \
    chown -R "${REAPER_USER}:${REAPER_GID}" /opt/REAPER

USER "${REAPER_USER}:${REAPER_GID}"
WORKDIR /opt/REAPER
ENTRYPOINT ["./reaper"]