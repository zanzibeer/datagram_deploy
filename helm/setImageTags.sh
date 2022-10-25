#!/usr/bin/env sh
sed -i "s/\${tags}/$1/g" ./helm/datagram/templates/statefulset.yaml