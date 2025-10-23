# An nginx proxy routing with Kubernetes DNS resolution and service-to-service communication!

## 📁 Created Files:

Manifests:

- namespace.yaml - Creates geo namespace
- nginx-config.yaml - ConfigMap with nginx proxy config and HTML
- south-service.yaml - South service deployment + ClusterIP service
- north-service.yaml - North service deployment + ClusterIP service  
- globalapp-frontend.yaml - Frontend proxy deployment + NodePort service

Scripts:

- deploy.sh - Deploy all resources
- test.sh - Test proxy routing and service communication
- cleanup.sh - Remove all resources

## 🔧 Key Enhancements:

Environment Variables (All Deployments):

- South: NORTH_SERVICE_URL, GLOBALAPP_SERVICE_URL
- North: SOUTH_SERVICE_URL, GLOBALAPP_SERVICE_URL
- GlobalApp: SOUTH_SERVICE_URL, NORTH_SERVICE_URL

Frontend Curl Commands:

- Continuous curl to both backend services every 30 seconds
- Logs service availability and responses

Resource Management:

- South/North: 32Mi/25m requests, 64Mi/50m limits
- GlobalApp: 64Mi/50m requests, 128Mi/100m limits

Nginx Proxy Routes:

- / - Load balanced between north and south (weight=5 each)
- /south - Direct to south service
- /north - Direct to north service

## 🚀 To Deploy:

```bash
cd workload/geo-location
./deploy.sh
```


```bash
 kubectl get pods -n geo
NAME                         READY   STATUS    RESTARTS   AGE
globalapp-77466687ff-9j5m8   1/1     Running   0          36s
north-5cfcd5db7-djr2z        1/1     Running   0          36s
south-7fdf559f65-bwrjr       1/1     Running   0          36s
```

## 🌐 Access:

- **Main**: http://NODEIP:30090/
- **South**: http://NODEIP:30090/south  
- **North**: http://NODEIP:30090/north

