#!/usr/bin/env zsh

emulate -L zsh

apk_path=$1

(cd $apk_path/bin && for f in ../usr/bin/*; do ln -s $f ./; done)
