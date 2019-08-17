#!/bin/sh

export JAVA_HOME="$HOME/opt/jdk-8u92-windows-x64"
export PATH="$PATH:$JAVA_HOME/bin"
export PATH="$PATH:$HOME/opt/sbt/bin"
export ORIGINAL_PATH="${PATH}"

exec "$BASH" --login -i
