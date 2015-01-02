#!/bin/bash
HPESS_ENV=${HPESS_ENV:-'hpess'}
USER=${USER:-'root'}
export PS1="\e[0;34m$USER@$HPESS_ENV> \e[0;m"
