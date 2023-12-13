---
title: AWS EKS Kubernetes with AWS Load Balancer Controller
description: Kubernetes Role and Role Binding in combination with AWS IAM Role, Group and User on EKS Cluster
---


```

```
## Step-13: c5-02-ingress-class.tf
- Understand what is Ingress Class 
- Understand how it overrides the default deprecated annotation `#kubernetes.io/ingress.class: "alb"`
- [Ingress Class Documentation Reference](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/ingress_class/)
- [Different Ingress Controllers available today](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
```t
# Resource: Kubernetes Ingress Class
resource "kubernetes_ingress_class_v1" "ingress_class_default" {
  depends_on = [helm_release.loadbalancer_controller]
  metadata {
    name = "my-aws-ingress-class"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }  
  spec {
    controller = "ingress.k8s.aws/alb"
  }
}
```
## Step-14: Execute Terraform Commands
```t
# Change Directory
02-lbc-install-terraform-manifests

# Terraform Initialize
terraform init

# Terraform Validate
terraform validate

# Terraform Plan
terraform plan

# Terraform Apply
terraform apply -auto-approve
```


## Step-15: Verify that the controller is installed and Webhook Service created
```t
# Verify that the controller is installed.
kubectl -n kube-system get deployment 
kubectl -n kube-system get deployment aws-load-balancer-controller
kubectl -n kube-system describe deployment aws-load-balancer-controller

# Sample Output
Kalyans-Mac-mini:02-lbc-install-terraform-manifests kalyanreddy$ kubectl -n kube-system get deployment aws-load-balancer-controller
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           18m
Kalyans-Mac-mini:02-lbc-install-terraform-manifests kalyanreddy$ 


# Verify AWS Load Balancer Controller Webhook service created
kubectl -n kube-system get svc 
kubectl -n kube-system get svc aws-load-balancer-webhook-service
kubectl -n kube-system describe svc aws-load-balancer-webhook-service

# Sample Output
Kalyans-Mac-mini:02-lbc-install-terraform-manifests kalyanreddy$ kubectl -n kube-system get svc aws-load-balancer-webhook-service
NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
aws-load-balancer-webhook-service   ClusterIP   172.20.110.33   <none>        443/TCP   18m
Kalyans-Mac-mini:02-lbc-install-terraform-manifests kalyanreddy$ 

# Verify Labels in Service and Selector Labels in Deployment
kubectl -n kube-system get svc aws-load-balancer-webhook-service -o yaml
kubectl -n kube-system get deployment aws-load-balancer-controller -o yaml
Observation:
1. Verify "spec.selector" label in "aws-load-balancer-webhook-service"
2. Compare it with "aws-load-balancer-controller" Deployment "spec.selector.matchLabels"
3. Both values should be same which traffic coming to "aws-load-balancer-webhook-service" on port 443 will be sent to port 9443 on "aws-load-balancer-controller" deployment related pods. 
```

## Step-16: Verify AWS Load Balancer Controller Logs
```t
# List Pods
kubectl get pods -n kube-system

# Review logs for AWS LB Controller POD-1
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f  aws-load-balancer-controller-86b598cbd6-5pjfk

# Review logs for AWS LB Controller POD-2
kubectl -n kube-system logs -f <POD-NAME> 
kubectl -n kube-system logs -f aws-load-balancer-controller-86b598cbd6-vqqsk
```

## Step-17: Verify AWS Load Balancer Controller k8s Service Account - Internals 
```t
# List Service Account and its secret
kubectl -n kube-system get sa aws-load-balancer-controller
kubectl -n kube-system get sa aws-load-balancer-controller -o yaml
kubectl -n kube-system get secret <GET_FROM_PREVIOUS_COMMAND - secrets.name> -o yaml
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th 
kubectl -n kube-system get secret aws-load-balancer-controller-token-5w8th -o yaml
## Decoce ca.crt using below two websites
https://www.base64decode.org/
https://www.sslchecker.com/certdecoder

## Decode token using below two websites
https://www.base64decode.org/
https://jwt.io/
Observation:
1. Review decoded JWT Token

# List Deployment in YAML format
kubectl -n kube-system get deploy aws-load-balancer-controller -o yaml
Observation:
1. Verify "spec.template.spec.serviceAccount" and "spec.template.spec.serviceAccountName" in "aws-load-balancer-controller" Deployment
2. We should find the Service Account Name as "aws-load-balancer-controller"

# List Pods in YAML format
kubectl -n kube-system get pods
kubectl -n kube-system get pod <AWS-Load-Balancer-Controller-POD-NAME> -o yaml
kubectl -n kube-system get pod aws-load-balancer-controller-65b4f64d6c-h2vh4 -o yaml
Observation:
1. Verify "spec.serviceAccount" and "spec.serviceAccountName"
2. We should find the Service Account Name as "aws-load-balancer-controller"
3. Verify "spec.volumes". You should find something as below, which is a temporary credentials to access AWS Services
CHECK-1: Verify "spec.volumes.name = aws-iam-token"
  - name: aws-iam-token
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          audience: sts.amazonaws.com
          expirationSeconds: 86400
          path: token
CHECK-2: Verify Volume Mounts
    volumeMounts:
    - mountPath: /var/run/secrets/eks.amazonaws.com/serviceaccount
      name: aws-iam-token
      readOnly: true          
CHECK-3: Verify ENVs whose path name is "token"
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token          
```

## Step-18: Verify TLS Certs for AWS Load Balancer Controller - Internals
```t
# List aws-load-balancer-tls secret 
kubectl -n kube-system get secret aws-load-balancer-tls -o yaml

# Verify the ca.crt and tls.crt in below websites
https://www.base64decode.org/
https://www.sslchecker.com/certdecoder

# Make a note of Common Name and SAN from above 
Common Name: aws-load-balancer-controller
SAN: aws-load-balancer-webhook-service.kube-system, aws-load-balancer-webhook-service.kube-system.svc

# List Pods in YAML format
kubectl -n kube-system get pods
kubectl -n kube-system get pod <AWS-Load-Balancer-Controller-POD-NAME> -o yaml
kubectl -n kube-system get pod aws-load-balancer-controller-65b4f64d6c-h2vh4 -o yaml
Observation:
1. Verify how the secret is mounted in AWS Load Balancer Controller Pod
CHECK-2: Verify Volume Mounts
    volumeMounts:
    - mountPath: /tmp/k8s-webhook-server/serving-certs
      name: cert
      readOnly: true
CHECK-3: Verify Volumes
  volumes:
  - name: cert
    secret:
      defaultMode: 420
      secretName: aws-load-balancer-tls
```


## References
- [AWS Load Balancer Controller Install](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- [ECR Repository per region](https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html)



---
title: AWS EKS Ingress Basics automate with Terraform
description: Learn AWS Load Balancer Controller - Ingress Basics automate using Terraform
---
## Step-01: Introduction
- Discuss about the Application Architecture which we are going to deploy
- Understand the following Ingress Concepts
  - [Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/)
  - [ingressClassName](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/ingress_class/)
  - defaultBackend
  - rules




## Step-04: Review Ingress kube-manifest with Default Backend Option
- [Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/)
                 
      

# 1. If  "spec.ingressClassName: my-aws-ingress-class" not specified, will reference default ingress class on this kubernetes cluster
# 2. Default Ingress class is nothing but for which ingress class we have the annotation `ingressclass.kubernetes.io/is-default-class: "true"`            
```

## Step-05: Deploy kube-manifests and Verify
```t
# Configure kubeconfig for kubectl
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region eu-west-2 update-kubeconfig --name exp-dev-eksdemo1

# Verify Kubernetes Worker Nodes using kubectl
kubectl get nodes
kubectl get nodes -o wide

# Change Directory
cd 27-EKS-Ingress-Basics

# Deploy kube-manifests
kubectl apply -f 03-kube-manifests-ingress-basics/

# Verify k8s Deployment and Pods
kubectl get deploy
kubectl get pods

# Verify Ingress (Make a note of Address field)
kubectl get ingress
Obsevation: 
1. Verify the ADDRESS value, we should see something like "ingress-basics-1334515506.eu-west-2.elb.amazonaws.com"

# Describe Ingress Controller
kubectl describe ingress ingress-nginxapp1
Observation:
1. Review Default Backend and Rules

# List Services
kubectl get svc

# Verify Application Load Balancer using 
Goto AWS Mgmt Console -> Services -> EC2 -> Load Balancers
1. Verify Listeners and Rules inside a listener
2. Verify Target Groups

# Access App using Browser
kubectl get ingress
http://<ALB-DNS-URL>
or
http://<INGRESS-ADDRESS-FIELD>

# Sample from my environment (for reference only)
http://ingress-basics-154912460.eu-west-2.elb.amazonaws.com

# Verify AWS Load Balancer Controller logs
kubectl get po -n kube-system 
## POD1 Logs: 
kubectl -n kube-system logs -f <POD1-NAME>
kubectl -n kube-system logs -f aws-load-balancer-controller-65b4f64d6c-h2vh4
##POD2 Logs: 
kubectl -n kube-system logs -f <POD2-NAME>
kubectl -n kube-system logs -f aws-load-balancer-controller-65b4f64d6c-t7qqb
```

## Step-06: Clean Up
```
# Delete Kubernetes Resources
kubectl delete -f 03-kube-manifests-ingress-basics/
```



