# MindsDB v26.1.0 (official image, pinned by version and digest)
FROM mindsdb/mindsdb:v26.1.0@sha256:163011c09299a95c97ce2e1b9f157683b3538c5b9167ddc258b95ac256c806bb

# The image ships the Studio GUI pre-downloaded under /root/mdb_storage/static.
# Railway mounts an empty volume on /root/mdb_storage, which would hide it and make
# MindsDB download the GUI from S3 on first boot. Keep the GUI that matches this
# image outside the volume instead.
RUN cp -a /root/mdb_storage/static /opt/mindsdb-gui

COPY start.sh /usr/local/bin/mindsdb-railway-start
RUN chmod +x /usr/local/bin/mindsdb-railway-start

EXPOSE 47334 47335
# The base image probes port 47334; follow PORT instead (Railway sets it).
HEALTHCHECK --interval=30s --timeout=10s --retries=5 --start-period=60s \
  CMD curl -fsS "http://localhost:${PORT:-47334}/api/util/ping" || exit 1
ENTRYPOINT ["/usr/local/bin/mindsdb-railway-start"]
