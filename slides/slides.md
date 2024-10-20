---
title: The operator antipattern
pdf: operator-antipattern.pdf
backgroundTransition: fade
transition: none
# progress: false
standalone: true
---

<link href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.10.0/styles/light.min.css">

# The operator antipattern {bgcss=sg15 .light-on-dark}

Kubernetes Community Days London 2024

Gerald Schmidt

<img src="assets/img/logo-monochrome.png" width="80" alt="DS Smith logo in white with transparent background"/></smaller>

# {bgcss=sg14 .light-on-dark}
<img width="600" src="assets/img/Box_factory_1.webp"/>
<!--<img width="400" src="https://static.wikia.nocookie.net/simpsons/images/6/69/Box_factory_1.png" alt="Simpsons box factory as found on Simpsons Fandom"/>-->
<br/>
<small>Source: <a href="https://simpsons.fandom.com/wiki/Springfield_Box_Factory">simpsons.fandom.com/wiki/Springfield_Box_Factory</a></small>

# {bgcss=sg13 .light-on-dark}
<iframe id="copyconstruct" width="550" height="480" frameBorder="0" title="Cindy Sridharan" src="assets/copyconstruct/index.html">
</iframe>
<small>Classic Sridharan:<br/><a href="https://copyconstruct.medium.com/testing-microservices-the-sane-way-9bb31d158c16">Testing Microservices, the sane way</a> (2017) |
<a href="https://medium.com/@copyconstruct/testing-in-production-the-safe-way-18ca102d0ef1">Testing in Production, the safe way</a> (2018) |
<a href="https://copyconstruct.medium.com/testing-in-production-the-hard-parts-3f06cefaf592">Testing in Production: the hard parts</a> (2019)</small>

# {bgcss=sg12 .with-links}
<img src="assets/img/xy.png"/>
<small>Source: <a href="https://layoffs.fyi/">layoffs.fyi</a></small>

# {bgcss=sg11 .light-on-dark}
<img src="assets/img/timeline.png"/>

# The premise {bgcss=sg10 .with-links}

An Operator is an application-specific controller that extends the Kubernetes API to create, configure, and manage instances of complex stateful applications on behalf of a Kubernetes user. It builds upon the basic Kubernetes resource and controller concepts but includes domain or application-specific knowledge to automate common tasks.

<small>Brandon Philips, <a href="https://www.redhat.com/en/blog/introducing-operators-putting-operational-knowledge-into-software">Introducing Operators: Putting Operational Knowledge into Software</a> (2016)</small>

# {bgcss=sg09}
<img src="assets/img/operator-benefits.png"/>

# The CRD/controller split {bgcss=sg09}

# Weighting {bgcss=sg09}
The benefits of operators centre on the controller.

The custom resource component is to a meaningful extent syntactic sugar.

At the same time it is responsible for most of the problematic side-effects of operators: custom resource definitions are cluster-level objects, which brings with it a whole set of permission issues. Versioning is another problematic aspect that we'll come back to.

# {bgcss=sg08}
<img width="500px" src="assets/img/quadrant.png"/>

#  Prometheus without operator {bgcss=sg07}

```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "2112"
    prometheus.io/scrape: "true"
```

# Prometheus with operator {bgcss=sg07}

```bash
$ kubectl get crd -o custom-columns=NAME:.metadata.name \
  | grep "monitoring\.coreos"
alertmanagerconfigs.monitoring.coreos.com
alertmanagers.monitoring.coreos.com
podmonitors.monitoring.coreos.com
probes.monitoring.coreos.com
prometheusagents.monitoring.coreos.com
prometheuses.monitoring.coreos.com
prometheusrules.monitoring.coreos.com
scrapeconfigs.monitoring.coreos.com
servicemonitors.monitoring.coreos.com
thanosrulers.monitoring.coreos.com
```

# Kube Prometheus stack {bgcss=sg06}

```bash
FILE=charts/kube-prometheus-stack/README.md
for TAG in "9.3.4" "15.0.0" "60.0.0"; do
  git checkout "kube-prometheus-stack-${TAG}" 2>/dev/null
  echo "# ${TAG}"
  head -n -100 "${FILE}" | wc -l charts/kube-prometheus-stack/README.md
  grep -v "\(^kubectl .*crd\|CRD\)" "${FILE}" | wc -l
done
```

# Kube-prometheus-operator {bgcss=sg05}
<img src="assets/img/sankey.png"/>

# Antipattern 1: operators in developer workflows {bgcss=sg04 .light-on-dark}
Flow operator

# Antipattern 2: tight coupling with external resources {bgcss=sg04 .light-on-dark}
Strimzi

# Antipattern 3: versioning trouble {bgcss=sg04 .light-on-dark}
Incrementing CRD versions is a serious matter.

Is the old version still served? Have we provided a conversion webhook?

So far from reducing complexity, we are introducing new error conditions, failure modes and edge cases.

See AWS Controllers for Kubernetes. (Still on alpha.)

# Antipattern 4: overpromising {bgcss=sg04 .light-on-dark}
The association of operators with complex *stateful* applications has not displaced managed databases such as the Relational Database Service. The CRD that allows me to create a VectorDatabase resource does not magically make it a good, fault-tolerant. A backup method is helpful and appreciated, but it does not rival a mature point-in-time recovery facility.

Whisper it: Kubernetes does not have a 'stateful workload' problem. It has a persistent volume problem. The solution is object storage, and the challenge is working around the limitations of object storage when it comes to read and write speed.

<small>See <a href="https://medium.com/go-city/object-storage-for-stateful-applications-on-kubernetes-35dc2388cb2f">Object storage for stateful applications on Kubernetes</a></small>

# Kyverno {bgcss=sg03 .light-on-dark}
Wins first prize for an implementation that feels as if it should be an in-tree policy engine. Policy violations create detailed events and the new resources (Policy, ClusterPolicy) fit well into the existing set of resources.

# Controller revival {bgcss=sg03 .light-on-dark}

Grafana has bucked the trend of CRD sprawl.

To load a dashboard on startup, Grafana seeks out ConfigMaps that have label `grafana_dashboard` set to value `1`.

There is no need for a GrafanaDashboard CRD.

Grafana dashboards are JSON objects following a well-established structure.

Teams store dashboards they wish to keep in a folder:

```bash
for DASHBOARD in \
  $(ls kube-prometheus-stack/dashboards/*.json)
do
  CONFIGMAP=$(basename "${DASHBOARD}" | cut -d'.' -f1)
  kubectl create configmap "${CONFIGMAP}" \
    -n monitoring \
    --dry-run=client \
    --from-file="${DASHBOARD}" -o yaml | \
    kubectl apply -f -
  kubectl label configmap "${CONFIGMAP}" \
    -n monitoring \
    --overwrite grafana_dashboard="1"
done
``` 

# {bgcss=sg02 .light-on-dark}
<i class="fa fa-github" aria-hidden="true"></i> <a href="https://github.com/gerald1248/operator-antipattern-slides">gerald1248/operator-antipattern-slides</a><br/>
<i class="fa fa-linkedin" aria-hidden="true"></i> <a href="https://www.linkedin.com/in/gerald1248/">www.linkedin.com/in/gerald1248</a><br/>
<i class="fa fa-twitter" aria-hidden="true"></i> 03spirit<br/>
Slides built with <a href="https://github.com/arnehilmann/markdeck">Markdeck</a><br/>

<img src="assets/img/logo-monochrome.png" width="80" alt="DS Smith logo in white with transparent background"/></smaller>
