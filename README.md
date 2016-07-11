# Deis LogBomb (WIP)

Deis LogBomb is intended for applying load directly to Deis Workflow's logging subsystem. This tool
is meant to facilitate the establishment of performance benchmarks for that subsystem wherein the
results will be minimally tainted by a network congested with unrelated traffic.

## Documentation

With a functioning Deis Workflow cluster and `kubectl` properly configured:

```
$ make build kube-create
```

## License

© 2016 Engine Yard, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
