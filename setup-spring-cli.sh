#!/bin/sh

export JAVA_HOME="$HOME/opt/jdk-8u92-windows-x64"
PATH="$PATH:$JAVA_HOME/bin"
SPRING_HOME="$HOME/opt/spring-2.0.0.RELEASE"
PATH="$PATH:$SPRING_HOME/bin"

exec "$BASH" --login
