@echo off
set PATH=%PATH%;%USERPROFILE%\opt\python-2.7.11
set PATH=%PATH%;%USERPROFILE%\AppData\Roaming\Python\Scripts

set WORKDIR=%USERPROFILE%\work

if not exist %WORKDIR%\get-pip.py (
    echo "Downloading 'get-pip.py'"
    curl https://bootstrap.pypa.io/get-pip.py > %WORKDIR%\get-pip.py
)

if exist %WORKDIR%\get-pip.py (
    echo "Installing / Updating pip user wide"
    python %WORKDIR%\get-pip.py --user
)
