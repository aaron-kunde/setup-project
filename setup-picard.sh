#!/bin/sh

INST_DIR=$HOME/opt
if [ ! -d $INST_DIR/make-3.81 ]
then
    echo "Installing make"
    echo "Creating installation directory for make"
    mkdir $INST_DIR/make-3.81
    pushd $INST_DIR/make-3.81 || exit $?

    if [ ! -f $TMP/make-3.81-bin.zip ]
    then
	echo "Downloading make binaries"
	curl -L http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-bin.zip > $TMP/make-3.81-bin.zip
    fi
    7z x $TMP/make-3.81-bin.zip

    if [ ! -f $TMP/make-3.81-dep.zip ]
    then
	echo "Downloading make dependencies"
	curl -L http://sourceforge.net/projects/gnuwin32/files/make/3.81/make-3.81-dep.zip > $TMP/make-3.81-dep.zip
    fi
    7z x $TMP/make-3.81-dep.zip
    popd
fi
export PATH=$PATH:$INST_DIR/make-3.81/bin

echo "Building SIP"
echo "Installing Mercurial"
pip install --user Mercurial
echo "Getting SIP sources"
hg clone http://www.riverbankcomputing.com/hg/sip
pushd sip
python build.py prepare
#Try this and other stuff like user space. python configure.py  -platform win32-g++
python configure.py
make
popd

exit
echo "Installing PyQt 4.5 or newer"
echo "Downloading PyQt"
if [ ! -f $TMP/PyQt-win-gpl-4.11.4.zip ]
then
    curl -L http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.11.4/PyQt-win-gpl-4.11.4.zip > $TMP/PyQt-win-gpl-4.11.4.zip
fi

7z x $TMP/PyQt-win-gpl-4.11.4.zip

echo "Installing mutagen (>= 1.20, 1.23 for AIFF)"
pip install --user mutagen
