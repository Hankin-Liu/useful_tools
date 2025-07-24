#!/bin/bash
g++ -std=c++11 -fPIC -shared -o libhookmalloc.so hook_malloc.cpp -ldl -pthread -O2 -g
