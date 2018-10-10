FROM google/cloud-sdk:alpine
LABEL maintainer="ManuelLR <manuellr.git@gmail.com>"

WORKDIR /opt

RUN apk add --no-cache \
    curl \
    coreutils

COPY google-cloud-auto-snapshot.sh  /opt/
# COPY entrypoint.sh                  /opt/

# ENTRYPOINT /opt/entrypoint.sh
CMD [ "/opt/google-cloud-auto-snapshot.sh" ]
