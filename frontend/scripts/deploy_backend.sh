#!/bin/bash

cd /opt/image-platform/backend

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt

sudo cp gunicorn.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable gunicorn

sudo systemctl restart gunicorn