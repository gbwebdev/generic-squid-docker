FROM ubuntu/squid:5

# Lightweight entrypoint to render squid.conf from env
COPY docker-entrypoint.sh /docker-entrypoint.d/10-gen-conf.sh
RUN chmod +x /docker-entrypoint.d/10-gen-conf.sh

# Optional: quieter default logs
ENV SQUID_CACHE_LOG=/var/log/squid/cache.log \
    SQUID_ACCESS_LOG=/var/log/squid/access.log
