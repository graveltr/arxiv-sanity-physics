#!/bin/bash

cd /app
export PYTHONPATH=/app
/usr/local/bin/python arxiv_daemon.py --num 2000
/usr/local/bin/python compute.py
