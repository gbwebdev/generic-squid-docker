FROM alpine:3.22

RUN apk add --no-cache squid

# Lightweight entrypoint to render squid.conf from env
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Optional: quieter default logs
ENV SQUID_CACHE_LOG=/var/log/squid/cache.log \
    SQUID_ACCESS_LOG=/var/log/squid/access.log

    ENTRYPOINT [ "/docker-entrypoint.sh" ]