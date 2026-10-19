#!/usr/bin/env python3
import configparser
import json
import sys


def main() -> None:
    config = configparser.ConfigParser()
    config.read_file(sys.stdin)
    interface = config["Interface"]
    addresses = interface["Address"]
    privatekey = interface["PrivateKey"]
    mtu = interface["MTU"]
    peer = config["Peer"]
    presharedkey = peer["PresharedKey"]

    keys = {
        "VPN_TYPE": "wireguard",
        "WIREGUARD_PRIVATE_KEY": privatekey,
        "WIREGUARD_ADDRESSES": addresses,
        "WIREGUARD_PRESHARED_KEY": presharedkey,
        "WIREGUARD_MTU": mtu,
    }

    sys.stdout.write("\n".join(f'{k}="{v}"' for k, v in keys.items()) + "\n")


if __name__ == "__main__":
    main()
