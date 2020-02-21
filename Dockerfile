FROM node:lts-buster

ARG APT_FLAGS="-y --no-install-recommends"
ARG WATCHING_DIR="/app"
ARG WATCHER_DIR="/watcher"
ARG FORCE_MEDIA_MERGE="true"

RUN set -ex \
    && apt-get update --fix-missing \
    # && apt-get install ${APT_FLAGS} nano \
    && mkdir -p ${WATCHER_DIR} \
    && mkdir -p ${WATCHING_DIR} \
    && echo ${WATCHER_DIR} > /root/watcher.dir.var \
    && echo ${WATCHING_DIR} > /root/watching.dir.var
    # && echo "WATCHER_DIR=${WATCHER_DIR}" >> /etc/security/pam_env.conf \
    # && echo "WATCHING_DIR=${WATCHING_DIR}" >> /etc/security/pam_env.conf \
    # && echo "html { background-color: blue; }" > ${WATCHING_DIR}/style.css

WORKDIR ${WATCHING_DIR}

COPY package-lock.json ${WATCHER_DIR}/
COPY package.json ${WATCHER_DIR}/package.json
COPY gulpfile.js ${WATCHER_DIR}/

RUN set -ex \
#     && sed -e "s|\${WATCHER_DIR}|${WATCHER_DIR}|g" -i ${WATCHER_DIR}/gulpfile.js \
    && sed -e "s|\${WATCHING_DIR}|${WATCHING_DIR}|g" -i ${WATCHER_DIR}/gulpfile.js \
    && sed -e "s|'\${FORCE_MEDIA_MERGE}'|${FORCE_MEDIA_MERGE}|g" -i ${WATCHER_DIR}/gulpfile.js

ENTRYPOINT set -ex \
    # && printenv \
    # && cat /etc/security/pam_env.conf \
    && export WATCHER_DIR=$(cat /root/watcher.dir.var) \
    && export WATCHING_DIR=$(cat /root/watching.dir.var) \
    # && cat ${WATCHER_DIR}/index.js \
    && cd ${WATCHER_DIR} \
    # && npm install less csso fancy-log gulp gulp-less gulp-csso gulp-sourcemaps less-plugin-autoprefix --save \
    && npm ci \
    && $(npm bin)/gulp
    # && tail -f /dev/null