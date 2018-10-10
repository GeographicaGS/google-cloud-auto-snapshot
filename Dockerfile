FROM google/cloud-sdk:alpine
LABEL maintainer="ManuelLR <manuellr.git@gmail.com>"

WORKDIR /opt

RUN apk add --no-cache \
    curl \
    coreutils

COPY google-cloud-auto-snapshot.sh  /opt/
COPY start.sh                       /opt/

CMD [ "/opt/start.sh" ]
