cluster := "melee"

kubeconfig:
	ssh root@melee.lamancha-alhena.ts.net -- \
		sudo cat /etc/rancher/k3s/k3s.yaml | \
		cluster="{{ cluster }}" yq ' \
		(.. | select(. == "default")) = strenv(cluster) \
		| .clusters[].cluster.server = "https://melee.lamancha-alhena.ts.net:6443" \
		| del(.current-context)' \
	> .kube/config
	kubectl config use-context "{{ cluster }}"

reconcile:
	git push origin main
	flux --namespace=flux-system --context=melee reconcile source git flux-system

inflate:
	flate build ks --path=k8s/clusters/{{ cluster }}

build:
	flate build all --path=k8s/clusters/{{ cluster }}

diff *args:
	flate diff all --path=k8s/clusters/{{ cluster }} {{ args }}

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

export KIND_CLUSTER_NAME := "dev"

kind-up:
	kind create cluster --config=kind/dev.yaml
	flux install --components=source-controller,kustomize-controller,helm-controller --context "kind-${KIND_CLUSTER_NAME}"
	flux \
	     --context="kind-${KIND_CLUSTER_NAME}" \
	     create source oci flux-system \
	     --url=oci://registry.lamancha-alhena.ts.net/k8s-dev \
	     --tag=latest \
	     --interval=2m
	flux \
	     --context="kind-${KIND_CLUSTER_NAME}" \
	     create kustomization flux-system \
	     --source=OCIRepository/flux-system \
	     --path="./k8s/clusters/dev" \
	     --prune=true \
	     --interval=10m \
	     --wait=true

kind-push:
	flux push artifact \
	     --path=. \
	     --source=https://github.com/lina-bh/melee.git \
	     --revision="$(git describe --always --dirty)" \
	     --ignore-paths='/*,!/k8s/' \
	     oci://registry.lamancha-alhena.ts.net/k8s-dev:latest
	flux \
	     --context="kind-${KIND_CLUSTER_NAME}" \
	     reconcile source oci flux-system

kind-down:
	kind delete cluster
	kubectl config use-context melee
