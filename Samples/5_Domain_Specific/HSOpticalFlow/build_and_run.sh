#!/usr/bin/env bash

set -euo pipefail

rm -rf build && mkdir build && cd build && cmake .. && make -j16 && ./HSOpticalFlow
