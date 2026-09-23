FROM ghcr.io/marmotdata/marmot:0.9.0

USER root
COPY entrypoint.sh /usr/local/bin/aiven-entrypoint.sh
RUN chmod 0755 /usr/local/bin/aiven-entrypoint.sh
USER marmot

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/aiven-entrypoint.sh"]
CMD ["run"]
