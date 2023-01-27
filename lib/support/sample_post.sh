#!/bin/sh

curl -v \
-H 'Content-Type: application/json' \
-H 'Authorization: Bearer a82663bacd9b62b5910c32b4c3c1fc9f' \
-d @sample_post.json \
http://localhost:3000/tagscans.json
