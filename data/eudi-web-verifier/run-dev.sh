#!/bin/bash

npm install
# echo "----------------------------"
# cat src/proxy.conf.json
# echo "----------------------------"
# pnpm run ng serve --host 0.0.0.0 --proxy-config src/proxy.conf.json --verbose
npm run ng serve -- --host 0.0.0.0 
