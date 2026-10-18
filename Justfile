kubeconfig:
	ssh root@melee.lamancha-alhena.ts.net -- \
		sudo cat /etc/rancher/k3s/k3s.yaml | \
		yq '.clusters[0].cluster.server = "https://melee.lamancha-alhena.ts.net:6443"' \
	> .kube/kubeconfig
