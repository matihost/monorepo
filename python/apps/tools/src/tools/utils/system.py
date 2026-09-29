"""System utility functions."""

import os
import shutil
import subprocess
import sys


def reexecute_self_as_root():
    """Re-execute current process as root.

    It breaks current process and run it again as root, hence
    it SHOULD be run at the beginning of the program.
    """
    if os.geteuid() != 0:
        os.execvp("sudo", ["python3"] + sys.argv)


def run(command):
    """Execute process and return its STDOUT."""
    return subprocess.check_output(command, encoding="UTF-8", shell=True, stderr=subprocess.STDOUT)


def is_command_available(command):
    """Check whether command is available in PATH.

    Args:
        command: name of the command, for example 'ffmpeg'.

    Returns:
        True when command is present in PATH.
    """
    return shutil.which(command) is not None


def ensure_commands_available(*commands):
    """Ensure all given commands are available in PATH.

    Args:
        *commands: names of required commands.

    Raises:
        RuntimeError: when any of the commands is missing, listing all missing ones.
    """
    missing = [command for command in commands if not is_command_available(command)]
    if missing:
        raise RuntimeError(
            f"Required command(s) not found in PATH: {', '.join(missing)}. Install them, for example: sudo apt-get install -y ffmpeg"
        )


def run_streamed(command, cwd=None, env=None):
    """Execute process passing its output through to the current terminal.

    Unlike run() it does not use shell, so arguments with spaces are safe,
    and it does not capture output, so progress of long running commands stays visible.

    Args:
        command: command with arguments as a list.
        cwd: optional working directory.
        env: optional environment variables mapping replacing the current one.

    Raises:
        subprocess.CalledProcessError: when command exits with non zero status.
    """
    subprocess.run([str(arg) for arg in command], check=True, cwd=cwd, env=env)
