#!/usr/bin/env bash
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
python3 -m venv $SCRIPTPATH/venv
source $SCRIPTPATH/venv/bin/activate
pip3 install -r $SCRIPTPATH/requirements.txt
