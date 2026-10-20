kubeconfig:
	ssh root@melee.lamancha-alhena.ts.net -- \
		sudo cat /etc/rancher/k3s/k3s.yaml | \
		yq '.clusters[0].cluster.server = "https://melee.lamancha-alhena.ts.net:6443"' \
	> .kube/kubeconfig

reconcile:
	flux --namespace=flux-system reconcile source git flux-system

inflate:
	flate build ks --path=k8s/clusters/melee

diff *args:
	flate diff all --path=k8s/clusters/melee {{ args }}

[script("sh", "-eu")]
lint:
	tmp="$(mktemp)"
	trap 'rm -f "$tmp"' EXIT
	{{ quote(just_executable()) }} -f {{ quote(justfile()) }} inflate > "$tmp"
	status=0
	# --config {{ quote(justfile_directory()) }}/.kube-linter.yaml
	kube-linter lint - < "$tmp" || status=1
	kubeconform -schema-location default -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{{{.Group}}/{{{{.ResourceKind}}_{{{{.ResourceAPIVersion}}.json' < "$tmp" || status=1
	exit "$status"
