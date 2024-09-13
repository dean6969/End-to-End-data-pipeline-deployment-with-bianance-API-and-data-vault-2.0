#!/bin/bash

# Di chuyển tới thư mục chứa docker-compose.yml
cd /home/ec2-user/app

# Dừng và gỡ bỏ các container đang chạy (nếu có)
docker-compose down

# Khởi động lại các container
docker-compose up -d
