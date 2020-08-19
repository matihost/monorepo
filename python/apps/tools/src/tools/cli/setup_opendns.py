#!/usr/bin/env python3
"""Ensure OpenDNS is updated with router's public ip regularly."""
import argparse
import subprocess

from jinja2 import Template

from tools.utils.file import read_file, write_file, relative_path
from tools.utils.version import package_version
from tools.utils.system import run, reexecute_self_as_root

reexecute_self_as_root()

_DESCRIPTION = """Ensure OpenDNS is updated with router's public ip regularly
It ensures ddclient is installed, configured to update OpenDNS with currently public ip regularly.
"""

_EPILOG = """Example:
setup-opendns -u opendns@user.com -p password Home1
"""

_NETWORK_LABEL_HELP = """label given to the network you're updating in your OpenDNSaccount.
You can find the network label in the Settings Tab of the OpenDNS Dashboard.
If you have spaces in your network label, replace them with an underscore ( _ )"""


def _parse_program_argv():
    parser = argparse.ArgumentParser(description=_DESCRIPTION, epilog=_EPILOG,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('opendns_network_label', metavar='opendns_network_label',
                        type=str, help=_NETWORK_LABEL_HELP)
    parser.add_argument('-u', '--user', metavar='user', type=str, required=True,
                        help='OpenDNS username')
    parser.add_argument('-p', '--password', metavar='password', type=str, required=True,
                        help='OpenDNS password')
    parser.add_argument('-v', '--version', action='version',
                        version=package_version('tools'))
    args = parser.parse_args()
    return args.opendns_network_label, args.user, args.password


def main():
    """Enter the program."""
    opendns_network_label, user, password = _parse_program_argv()

    ensure_ddclient_installed()
    if ensure_ddclient_config_setup(opendns_network_label, user, password):
        ensure_ddclient_service_is_running_and_enabled()


def is_ddclient_installed():
    """Check whether ddclient is present in the system."""
    try:
        run('command -v ddclient')
        return True
    except subprocess.CalledProcessError:
        return False


def ensure_ddclient_installed():
    """Ensure ddclient is installed."""
    if not is_ddclient_installed():
        print('Installing ddclient')
        run('apt-get -y install ddclient')


def ensure_ddclient_config_setup(opendns_network_label, user, password):
    """Ensure ddclient configuration is present in the system."""
    template = Template(read_file(relative_path(__file__, '..', 'files', 'ddclient.conf.j2')))
    desired_config = template.render(opendns_network_label=opendns_network_label,
                                     user_email=user, password=password)

    current_config = read_file('/etc/ddclient.conf', ignore_error=True)

    if current_config != desired_config:
        if len(current_config.strip()) != 0:
            print('Backup existing ddclient.conf as /etc/ddclient.conf.backup')
            write_file('/etc/ddclient.conf.backup', current_config)
            run('chmod 400 /etc/ddclient.conf.backup')
        print('Writing /etc/ddclient.conf')
        write_file('/etc/ddclient.conf', desired_config)
        run('chmod 400 /etc/ddclient.conf')
        return True
    return False


def ensure_ddclient_service_is_running_and_enabled():
    """Ensure ddclient systemd service is running starting upon system boot."""
    print('Restarting ddclient service')
    run('systemctl restart ddclient')
    print('Enabling ddclient service')
    run('systemctl enable ddclient')


if __name__ == "__main__":
    main()
