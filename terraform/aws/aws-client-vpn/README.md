# AWS Client VPN

Terraform scripts creating:

- Client VPN endpoint in selected VPC and its private subnets.


## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Tofu/Terragrunt, OpenVPN client installed

- Warning: For Linux/Ubuntu clients AppArmor policy may prevent OpenVPN client to change systemd-resolved (aka `/run/systemd/resolve/resolv.conf` content) configuration to update DNS resolver settings.
See: <https://bugs.launchpad.net/ubuntu/+source/apparmor/+bug/2107596> for details.
Workaround:

Ensure `/etc/apparmor.d/openvpn` file and `profile update-resolv` sections contains:

```txt
    dbus (send) bus="system" path="/org/freedesktop/resolve1" interface="org.freedesktop.resolve1.Manager" member="SetLinkDomains",
    dbus (send) bus="system" path="/org/freedesktop/resolve1" interface="org.freedesktop.resolve1.Manager" member="RevertLink",
```

Then reload AppArmor profile:

```bash
sudo apparmor_parser -r /etc/apparmor.d/openvpn
```

## Usage

```bash
# setup Client Side VPN
make run MODE=apply [ENV=dev] [PARTITION=aws]

# create target/client.ovpn file needed to connect to VPN
# mode is either all (default), aka all trafic goes via VPN
# or private - when only VPC traffic routed via VPN
make get-client-ovpn ENV=dev

# connect to to VPN, press Ctrl+C to disconnect
# mode is either all (default), aka all trafic goes via VPN
# or private - when only VPC traffic routed via VPN
make connect-to-vpn

# show Terraform state
make show-state
```
