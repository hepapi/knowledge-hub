# Elasticsearch Index Lifecycle Management
## Index ekleme:
Logstash üzerinde tanımlanan indexname e göre oluşan indexlerin Kibana üzerinde görülmesi için create edilmesi gerekmektedir. Bunun için sol menüde Stack management altında Index Pattern bölümünden Create Index Pattern tıklanarak belirlenmiş olan pattern yazılıp oluşturulur. 
 
## Repository oluşturma:
Alınancak snapshotların tutulması için bir repo oluşturulmalı ve register edilmelidir.

**/Stack management/Snapshot and Restore/Repositories**

Burada repo elasticsearch kurulu sunucuda olabileceği gibi ayrı bir sunucuda da olabilir. Önemli olan elasticsearch konfigürasyon dosyası içinde (elasticsearch.yaml, values.yaml) bu dizin belirtilmelidir. Başka sunucuda da olacaksa mount edilmelidir.

Örneğin NFS server olarak kullanılacak ayrı bir sunucu için Elasticsearch sunucusunda çalıştırılan komutlar:

```yaml
sudo apt install nfs-common
sudo apt install cifs-utils
sudo  mount.nfs <destination-ip>:/mnt/disk2/elasticmount /mnt/elasticmount 
chown -R elasticsearch:elasticsearch elasticmount 
```
## Index Template:

Create edilen Indexlerin yönetilebilmesi ve bir lifecycle policy tanımlanabilmesi için bir template oluşturulmalıdır.

**/Stack management/Index Management/Index Templates**

Bölümünden create template tıklanarak belli patterne ait template oluşturulur.

 
**Index settings:**

{ "index": { "lifecycle": { "name": "kubernetes-pod-policy" } } }


## Index Lifecycle Policy:

Belirlenen patterne ait index lerin lifecyle içinde ne yapılacağına yönelik policy oluşturulur. Bunun için 

**/Stack management/ Index Lifecycle Policies**

altında Create Policy ile yeni bir policy oluşturulur.

Burada hangi fazda ne kadar süre duracağı ve bu sürede ne yapılacağı belirtilir. 

Örneğin şekilde verilen pod-loglarına ait policy de warm phase de 1 saatlik ömre sahip index lerin replica sayılarının 0 a çekilmesi (yer tutmaması için) sonrasında da delete phase de 7 günlük yaşam döngüsüne sahip indexlerin snapshot policysi çalıştıktan sonra silinmesine yönelik bir policy oluşturulmuştur.

## Snapshot Policy:

Belirlenen indexlerin yer tutmaması için belli aralıklarla snapshotı alınarak silinebilir. Gerektiğinde de bu snapshotlardan restore edilebilmektedir. Bu snapshotların alınması için bir policy tanımlanır.

**/Stack management/Snapshot and Restore/Policies**

Örneğin, şekildeki kubernetes-pod-daily-snapshot policy si oluşturulurken;

- Alınacak snapshot ismi <kubernetes-pod-{now/d}> şeklinde tanımlanarak gün bazlı oluşturulmuş,
- Alınacak snapshotun hangi repository de tutulacağı belirtilmiş, günün hangi saati alınacağı schedule ile tanımlanmış,
- hangi pattern e sahip index lerin alınacağı belirtilmiş,
- Bu snapshotun geçerlilik süresi (Expiration-hangi süreden sonra silme izni verildiği) belirtilmiş
- Bu policy de min ve max tutulacak snapshot sayısı belirtilmiştir.

## Snapshotların Restore edilmesi:
Belli bir güne ait alınmış snapshotların restore eilmesi için

**Stack management/Snapshot and Restore/snapshot**

altında ilgili güne ait snapshot tıklanır. Açılan ekranda restore düğmesi tıklanır. 

Burada snapshotlar bir den fazla güne ait olacaktır. Bununla birlikte incremental olarak alındığıda unutulmamalıdır.

Bir güne ait snapshot restore edilmesi için **Data streams and indices** deki tik kaldırılır ve aşağıda bulunan **deselect all** kısmı tıklanır. Sonrasında istenilen güne ait index tıklanarak restore işlemi yapılır.

