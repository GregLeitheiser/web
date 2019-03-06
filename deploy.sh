#!/usr/bin/env bash

#login = `aws ecr get-login --no-include-email`
#exec $login

docker.exe tag gregleithieser/sc-web:latest gregleitheiser/sc-web:latest
docker.exe push gregleitheiser/sc-web:latest
