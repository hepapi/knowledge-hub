# Elasticsearch `http.p12` Certificate Renewal

This document explains how to renew only the **HTTP layer** `http.p12` certificate in a **3-node self-managed Elasticsearch cluster**.

This procedure:

- Is only for `http.p12`
- Is not for `transport.p12`
- Must be done **one node at a time**
- Must follow a **rolling** approach
- Reuses the current CA to create a new `http.p12`

## References

- Medium: <https://medium.com/@ashishofficial47_85130/how-we-renewed-our-expired-elasticsearch-self-signed-certificate-without-breaking-everything-f269292b2a7c>
- Elastic Docs, Update TLS certificates: <https://www.elastic.co/docs/deploy-manage/security/updating-certificates>
- Elastic Docs, Set up HTTPS: <https://www.elastic.co/docs/deploy-manage/security/set-up-basic-security-plus-https>

## Important Notes

- This method works only if `http_ca.crt` is still valid.
- If `http_ca.crt` is also expired, you need a CA rotation. This guide is not enough by itself.
- Keep the file name as `http.p12`.
- Using the same keystore password makes the update easier.

## Information Needed For Each Node

- VM hostname: `<vm-hostname>`
- VM private IP: `<vm-private-ip>`
- `elastic` user password: `<elastic-password>`

Example paths used in this guide:

- Cert directory: `/etc/elasticsearch/certs`
- Elasticsearch home: `/usr/share/elasticsearch`
- `keytool`: `/usr/share/elasticsearch/jdk/bin/keytool`

## Recommended Order

1. Update `node-1`.
2. Restart the service and verify health.
3. When the cluster is healthy again, repeat on `node-2`.
4. Repeat the same for `node-3`.

## Steps For Each Node

Run all commands on the target node.

### 1. Get the current `http.p12` password

```bash
/usr/share/elasticsearch/bin/elasticsearch-keystore show xpack.security.http.ssl.keystore.secure_password
```

Save this value. You will use the same password in the next steps.

### 2. Check certificate dates

Check the certificate inside `http.p12`. Replace `YOUR_HTTP_P12_PASSWORD` with the password from step 1:

```bash
/usr/share/elasticsearch/jdk/bin/keytool -list -v \
  -keystore /etc/elasticsearch/certs/http.p12 \
  -storepass 'YOUR_HTTP_P12_PASSWORD' | grep -E "Alias name:|Valid from:"
```

Check the `http_ca.crt` end date:

```bash
openssl x509 -in /etc/elasticsearch/certs/http_ca.crt -noout -enddate
```

You can also check certificates through the Elasticsearch API:

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:<elastic-password> \
  https://localhost:9200/_ssl/certificates?pretty
```

### 3. Back up the `certs` directory

```bash
cd /etc/elasticsearch/certs
BACKUP_DIR="/etc/elasticsearch/certs_backup_$(date +%F_%H%M%S)"
cp -a /etc/elasticsearch/certs "${BACKUP_DIR}"
```

### 4. Verify `keytool` access

In most cases Elasticsearch already includes its own JDK:

```bash
/usr/share/elasticsearch/jdk/bin/keytool -help >/dev/null
```

If `keytool` is not available:

```bash
apt-get update
apt-get install -y openjdk-17-jre-headless unzip
```

### 5. Extract the CA from `http.p12`

This step does not create the new HTTP certificate yet. It first exports the `http_ca` alias from the current `http.p12` into a separate `.p12` file:

```bash
cd /etc/elasticsearch/certs
/usr/share/elasticsearch/jdk/bin/keytool -importkeystore \
  -srckeystore http.p12 \
  -destkeystore http_ca.p12 \
  -srcalias http_ca
```

When prompted:

- Source keystore password: password from step 1
- Destination keystore password: password from step 1

### 6. Generate a new HTTP certificate

```bash
cd /usr/share/elasticsearch
./bin/elasticsearch-certutil http
```

Use these answers:

- `Generate a CSR?` -> `n`
- `Use an existing CA?` -> `y`
- `CA path` -> `/etc/elasticsearch/certs/http_ca.p12`
- `CA password` -> password from step 1
- `Validity period` -> for example `5y`
- `Generate a certificate per node?` -> `n`

Because this guide updates one node at a time, use `n` here.

For hostname / DNS values, enter:

- `elasticsearch`
- `localhost`
- `<vm-hostname>`

Then answer `Y` to `Is this correct [Y/n]`.

For IP values, enter:

- `<vm-private-ip>`
- `127.0.0.1`

Then answer:

- `Do you wish to change any of these options? [y/N]` -> `N`
- Private key / keystore password -> password from step 1

At the end, the command creates a `.zip` file.

### 7. Unzip the output file

```bash
mkdir -p /tmp/es-http-cert-update
unzip elasticsearch-ssl-http.zip -d /tmp/es-http-cert-update
```

The new file is usually here:

```bash
/tmp/es-http-cert-update/elasticsearch/http.p12
```

### 8. Replace the old `http.p12`

First confirm that the file exists:

```bash
ls -l /tmp/es-http-cert-update/elasticsearch/http.p12
```

Then copy it over the old file:

```bash
cp /tmp/es-http-cert-update/elasticsearch/http.p12 /etc/elasticsearch/certs/http.p12
```

Fix ownership and permissions:

```bash
chown elasticsearch:elasticsearch /etc/elasticsearch/certs/http.p12
chmod 750 /etc/elasticsearch/certs/http.p12
```

### 9. Restart Elasticsearch

```bash
systemctl restart elasticsearch
```

Optional status check:

```bash
systemctl status elasticsearch --no-pager
```

### 10. Verify service and cluster health

Check local HTTPS access:

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:<elastic-password> \
  https://localhost:9200/_cluster/health?pretty
```

Check the new certificate end date again:

```bash
openssl pkcs12 -in /etc/elasticsearch/certs/http.p12 -clcerts -nokeys | openssl x509 -noout -enddate
```

## Short Operation Summary

Repeat this flow for each node:

1. Check certificate dates.
2. Back up the `certs` directory.
3. Create `http_ca.p12`.
4. Generate a new `http.p12`.
5. Replace the old file.
6. Restart Elasticsearch.
7. Verify with `curl`.
8. Move to the next node.

## Things To Watch

- Do not use this method if `http_ca.crt` is expired.
- Do not restart multiple nodes at the same time.
- This procedure does not change `transport.p12`.
- The new file name must stay `http.p12`.
- If you change the password, you must also update the secure setting in the Elasticsearch keystore.
