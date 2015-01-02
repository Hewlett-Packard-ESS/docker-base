#!/bin/bash
HPESS_ENV=${HPESS_ENV:-'hpess'}
export PS1="\e[0;34m$HPESS_ENV${NAME:+ ($NAME)}> \e[0;m"
