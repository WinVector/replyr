#!/bin/bash

# get rid of side effect files from practice runs

find . \( -name \*\.log -or -name \*.log\.\* -or -name \*.sqlite3\* \) -exec rm {} \;
