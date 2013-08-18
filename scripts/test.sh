#!/bin/bash

scripts/compile.sh && NODE_PATH=`pwd` mocha
