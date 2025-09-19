#!/bin/bash

docker compose -p verifier up -d
echo "--------------------------------"
sleep 0.5
docker ps --format 'table {{.Label "com.docker.compose.project"}}\t{{if ge (len .Names) 16}}{{slice .Names 0 16}}{{else}}{{.Names}}{{end}}\t{{.Ports}}\t{{.Status}}' -a
