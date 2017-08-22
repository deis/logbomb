# Deis LogBomb (WIP)

Deis LogBomb is intended for applying load directly to Deis Workflow's logging subsystem. This tool
is meant to facilitate the establishment of performance benchmarks for that subsystem wherein the
results will be minimally tainted by a network congested with unrelated traffic.

## Documentation

With a functioning Deis Workflow cluster and `kubectl` properly configured:

```
$ make build kube-create
```
