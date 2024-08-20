#!/bin/bash

cd /app

export PYTHONPATH=/app

python arxiv_daemon.py --num 2000
python compute.py
