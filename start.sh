#!/bin/bash

export PORT=5300

cd ~/www/tanks
./bin/tanks stop || true
./bin/tanks start
