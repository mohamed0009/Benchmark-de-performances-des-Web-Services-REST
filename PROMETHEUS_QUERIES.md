# 📊 Guide Prometheus - Requêtes Utiles

## 🔗 Accès Prometheus
- **Interface Web**: http://localhost:9091
- **Targets (Status)**: http://localhost:9091/targets
- **Grafana Dashboard**: http://localhost:3001/d/01526621-ec66-472e-9198-283d86d2fba7/

---

## 📈 Requêtes PromQL par Catégorie

### 🧠 MÉMOIRE JVM

#### Mémoire Heap utilisée (tous services)
```promql
jvm_memory_bytes_used{area="heap"}
```

#### Mémoire Heap par service
```promql
jvm_memory_bytes_used{job="jersey", area="heap"}
jvm_memory_bytes_used{job="springmvc", area="heap"}
jvm_memory_bytes_used{job="springdata", area="heap"}
```

#### Mémoire en MB (conversion)
```promql
jvm_memory_bytes_used{area="heap"} / 1024 / 1024
```

#### Mémoire Non-Heap
```promql
jvm_memory_bytes_used{area="nonheap"}
```

---

### 🌐 REQUÊTES HTTP (Spring Services)

#### Total des requêtes HTTP (Spring MVC)
```promql
sum(http_server_requests_seconds_count{application="springmvc"})
```

#### Total des requêtes HTTP (Spring Data)
```promql
sum(http_server_requests_seconds_count{application="springdata"})
```

#### Taux de requêtes par seconde (Rate sur 1 minute)
```promql
rate(http_server_requests_seconds_count{application="springmvc"}[1m])
```

#### Requêtes par URI
```promql
http_server_requests_seconds_count{application="springmvc", uri="/api/categories"}
```

#### Requêtes par status code
```promql
http_server_requests_seconds_count{status="200"}
http_server_requests_seconds_count{status="500"}
```

---

### ⏱️ LATENCE / TEMPS DE RÉPONSE

#### Temps de réponse moyen (Spring MVC)
```promql
rate(http_server_requests_seconds_sum{application="springmvc"}[5m]) / 
rate(http_server_requests_seconds_count{application="springmvc"}[5m])
```

#### Latence P50 (médiane)
```promql
histogram_quantile(0.5, rate(http_server_requests_seconds_bucket[5m]))
```

#### Latence P95
```promql
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))
```

#### Latence P99
```promql
histogram_quantile(0.99, rate(http_server_requests_seconds_bucket[5m]))
```

---

### 🧵 THREADS

#### Nombre de threads actifs
```promql
jvm_threads_current
```

#### Threads par état
```promql
jvm_threads_states_threads{state="runnable"}
jvm_threads_states_threads{state="waiting"}
jvm_threads_states_threads{state="blocked"}
```

---

### 🗑️ GARBAGE COLLECTION

#### Nombre de GC
```promql
jvm_gc_collection_seconds_count
```

#### Temps total de GC (secondes)
```promql
jvm_gc_collection_seconds_sum
```

#### Taux de GC par seconde
```promql
rate(jvm_gc_collection_seconds_count[1m])
```

---

### 📚 CLASSES JVM

#### Classes actuellement chargées
```promql
jvm_classes_currently_loaded
```

#### Total des classes chargées
```promql
jvm_classes_loaded_total
```

#### Classes déchargées
```promql
jvm_classes_unloaded_total
```

---

### 💾 BASE DE DONNÉES (HikariCP - Spring)

#### Connexions actives
```promql
hikaricp_connections_active
```

#### Connexions en attente
```promql
hikaricp_connections_pending
```

#### Pool de connexions total
```promql
hikaricp_connections
```

#### Timeout de connexion
```promql
hikaricp_connections_timeout_total
```

---

### 🔥 TOMCAT (Spring Services)

#### Sessions actives
```promql
tomcat_sessions_active_current_sessions
```

#### Threads Tomcat
```promql
tomcat_threads_current_threads
tomcat_threads_busy_threads
```

---

## 🎯 REQUÊTES DE COMPARAISON

### Comparer la mémoire des 3 services
```promql
jvm_memory_bytes_used{area="heap"} / 1024 / 1024
```

### Comparer le nombre de requêtes HTTP
```promql
sum by (application) (http_server_requests_seconds_count)
```

### Comparer les threads
```promql
jvm_threads_current
```

### Comparer les GC
```promql
sum by (job) (rate(jvm_gc_collection_seconds_count[5m]))
```

---

## 💡 TIPS

### 1. **Utiliser des labels pour filtrer**
```promql
{job="jersey"}
{application="springmvc"}
{area="heap"}
{status="200"}
```

### 2. **Agrégations utiles**
```promql
sum(metric)           # Somme
avg(metric)           # Moyenne
max(metric)           # Maximum
min(metric)           # Minimum
count(metric)         # Comptage
```

### 3. **Grouper par label**
```promql
sum by (job) (jvm_memory_bytes_used)
avg by (application) (http_server_requests_seconds_count)
```

### 4. **Rate pour les counters**
```promql
rate(metric[1m])      # Taux par seconde sur 1 minute
rate(metric[5m])      # Taux par seconde sur 5 minutes
```

---

## 🚀 EXEMPLES PRATIQUES

### Trouver le service le plus gourmand en mémoire
```promql
topk(3, jvm_memory_bytes_used{area="heap"})
```

### Détecter les erreurs HTTP
```promql
http_server_requests_seconds_count{status=~"5.."}
```

### Calculer le throughput total
```promql
sum(rate(http_server_requests_seconds_count[1m]))
```

### Voir l'évolution de la mémoire sur 1h
```promql
jvm_memory_bytes_used{area="heap"}[1h]
```

---

## 📊 COMMENT UTILISER CES REQUÊTES

1. **Ouvrez Prometheus**: http://localhost:9091
2. **Copiez une requête** ci-dessus
3. **Collez dans le champ "Expression"**
4. **Cliquez "Execute"**
5. **Choisissez l'onglet**:
   - **Table**: Valeurs actuelles
   - **Graph**: Évolution dans le temps

---

## 🔗 LIENS UTILES

- **Prometheus UI**: http://localhost:9091
- **Targets Status**: http://localhost:9091/targets
- **Jersey JMX**: http://localhost:9090/metrics
- **Spring MVC Actuator**: http://localhost:8091/actuator/prometheus
- **Spring Data Actuator**: http://localhost:8092/actuator/prometheus
- **Grafana**: http://localhost:3001 (admin / admin123)
- **Dashboard**: http://localhost:3001/d/01526621-ec66-472e-9198-283d86d2fba7/
