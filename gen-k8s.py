#!/usr/bin/python3

import json
from typing import NamedTuple


class Container(NamedTuple):
    wic_url: str
    pod_idx: int

    def to_container(self) -> dict:
        idx = self.pod_idx
        port = 2021 + idx;

        return {
            "name": f"qemu-{idx}",
            "image": "doanac/qemu-lmp:1dc8a0c",
            "command": [
              "/usr/local/bin/download-run.sh",
              f"/data/qemu-{idx}.wic",
              f"-netdev user,id=net0,hostfwd=tcp::{port}-:22",
              self.wic_url,
            ],
            "tty": True,
            "stdin": True,
            "securityContext": {
              "privileged": True,
              "capabilities": {
                "add": [
                  "NET_ADMIN"
                ]
              }
            },
            "volumeMounts": [
              {
                "name": "dev-kvm",
                "mountPath": "/dev/kvm"
              },
              {
                "name": "dev-tun",
                "mountPath": "/dev/net/tun"
              },
              {
                "name": "data",
                "mountPath": "/data"
              }
            ]
          }


host_aliases = [
    {"ip": "35.222.247.102", "hostnames": ["api.foundries.io"]},
    {"ip": "34.123.235.174", "hostnames": ["ota-lite.foundries.io", "42901445-79e7-408a-8f07-9dd68f3157ed.ota-lite.foundries.io"]},
]

ss_templ = {
  "apiVersion": "apps/v1",
  "kind": "StatefulSet",
  "metadata": {
    "name": "lmp"
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "app": "lmp"
      }
    },
    "serviceName": "lmp",
    "replicas": 1,
    "template": {
      "metadata": {
        "labels": {
          "app": "lmp"
        }
      },
      "spec": {
        "containers": [],
        "volumes": [
          {
            "name": "dev-kvm",
            "hostPath": {
              "path": "/dev/kvm"
            }
          },
          {
            "name": "dev-tun",
            "hostPath": {
              "path": "/dev/net/tun"
            }
          }
        ]
      }
    },
    "volumeClaimTemplates": [
      {
        "metadata": {
          "name": "data"
        },
        "spec": {
          "accessModes": [
            "ReadWriteOnce"
          ],
          "resources": {
            "requests": {
              "storage": "40G"
            }
          }
        }
      }
    ]
  }
}

def generate(wic_url: str, num_instances: int, use_host_alias: bool) -> str:
    data = ss_templ
    for i in range(num_instances):
        c = Container(wic_url, i + 1)
        containers = data["spec"]["template"]["spec"]["containers"]
        containers.append(c.to_container())

    if use_host_alias:
        data["spec"]["template"]["spec"]["hostAliases"] = host_aliases

    return json.dumps(data, indent=2)


url = "https://storage.googleapis.com/tenant-osf/this-be-in-staging/lmp/4/intel-corei7-64/lmp-factory-image-intel-corei7-64.wic.gz"
# spec = generate(url, 12, True)  # good balance for 8G RAM node
spec = generate(url, 4, True)
print(spec)
