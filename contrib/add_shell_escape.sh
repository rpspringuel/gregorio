#!/usr/bin/env bash

#  add_shell_escape.sh
#  
#
#  Created by R. Padraic Springuel on 2016-05-10.
#

TARGET=`kpsewhich --var-value=TEXMFLOCAL`"/web2c"
mkdir -p ${TARGET}
TARGET=${TARGET}"/texmf.cnf"
touch ${TARGET}
if grep -q "^shell_escape_commands =.*gregorio.*" ${TARGET}; then
    echo "gregorio is already in the shell_escape_commands"
    echo "doing nothing"
elif grep -q "^shell_escape_commands =" ${TARGET}; then
    sed -i.old '/^shell_escape_commands =/ s/$/gregorio,/' ${TARGET}
    mktexlsr
else
    cp ${TARGET} ${TARGET}.old
    echo "" >> ${TARGET}
    echo "shell_escape_commands = `kpsewhich --var-value=shell_escape_commands`gregorio," >> ${TARGET}
    echo "" >> ${TARGET}
    mktexlsr
fi
