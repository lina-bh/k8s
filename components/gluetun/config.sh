HEALTH_SERVER_ADDRESS=0.0.0.0:9999
PUBLICIP_ENABLED=false
STORAGE_SERVERS_ENABLED=false
HEALTH_SMALL_CHECK_TYPE=dns
# melee's Service CIDR, reached outside the tunnel: kube-dns for local names,
# and cluster Services such as pg-rw.
# Assisted-by: Claude Code:claude-opus-5-5
FIREWALL_OUTBOUND_SUBNETS=10.96.0.0/12
FIREWALL_INPUT_PORTS=9999
