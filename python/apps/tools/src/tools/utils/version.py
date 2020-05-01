import subprocess
import pkg_resources

def git_version():
    try:
        version = subprocess.check_output(
            ["git", "describe", "--long"],
            stderr=subprocess.DEVNULL).decode('UTF-8').strip().replace('-', '.')
    except subprocess.CalledProcessError:
        version = "0.0.1.dev1"
    return version

def package_version(package):
    try:
        version = pkg_resources.get_distribution(package).version
    except pkg_resources.DistributionNotFound:
        version = "0.0.1.dev1"
    return version
