#!/usr/bin/env python3
"""
Mount SAMBA/CIFS 1.0 resource to be automatically mounted when available and reached.

(using system autofs service)
"""
import argparse
import subprocess

from tools.utils.file import read_file, write_file
from tools.utils.version import package_version
from tools.utils.system import run, reexecute_self_as_root

reexecute_self_as_root()

_DESCRIPTION = "Ensure SAMBA/CIFS 1.0 url is mounted as autofs resource"
_EPILOG = """
Example:
automount-cifs //192.168.1.1/all /mnt/nas/router/all -u admin -p passwordForResource
"""


def _parse_program_argv():
    parser = argparse.ArgumentParser(description=_DESCRIPTION, epilog=_EPILOG,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('server_url', metavar='server_url', type=str,
                        help='the url to mount, for example: //192.168.1.1/all')
    parser.add_argument('mount_path', metavar='mount_path', type=str,
                        help='mount path, example: /mnt/nas/router/all')
    parser.add_argument('-u', '--user', metavar='user', nargs='?', type=str,
                        help='user')
    parser.add_argument('-p', '--password', metavar='password', nargs='?', type=str,
                        help='name to mount')

    parser.add_argument('-v', '--version', action='version',
                        version=package_version('tools'))
    args = parser.parse_args()
    return args.server_url, args.mount_path, args.user, args.password


def main():
    """Enter the program."""
    url, mount_path, user, password = _parse_program_argv()
    ensure_autofs_present()
    ensure_direct_mapping_present()
    if ensure_mapping2url_present(url, mount_path, user, password):
        ensure_autofs_running_and_enabled()


def is_automount_installed():
    """Check whether automout is present in the system."""
    try:
        run('command -v automount')
        return True
    except subprocess.CalledProcessError:
        return False


def ensure_autofs_present():
    """Ensure autofs package is installed."""
    if not is_automount_installed():
        print('Installing autofs')
        run('apt-get -y install autofs')


def ensure_direct_mapping_present():
    """Ensure automount diract mappiint to router CIFS is present."""
    desired_config = "/-  /etc/auto.direct\n"
    direct_mapping_filename = '/etc/auto.master.d/direct.autofs'
    current_config = read_file(direct_mapping_filename, ignore_error=True)
    if current_config != desired_config:
        write_file(direct_mapping_filename, desired_config)


def ensure_mapping2url_present(url, mount_path, user, password):
    """Convert mount data to autofs mapping."""
    desired_line = "{1} -fstype=cifs,user={2},password={3},rw,vers=1.0 :{0}\n"\
        .format(url, mount_path, user, password)
    direct_filename = '/etc/auto.direct'
    current_config = read_file(direct_filename, ignore_error=True)
    # TODO what is file mapping is already there
    if desired_line not in current_config:
        # TODO ensure mount directory is present except the last directory
        print('Writing {0} with {1} mapping to {2}'.format(direct_filename, url, mount_path))
        write_file(direct_filename, desired_line, mode='a')
        return True
    return False


def ensure_autofs_running_and_enabled():
    """Ensure autofs is running and enabled."""
    print('Restarting autofs service')
    run('systemctl restart autofs')
    print('Enabling autofs service')
    run('systemctl enable autofs')


if __name__ == "__main__":
    main()
