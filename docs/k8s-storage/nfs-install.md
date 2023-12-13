# NFS Kurulumu Gereksinimler
- 1 Master Node
- 1 Worker Node (NFS)
---
Öncelikle bütün nodelarımızdaki `/etc/hosts` dosyasına, NFS sunucumuzun ip adresini kayıt ediyoruz.

```yaml
/etc/hosts

172.31.18.194 master
172.31.20.138 k8s-ankara-nfs01
```

Daha sonra NFS yapımız için gerekli uygulamaları kuruyoruz.

```yaml
sudo apt-get update
sudo apt-get install -y nfs-kernel-server
```

Sunucumuzda dosyaların saklanması için bir dizin oluşturalım.
```yaml
sudo mkdir /k8s-data && sudo mkdir /k8s-data/ankara-data
sudo chmod 1777 /k8s-data/ankara-data
touch /k8s-data/ankara-data/ankara-cluster.txt
```
Yeni oluşturduğumuz dizin için NFS sunucu dosyasını düzenlememiz gerekiyor. Bu aşamada dizini bütün nodelarımızla paylaşmış olacağız.
```yaml
sudo nano /etc/exports
```


Açtıktan sonra aşağıdaki değerleri en sona ekleyelim.
```yaml
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#

/k8s-data/ankara-data *(rw,sync,no_root_squash,subtree_check)
```


Ardından aşağıdaki komutu çalıştırarak exportfs’nin yeniden okunmasını ve değişikliklerin onaylanmasını sağlayalım.
```yaml
sudo exportfs -ra
```


Şimdi bütün Kubernetes nodelarımızda aşağıdaki işlemleri yapacağız.
```yaml
sudo apt-get -y install nfs-common
```


Kurulum bittikten sonra tüm nodelarımızda aşağıdaki komutu çalıştırarak, erişim sorunu olup, olmadığını kontrol ediyoruz.
```yaml
showmount -e k8s-ankara-nfs01
```


Herhangi bir sorun görünmüyor. Artık NFS sunucumuzda açtığımız klasörü, nodelarımıza mount edebiliriz.
```yaml
sudo mount k8s-ankara-nfs01:/k8s-data/ankara-data /mnt
ls -l /mnt
```

NFS için tüm kurulum ve ayarlamaları yaptık. Sorunsuz şekilde podlarımızın verilerini saklayabiliriz.

NFS’imizi podların kullanımına sunmak için örnek Persistent Volume, Persistent Volume Claim ve Pod yaml dosyası aşağıdaki gibi olmalıdır.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ankara-cluster-test-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /k8s-data/ankara-data
    server: k8s-ankara-nfs01
    readOnly: false
```
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ankara-pv-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 5Gi
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-generator-pod
spec:
  containers:
  - name: data-generator-container
    image: alpine
    command: ["/bin/sh", "-c"]
    args:
    - |
      while true; do
        echo "$(date) - Data content: $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)" > /data/data-$(date +%s).txt
        sleep 1
      done
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: ankara-pv-claim
```
