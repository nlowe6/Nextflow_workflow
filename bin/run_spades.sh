#!/bin/bash
mkdir -p "$2"
spades.py -s "$1" -o "$2"
