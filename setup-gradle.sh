#!/bin/sh

export JAVA_HOME="$HOME/opt/jdk-8u92-windows-x64"
PATH="$PATH:$JAVA_HOME/bin"

GRADLE_HOME="$HOME/opt/gradle-4.6"
PATH="$PATH:$GRADLE_HOME/bin"

exec "$BASH" --login
