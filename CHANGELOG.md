# Changelog

Each entry lists breaking changes first. Read it before you apply an update from Railway.

## v26.1.0 (2026-11-17)

- First release of this template: MindsDB `v26.1.0` (`mindsdb/mindsdb:v26.1.0@sha256:163011c09299a95c97ce2e1b9f157683b3538c5b9167ddc258b95ac256c806bb`).
- Login required (generated `MINDSDB_PASSWORD`), data on a volume at `/root/mdb_storage`, Studio GUI baked in (no download at boot), health check `/api/util/ping`, MySQL API on container port 47335 (TLS on).
