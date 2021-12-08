import os
import subprocess

import sys


def run_command(command, err_msg):
    """run command silently, exit on error"""
    out = open(os.devnull, 'w')
    err = subprocess.STDOUT
    if subprocess.call(command, shell=True, stdout=out, stderr=err) != 0:
        print(err_msg, file=sys.stderr)
        exit(255)


run_command("python --version",
                       "Install Python first, make sure Python can be started from the command line "
                       "(add path to `python.exe` to PATH on Windows)")

run_command("cmake --version", "Install CMake first")

run_command("git --version", "Install Git first")
