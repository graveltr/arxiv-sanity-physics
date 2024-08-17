#!/bin/bash

cd /app

python arxiv_daemon.py --num 2000
python compute.py
