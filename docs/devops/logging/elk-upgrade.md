# Elasticsearch + Kibana Upgrade (Rolling, 3 Master Nodes)

This section is a **minimal, step-by-step** guide so someone can run the commands and complete a safe upgrade.

- [Elastic Support Matrix](https://www.elastic.co/support/matrix) (Elasticsearch + Kibana OS/JVM compatibility)

> **Production reminder:** run the same upgrade on a test/staging cluster first, and validate snapshot/restore.
> **Where to run commands:**  
> - **Kibana Dev Tools:** commands starting with `GET/PUT/POST`  
> - **Node terminal:** commands starting with `sudo`, `systemctl`, `wget`, `rpm`, `dpkg`

## Recommended Path (Production)

```
8.14.2
  ↓
8.18.x   (run Upgrade Assistant, fix all issues)
  ↓
9.2.4    (rolling upgrade)
```

> You must reach the **latest 8.x** first, then upgrade to **9.x**.
> In 8.18.x, open Kibana **Upgrade Assistant** and fix all warnings before moving to 9.x.
> **Do not** install 9.x packages until all **Critical** items are cleared.
> [Upgrade Assistant docs](https://www.elastic.co/guide/en/kibana/current/upgrade-assistant.html)
> Version rule: 8.x → latest 8.x before 9.x; prefer a stable 9.x minor (not 9.0.0).
> Always verify the exact target versions on elastic.co before running `wget` (avoid 404s).

---

## Pre-Upgrade Checklist (Must Do)

1) **Cluster health must be green or yellow (red is not allowed):**

```bash
GET _cat/health?v
```

2) **Snapshot is mandatory (rollback safety):**

```bash
GET _snapshot
```

If repository exists, take a snapshot:

```bash
PUT _snapshot/<repo_name>/pre_upgrade_8x_to_8_latest?wait_for_completion=true
GET _snapshot/<repo_name>/pre_upgrade_8x_to_8_latest
```

You should see:

```json
"state":"SUCCESS"
```

> Rollback note: Elasticsearch does **not** support downgrade. If upgrade fails, the recovery path is **restore from snapshot**.

---

## Upgrade Order (Golden Rule)

**Order is mandatory:**

1) Data nodes (if tiers: frozen → cold → warm → hot)
2) Other nodes (ingest, ml, coordinating)
3) **Master nodes last, one-by-one**

> Never upgrade masters before data nodes. Never stop two masters at once.

---

## Node Upgrade Loop (Apply to Each Node One-by-One)

> Run this loop for every node in the order above.

0) **Before touching the next node, confirm health:**

```bash
GET _cat/health?v
```

1) **Disable replica allocation (recommended for data nodes; optional for masters/others):**

```bash
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": "primaries"
  }
}
```

2) **Flush before stop (recommended for data nodes):**

```bash
POST /_flush
```

3) **Back up config before upgrade (recommended):**

```bash
sudo cp -r /etc/elasticsearch /etc/elasticsearch_backup_$(date +%F)
```

4) **Stop Elasticsearch on the node:**

```bash
sudo systemctl stop elasticsearch
```

5) **Upgrade package (choose your OS)**

**DEB (Debian/Ubuntu):**

[Elasticsearch DEB docs](https://www.elastic.co/guide/en/elasticsearch/reference/8.19/deb.html)

Example:

```
<ELASTICSEARCH_VERSION> = 8.19.10
```

```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-<ELASTICSEARCH_VERSION>-amd64.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-<ELASTICSEARCH_VERSION>-amd64.deb.sha512
shasum -a 512 -c elasticsearch-<ELASTICSEARCH_VERSION>-amd64.deb.sha512
sudo dpkg -i elasticsearch-<ELASTICSEARCH_VERSION>-amd64.deb
```

**RPM (RHEL/Rocky/Alma):**

[Elasticsearch RPM docs](https://www.elastic.co/guide/en/elasticsearch/reference/8.19/rpm.html)

```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-<ELASTICSEARCH_VERSION>-x86_64.rpm
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-<ELASTICSEARCH_VERSION>-x86_64.rpm.sha512
shasum -a 512 -c elasticsearch-<ELASTICSEARCH_VERSION>-x86_64.rpm.sha512
sudo rpm -Uvh elasticsearch-<ELASTICSEARCH_VERSION>-x86_64.rpm
```

> Use the exact target version you plan. Do not use `--install` for RPM.
> If prompted about `/etc/elasticsearch/elasticsearch.yml`, choose **Keep the local version**.

6) **Upgrade plugins (only if installed on this node):**

```bash
/usr/share/elasticsearch/bin/elasticsearch-plugin list
```

Check compatibility first:

- [Elasticsearch plugins compatibility](https://www.elastic.co/guide/en/elasticsearch/plugins/current/index.html)

If you see plugins, remove + install again (same name):

```bash
/usr/share/elasticsearch/bin/elasticsearch-plugin remove <plugin_name>
/usr/share/elasticsearch/bin/elasticsearch-plugin install <plugin_name>
```

7) **Start Elasticsearch:**

```bash
sudo systemctl daemon-reload
sudo systemctl start elasticsearch
```

8) **Wait until the cluster is stable before the next node:**

```bash
GET _cat/health?v
GET _cat/shards?v=true&h=index,shard,prirep,state,node,unassigned.reason&s=state
GET _cat/recovery
```

You can watch recovery progress:

```bash
watch -n 5 'curl -s "localhost:9200/_cat/recovery?v&active_only=true"'
```

**Continue only if:**
- health = green/yellow
- primary shards are STARTED
- initializing/relocating shards = 0

9) **Re-enable allocation (after the node is stable):**

```bash
PUT _cluster/settings
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
```

---

## Master Node Order (3 Masters)

Example:

1) master-1  
2) master-3  
3) **master-2 (current active master last)**

> **Quorum warning:** in a 3-master cluster, only **one** master may be offline at a time.

Check active master:

```bash
GET _cat/master
```

---

## Final Elasticsearch Checks

```bash
GET _cat/nodes?h=name,version,master
GET _cat/health?v
GET /
```

If you see any `archived.*` settings:

```bash
GET _cluster/settings?include_defaults=true
```

`archived.*` means Elasticsearch detected **old/unsupported settings** after upgrade and ignored them.
You should remove them before moving on.

Example output (if you see this, you must clean it):

```json
{
  "persistent": {
    "archived.cluster.routing.allocation.awareness.attributes": "rack_id"
  }
}
```

Example cleanup:

```bash
PUT _cluster/settings
{
  "persistent": {
    "archived.cluster.routing.allocation.awareness.attributes": null
  }
}
```

---

# Kibana Upgrade (Must Match Elasticsearch Version)

## Rules

- **Kibana upgrades after Elasticsearch**
- **Kibana version = Elasticsearch version**
- **No rolling upgrade for Kibana** (stop all Kibana instances first)

## Stop all Kibana instances

```bash
sudo systemctl stop kibana
```

## Upgrade package

**RPM (RHEL/Rocky/Alma):**

[Kibana RPM docs](https://www.elastic.co/guide/en/kibana/8.19/rpm.html)

Example:

```
<KIBANA_VERSION> = 8.19.10
```

Backup config first:

```bash
sudo cp -r /etc/kibana /etc/kibana_backup_$(date +%F)
```

```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-<KIBANA_VERSION>-x86_64.rpm
wget https://artifacts.elastic.co/downloads/kibana/kibana-<KIBANA_VERSION>-x86_64.rpm.sha512
shasum -a 512 -c kibana-<KIBANA_VERSION>-x86_64.rpm.sha512
sudo rpm -Uvh kibana-<KIBANA_VERSION>-x86_64.rpm
```

**DEB (Debian/Ubuntu):**

[Kibana DEB docs](https://www.elastic.co/guide/en/kibana/8.19/deb.html)

```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-<KIBANA_VERSION>-amd64.deb
wget https://artifacts.elastic.co/downloads/kibana/kibana-<KIBANA_VERSION>-amd64.deb.sha512
shasum -a 512 -c kibana-<KIBANA_VERSION>-amd64.deb.sha512
sudo dpkg -i kibana-<KIBANA_VERSION>-amd64.deb
```

> If prompted about `/etc/kibana/kibana.yml`, choose **Keep the local version**.

## Upgrade Kibana plugins (if any)

```bash
/usr/share/kibana/bin/kibana-plugin list
```

If plugins exist:

```bash
/usr/share/kibana/bin/kibana-plugin remove <plugin_name>
/usr/share/kibana/bin/kibana-plugin install <plugin_name>
```

## Start Kibana and verify

```bash
sudo systemctl start kibana
```

Watch logs for migration status:

```bash
sudo journalctl -u kibana -f
```

Look for:

```
Saved object migrations completed successfully
```

Check:

```bash
GET _cat/indices/.kibana*
```

If login page opens and Kibana indices are healthy, upgrade is complete.
