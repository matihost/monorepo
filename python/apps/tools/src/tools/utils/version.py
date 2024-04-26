"""Versioning utility functions."""
import subprocess
import importlib.metadata as importlib_metadata


def git_version():
    """Retrieve version of source code repository as git describe long output."""
    try:
        version = subprocess.check_output(["git", "describe", "--long"],
                                          encoding='UTF-8', stderr=subprocess.DEVNULL)\
            .strip().replace('-', '.')
    except subprocess.CalledProcessError:
        version = "0.0.1.dev1"
    return version


def package_version(package):
    """Retrieve python package version."""
    return importlib_metadata.version(package)
