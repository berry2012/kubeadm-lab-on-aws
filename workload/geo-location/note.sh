
# ====== Demo: nginx proxy for global multi-location app in kubernetes ======


User --> http://globalapp/south ---> http://south.geo.svc.cluster.local
User --> http://globalapp/north ---> http://north.geo.svc.cluster.local



kubectl create ns geo


kubectl create deployment south --image=nginx --replicas=1 --port=80 -n geo
kubectl create deployment north --image=nginx --replicas=1 --port=80 -n geo
kubectl expose deployment south --type=ClusterIP --name=south --port=80 --target-port=80 -n geo
kubectl expose deployment north --type=ClusterIP --name=north --port=80 --target-port=80 -n geo


kubectl run globalapp --image=nginx -n geo
kubectl expose pod globalapp --type=NodePort --name=globalapp --port=80 -n geo 

# the globalapp needs nginx configuration 

kubectl exec -it globalapp -n geo -- sh
cat << EOF > /etc/nginx/nginx.conf
events {
    worker_connections  1024;
}

http {
    upstream backend {
        server south.geo.svc.cluster.local weight=5;
        server north.geo.svc.cluster.local weight=5;
    }

    upstream south {
        server south.geo.svc.cluster.local;
    }

    upstream north {
        server north.geo.svc.cluster.local;
    }    
    
    server {
        location / {
            proxy_pass http://backend;
        }

        location /south {
            proxy_pass      http://south;
        }

        location /north {
            proxy_pass      http://north;
        }

    }
}
EOF
# reload nginx
nginx -s reload

kubectl get pods,svc,deploy -n geo

apt install vim -y 
vim /usr/share/nginx/html/index.html


<!DOCTYPE html>
<html>
<head>
<title>globalapp Gateway</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>globalapp Gateway</h1>
</body>
</html>

k exec -it north-86bbd4cc67-zrd5z -n geo -- sh
cat << EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Service 2</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Service 2</h1>
</body>
</html>
EOF

k exec -it north-c4b7787f6-2rsr8 -n geo -- sh
cat << EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Service 2</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Service 2</h1>
</body>
</html>
EOF




