#!/usr/bin/env bash

docker.exe run -dit --name web -p 8080:80 servantscode/web:latest
