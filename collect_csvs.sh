#!/bin/bash
mapfile CSV_FILES < <(find . -name $1)
cat ${CSV_FILES[@]}
