import os
import sys
import subprocess


def reexecute_self_as_root():
    """
    Re-execute current process as root.
    It breaks current process and run it again as root, hence
    it SHOULD be run at the beginning of the program.
    """
    if os.geteuid() != 0:
        os.execvp('sudo', ['python3'] + sys.argv)


def run(command):
    return subprocess.check_output(command, encoding='UTF-8', shell=True, stderr=subprocess.STDOUT)
