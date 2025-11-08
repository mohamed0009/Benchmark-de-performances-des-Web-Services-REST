#  Benchmark de Performances des Web Services REST

> Étude comparative de performances entre JAX-RS (Jersey), Spring MVC et Spring Data REST

---

##  Objectifs du Projet

Évaluer et comparer les performances de **trois approches REST** différentes :
- **Service A** : JAX-RS (Jersey) + JPA/Hibernate
- **Service C** : Spring Boot + @RestController + JPA/Hibernate  
- **Service D** : Spring Boot + Spring Data REST (HAL)

**Critères d''évaluation** :
- Temps de réponse (p50, p95, p99)
- Throughput (requêtes/seconde)
- Consommation mémoire (Heap, GC)
- CPU usage
- Efficacité HikariCP (connexions DB)
- Impact du problème N+1 (avec/sans JOIN FETCH)

---

##  Structure du Projet

```
Benchmark-REST/
 services/
    service-jersey/       # JAX-RS + JPA
    service-springmvc/    # Spring MVC + JPA
    service-springdata/   # Spring Data REST
 database/
    init.sql              # 2,000 categories + 100,000 items
 jmeter/
    scenarios/            # 4 scénarios de test
    data/                 # CSV + JSON payloads
 configs/
    prometheus.yml
    grafana/
        dashboards/       # JVM + JMeter dashboards
        datasources/
 docker-compose.yml        # Stack complet (7 services)
 QUICKSTART.md            # Guide démarrage rapide
```

---

##  Démarrage Rapide

### Prérequis
- Docker Desktop + Docker Compose
- Apache JMeter 5.6+
- Java 17+ (pour compilation locale)
- 8 GB RAM minimum

### Lancement du Stack

```bash
# 1. Build & démarrer tous les services
docker-compose up -d --build

# 2. Vérifier les services
docker-compose ps

# 3. Accéder aux interfaces
# - Jersey:      http://localhost:8080/api/categories
# - Spring MVC:  http://localhost:8081/api/categories
# - Spring Data: http://localhost:8082/api/categories
# - Prometheus:  http://localhost:9091
# - Grafana:     http://localhost:3000 (admin/admin)
# - InfluxDB:    http://localhost:8086

# 4. Exécuter les tests JMeter
cd jmeter
jmeter -n -t scenarios/READ-heavy.jmx -l results/read-heavy.jtl

# 5. Arrêter
docker-compose down
```

**Scripts disponibles** :
- `build_services.bat` - Compilation Maven
- `start_services.bat` - Démarrage Docker
- `test_services.bat` - Tests JMeter
- `stop_services.bat` - Arrêt propre

---

##  Architecture Technique

### Modèle de Données

**Relations** : `Category` (1)  (N) `Item`

| Entity   | Fields                                      |
|----------|---------------------------------------------|
| Category | id, code, name, updated_at, items[]        |
| Item     | id, sku, name, price, stock, category_id, updated_at |

**Volume de données** :
- 2,000 catégories (CAT0001  CAT2000)
- 100,000 items (~50 items/catégorie)
- Distribution aléatoire via `generate_series()`

### Stack Technologique

| Service       | Technologie                    | Ports       |
|---------------|--------------------------------|-------------|
| PostgreSQL    | 14-alpine                      | 5432        |
| Jersey        | JAX-RS 2.41 + Jetty 11 + JPA  | 8080, 9090  |
| Spring MVC    | Spring Boot 2.7.18 + JPA      | 8081, 8091  |
| Spring Data   | Spring Boot + Data REST        | 8082, 8092  |
| Prometheus    | Latest                         | 9091        |
| Grafana       | Latest                         | 3000        |
| InfluxDB      | 2.7-alpine                     | 8086        |

**Configuration commune** :
- Java 17 (eclipse-temurin)
- HikariCP : `minimumIdle=10`, `maximumPoolSize=20`
- Caches désactivés : `use_second_level_cache=false`
- JPA : `open-in-view=false`

---

##  Tables de Résultats (T0-T7)

### T0 : Configuration des Services

| Service      | Framework        | Port | Pool DB    | Cache | Java |
|--------------|------------------|------|------------|-------|------|
| service-jersey | JAX-RS 2.41    | 8080 | 10-20      | OFF   | 17   |
| service-springmvc | Spring MVC  | 8081 | 10-20      | OFF   | 17   |
| service-springdata | Data REST  | 8082 | 10-20      | OFF   | 17   |

### T1 : Endpoints REST Implémentés

| Endpoint                     | Jersey | Spring MVC | Spring Data |
|------------------------------|--------|------------|-------------|
| GET /categories              |      |          |           |
| GET /categories/{id}         |      |          |           |
| GET /categories/{id}/items   |      |          |           |
| POST /categories             |      |          |           |
| PUT /categories/{id}         |      |          |           |
| DELETE /categories/{id}      |      |          |           |
| GET /items                   |      |          |           |
| GET /items?categoryId=       |      |          |           |
| GET /items/{id}              |      |          |           |
| POST /items                  |      |          |           |
| PUT /items/{id}              |      |          |           |
| DELETE /items/{id}           |      |          |           |

**Total** : 15+ endpoints par service

### T2 : Scénarios JMeter

| Scénario     | Description                              | Threads | Durée |
|--------------|------------------------------------------|---------|-------|
| READ-heavy   | 50% items list, 20% by cat, 20% catitems | 50-200 | 5 min |
| JOIN-filter  | 70% items?categoryId=, 30% item by id    | 50-200 | 5 min |
| MIXED        | GET/POST/PUT/DELETE (70/15/10/5)         | 50-200 | 5 min |
| HEAVY-body   | POST/PUT avec payloads 1KB-5KB           | 50-200 | 5 min |

**Variables de contrôle** :
- `USE_JOIN_FETCH=true/false` (mode anti-N+1)
- Pagination : `?page=0&size=20`

### T3 : Métriques JVM (exemple à remplir)

| Service       | Heap Max | Heap Avg | GC Count | GC Time | CPU Avg |
|---------------|----------|----------|----------|---------|---------|
| Jersey        | ___ MB   | ___ MB   | ___      | ___ ms  | ___ %   |
| Spring MVC    | ___ MB   | ___ MB   | ___      | ___ ms  | ___ %   |
| Spring Data   | ___ MB   | ___ MB   | ___      | ___ ms  | ___ %   |

**Source** : Prometheus + Grafana (Dashboard JVM)

### T4 : Performances READ-heavy (exemple)

| Service       | RPS   | p50 (ms) | p95 (ms) | p99 (ms) | Errors |
|---------------|-------|----------|----------|----------|--------|
| Jersey        | ___   | ___      | ___      | ___      | ___    |
| Spring MVC    | ___   | ___      | ___      | ___      | ___    |
| Spring Data   | ___   | ___      | ___      | ___      | ___    |

### T5 : Impact N+1 (avec/sans JOIN FETCH)

| Service       | Mode       | RPS   | p95 (ms) | DB Queries |
|---------------|------------|-------|----------|------------|
| Jersey        | Baseline   | ___   | ___      | ___        |
| Jersey        | JOIN FETCH | ___   | ___      | ___        |
| Spring MVC    | Baseline   | ___   | ___      | ___        |
| Spring MVC    | JOIN FETCH | ___   | ___      | ___        |

### T6 : HikariCP Utilisation

| Service       | Active Avg | Idle Avg | Waiting Threads | Timeouts |
|---------------|------------|----------|-----------------|----------|
| Jersey        | ___        | ___      | ___             | ___      |
| Spring MVC    | ___        | ___      | ___             | ___      |
| Spring Data   | ___        | ___      | ___             | ___      |

### T7 : Analyse Comparative

| Critère                  |  Meilleur |  Moyen |  Moins bon |
|--------------------------|-------------|----------|--------------|
| Temps de réponse         | ___         | ___      | ___          |
| Throughput               | ___         | ___      | ___          |
| Consommation mémoire     | ___         | ___      | ___          |
| Simplicité développement | ___         | ___      | ___          |
| Taille payload (HAL)     | ___         | ___      | ___          |

---

##  Méthodologie de Test

### 1. Préparation
```bash
# Démarrer le stack
docker-compose up -d --build

# Attendre que PostgreSQL charge les 100k rows
docker-compose logs -f postgres | grep "database system is ready"
```

### 2. Warmup
```bash
# 2 minutes de warmup pour JIT compilation
jmeter -n -t scenarios/READ-heavy.jmx -l warmup.jtl -Jthreads=10 -Jduration=120
```

### 3. Tests Baseline (sans JOIN FETCH)
```bash
docker-compose restart service-jersey service-springmvc service-springdata

# Pour chaque scénario
jmeter -n -t scenarios/READ-heavy.jmx -l results/read-baseline.jtl -Jthreads=100
jmeter -n -t scenarios/JOIN-filter.jmx -l results/join-baseline.jtl -Jthreads=100
jmeter -n -t scenarios/MIXED.jmx -l results/mixed-baseline.jtl -Jthreads=100
```

### 4. Tests avec JOIN FETCH
```bash
# Activer JOIN FETCH
docker-compose down
export USE_JOIN_FETCH=true  # ou modifier docker-compose.yml
docker-compose up -d

# Répéter les tests
jmeter -n -t scenarios/READ-heavy.jmx -l results/read-joinf
etch.jtl -Jthreads=100
```

### 5. Collecte des Métriques
- **Grafana** : Exporter les dashboards JVM et JMeter
- **Prometheus** : Requêtes pour CPU, Heap, GC
- **InfluxDB** : Métriques JMeter (RPS, latence)
- **Logs Docker** : `docker-compose logs > full-logs.txt`

---

##  Analyse des Résultats

### Points Clés à Analyser

**1. Problème N+1**
```sql
-- Sans JOIN FETCH : 1 + N queries
SELECT * FROM category WHERE id = ?;
SELECT * FROM item WHERE category_id = ?;  -- répété N fois
SELECT * FROM item WHERE category_id = ?;
...

-- Avec JOIN FETCH : 1 query
SELECT c.*, i.* FROM category c LEFT JOIN item i ON c.id = i.category_id WHERE c.id = ?;
```

**2. Taille des Payloads HAL (Spring Data REST)**
```json
{
  "_embedded": { ... },
  "_links": { "self", "next", "prev" },
  "page": { "size", "totalElements", "totalPages" }
}
```
 Overhead de 30-50% vs JSON standard

**3. Impact Pagination**
- `OFFSET` vs Keyset pagination
- Performance avec `LIMIT 20` vs `LIMIT 100`

**4. HikariCP Bottlenecks**
- Threads en attente > 0  Pool trop petit
- Connections actives = max  Saturation

---

##  Dashboards Grafana

### Dashboard JVM
- **Memory** : Heap Used/Max, Non-Heap, GC Rate
- **Threads** : Total, Daemon, Peak
- **CPU** : Process vs System load
- **HikariCP** : Active/Idle/Total connections, Wait time

### Dashboard JMeter
- **Throughput** : Requests/sec par service
- **Latency** : p50, p95, p99 percentiles
- **Errors** : Rate d''erreur par endpoint
- **Active Users** : Threads actifs dans le temps

**Accès** : http://localhost:3000/dashboards

---

##  Troubleshooting

### Problème : PostgreSQL ne charge pas les données
```bash
# Vérifier les logs
docker-compose logs postgres

# Réinitialiser
docker-compose down -v
docker-compose up -d postgres
```

### Problème : Services ne démarrent pas
```bash
# Vérifier les ports occupés
netstat -ano | findstr "8080 8081 8082"

# Rebuild avec logs
docker-compose up --build --force-recreate
```

### Problème : JMeter errors 500
```bash
# Vérifier que les données sont chargées
docker exec -it benchmark-postgres psql -U benchmark_user -d benchmark_db -c "SELECT COUNT(*) FROM item;"

# Devrait retourner : 100000
```

### Problème : Prometheus ne scrape pas
```bash
# Tester les endpoints manuellement
curl http://localhost:9090/metrics  # Jersey JMX
curl http://localhost:8091/actuator/prometheus  # Spring MVC
curl http://localhost:8092/actuator/prometheus  # Spring Data
```

---

##  Livrables Attendus

### 1. Code Source
-  3 services REST fonctionnels
-  DAOs/Repositories avec JOIN FETCH
-  Configuration HikariCP optimisée
-  Docker Compose complet

### 2. Tests JMeter
-  4 scénarios (.jmx)
-  Fichiers CSV de données
-  Configuration Backend Listener InfluxDB

### 3. Monitoring
-  Prometheus scraping 3 services
-  2 dashboards Grafana (JVM + JMeter)
-  InfluxDB configuré

### 4. Résultats
- Tables T0-T7 remplies avec données réelles
- Graphiques Grafana exportés (PNG/JSON)
- Analyse comparative écrite
- Recommandations par use case

### 5. Documentation
-  README.md complet
-  QUICKSTART.md
-  Scripts de lancement (.bat)
- Guide de troubleshooting

---

##  Recommandations par Use Case

### Use Case 1 : API Interne Simple
** JAX-RS (Jersey)**
- Meilleure performance brute
- Contrôle total sur les endpoints
- Moins de "magie" framework
- Idéal pour microservices légers

### Use Case 2 : Application d''Entreprise
** Spring MVC**
- Écosystème riche (Security, Batch, etc.)
- Bonne balance performance/productivité
- Support long-terme
- Standard de facto Java

### Use Case 3 : Prototypage Rapide
** Spring Data REST**
- Zéro code pour CRUD
- HAL auto-généré
- Idéal pour POC/MVP
- Attention au payload overhead

### Use Case 4 : Haute Performance
** JAX-RS avec optimisations**
- JOIN FETCH systématique
- DTOs au lieu d''entités JPA
- Cache Redis externe
- Connection pooling agressif

---

##  Références

### Documentation
- [JAX-RS 2.1 Spec](https://jakarta.ee/specifications/restful-ws/2.1/)
- [Spring MVC Reference](https://docs.spring.io/spring-framework/docs/current/reference/html/web.html)
- [Spring Data REST](https://docs.spring.io/spring-data/rest/docs/current/reference/html/)
- [JMeter User Manual](https://jmeter.apache.org/usermanual/index.html)
- [Prometheus Docs](https://prometheus.io/docs/introduction/overview/)

### Articles Recommandés
- **N+1 Problem** : https://vladmihalcea.com/n-plus-1-query-problem/
- **HikariCP Sizing** : https://github.com/brettwooldridge/HikariCP/wiki/About-Pool-Sizing
- **JVM Tuning** : https://docs.oracle.com/en/java/javase/17/gctuning/

---

##  Auteurs & Licence

**Étude technique de performance**  
Architecture des Services Web REST

**Date** : Novembre 2025

---

##  Checklist Finale

Avant soumission, vérifier :

- [ ] Docker Compose lance les 7 services
- [ ] PostgreSQL contient 100,000 items
- [ ] Les 3 services REST répondent
- [ ] Prometheus scrape les 3 services
- [ ] Grafana affiche les 2 dashboards
- [ ] JMeter exécute les 4 scénarios
- [ ] Tables T0-T7 remplies avec données
- [ ] README.md complet et clair
- [ ] Code source commenté et propre
- [ ] Scripts .bat fonctionnels

**Bonne chance! **