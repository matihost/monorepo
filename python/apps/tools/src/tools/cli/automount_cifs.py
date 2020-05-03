#!/usr/bin/env python3
"""
Mount SAMBA/CIFS 1.0 resource to be automatically mounted when available and reached
(using system autofs service)
"""
import argparse

from tools.utils.version import package_version
from tools.utils.system import reexecute_self_as_root

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
    parser.add_argument('-p', '--pass', metavar='pass', nargs='?', type=str,
                        help='name to mount')

    parser.add_argument('-v', '--version', action='version',
                        version=package_version('tools'))
    args = parser.parse_args()
    return args.server_url


def main():
    """
    Main program method
    """
    args = _parse_program_argv()
    # TODO implement
    print('{0}'.format(args))


if __name__ == "__main__":
    main()
