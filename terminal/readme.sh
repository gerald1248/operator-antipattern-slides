$ for TAG in "9.3.4" "15.0.0" "60.0.0"; do
> git checkout "kube-prometheus-stack-${TAG}" 2>/dev/null
> echo "# ${TAG}"
> wc -l charts/kube-prometheus-stack/README.md
> grep -v "\(^kubectl .*crd\|CRD\)" charts/kube-prometheus-stack/README.md | wc -l
> done
# 9.3.4
312 charts/kube-prometheus-stack/README.md
296
# 15.0.0
434 charts/kube-prometheus-stack/README.md
397
# 60.0.0
1090 charts/kube-prometheus-stack/README.md
811
