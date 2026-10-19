#!/usr/bin/env python3
import configparser
import json
import sys


def make_secret(name: str, **kwargs) -> str:
    data = {"VPN_TYPE": "wireguard"}
    data.update(kwargs)
    return json.dumps(
        {
            "apiVersion": "v1",
            "kind": "Secret",
            "metadata": {"name": name},
            "stringData": data,
        }
    )


def main() -> None:
    _, name, provider, *_argv = sys.argv
    config = configparser.ConfigParser()
    config.read_file(sys.stdin)
    interface = config["Interface"]
    addresses = interface["Address"]
    privatekey = interface["PrivateKey"]
    mtu = interface["MTU"]
    peer = config["Peer"]
    presharedkey = peer["PresharedKey"]

    sys.stdout.write(
        make_secret(
            name,
            VPN_SERVICE_PROVIDER=provider,
            WIREGUARD_PRIVATE_KEY=privatekey,
            WIREGUARD_ADDRESSES=addresses,
            WIREGUARD_PRESHARED_KEY=presharedkey,
            WIREGUARD_MTU=mtu,
        )
    )


if __name__ == "__main__":
    main()
