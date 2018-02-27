
|![](https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Warning.svg/156px-Warning.svg.png) | Deis Workflow is no longer maintained.<br />Please [read the announcement](https://deis.com/blog/2017/deis-workflow-final-release/) for more detail. |
|---:|---|
| 09/07/2017 | Deis Workflow [v2.18][] final release before entering maintenance mode |
| 03/01/2018 | End of Workflow maintenance: critical patches no longer merged |
| | [Hephy](https://github.com/teamhephy/workflow) is a fork of Workflow that is actively developed and accepts code contributions. |

# Deis LogBomb (WIP)

Deis LogBomb is intended for applying load directly to Deis Workflow's logging subsystem. This tool
is meant to facilitate the establishment of performance benchmarks for that subsystem wherein the
results will be minimally tainted by a network congested with unrelated traffic.

## Documentation

With a functioning Deis Workflow cluster and `kubectl` properly configured:

```
$ make build kube-create
```

[v2.18]: https://github.com/deis/workflow/releases/tag/v2.18.0
