#!/bin/sh

for f in samples/*; do
  echo "----------------"
  echo ""
  echo $f
  echo ""
  ./gel $f
  echo ""
done
