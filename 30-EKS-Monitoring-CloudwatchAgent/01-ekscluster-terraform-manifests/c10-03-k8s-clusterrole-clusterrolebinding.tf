# Resource: Cluster Role
resource "kubernetes_cluster_role_v1" "eksreadonly_clusterrole" {
  metadata {
    name = "${local.name}-eksreadonly-clusterrole"
  }
  rule {
    api_groups = [""] # These come under core APIs
    resources  = ["bindings", "componentstatuses", "configmaps", "endpoints", "events", "limitranges", "namespaces", "namespaces/finalize", "namespaces/status", "nodes", "nodes/proxy", "nodes/status",  "persistentvolumeclaims", "persistentvolumeclaims/status", "persistentvolumes", "persistentvolumes/status", "pods", "pods/attach", "pods/binding", "pods/eviction", "pods/exec", "pods/log", "pods/proxy",  "pods/status", "podtemplates", "replicationcontrollers", "replicationcontrollers/scale", "replicationcontrollers/status", "resourcequotas", "resourcequotas/status", "serviceaccounts", "services", "services/proxy", "services/status"]
    #resources  = ["nodes", "namespaces", "pods", "events", "services", "configmaps", "serviceaccounts"] #Uncomment for additional Testing
    verbs      = ["get", "list", "watch"]    
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs      = ["get", "list", "watch"]    
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]    
  }  
}

# Resource: Cluster Role Binding
resource "kubernetes_cluster_role_binding_v1" "eksreadonly_clusterrolebinding" {
  metadata {
    name = "${local.name}-eksreadonly-clusterrolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.eksreadonly_clusterrole.metadata.0.name 
  }
  subject {
    kind      = "Group"
    name      = "eks-readonly-group"
    api_group = "rbac.authorization.k8s.io"
  }
}
 