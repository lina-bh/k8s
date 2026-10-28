cluster := "melee"

reconcile type="git":
	git push origin main
	flux --namespace=flux-system --context={{ cluster }} reconcile source {{ type }} flux-system

inflate:
	flate build ks --path=clusters/{{ cluster }}

build:
	flate build all --path=clusters/{{ cluster }}

diff output="human":
	flate diff all --path=clusters/{{ cluster }} --output={{ output }}

[script("sh", "-eu")]
lint:
	tmp="$(mktemp)"
	trap 'rm -f "$tmp"' EXIT
	flate build all --path=clusters/{{ cluster }} > "$tmp"
	status=0
	# --config {{ quote(justfile_directory()) }}/.kube-linter.yaml
	kube-linter lint --config=kube-linter.yaml - < "$tmp" || status=1
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

kind-down:
	kind delete cluster
	kubectl config use-context melee
