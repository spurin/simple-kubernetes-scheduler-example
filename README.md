# Simple Kubernetes Scheduler Example

An example of the Binding process carried out by the Kubernetes kube-scheduler

## Create a yaml file for a pod, with an assigned scheduler of my-scheduler -

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  schedulerName: my-scheduler
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

##  Apply the nginx pod with a custom scheduler -

```
# kubectl apply -f nginx_scheduler.yaml
pod/nginx created
```

## The pod will be pending -

```
# kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
nginx   0/1     Pending   0          6s    <none>   <none>   <none>           <none>
```

##  Run the scheduler example to bind the pod to a node -

```
# ./my_scheduler.sh 
🚀 Starting the custom scheduler...
🎯 Attempting to bind the pod nginx in namespace default to node worker-2
🎉 Successfully bound the pod nginx to node worker-2
```

## The pod will be scheduled to a node -

```
# kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE       NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          28s   10.42.2.3   worker-2   <none>           <none>
```
