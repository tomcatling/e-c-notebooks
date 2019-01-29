#!/bin/bash

# This script runs flake8 on all notebooks and all python files
# underneath the working directory. The .ipynb_checkpoints folder
# is the only one excluded by default.

for file in ./**.ipynb 
  do jupyter nbconvert --to python "$file" --stdout | flake8 --count  - 
done

flake8 --count --include .py --exclude .ipynb_checkpoints
