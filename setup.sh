#!/usr/bin/env bash
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
virtualenv $SCRIPTPATH/venv
source $SCRIPTPATH/venv/bin/activate
pip install -r $SCRIPTPATH/requirements.txt
