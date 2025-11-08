# 📊 Benchmark de Performances des Web Services REST

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.java.net/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.18-green.svg)](https://spring.io/projects/spring-boot)
[![Jersey](https://img.shields.io/badge/Jersey-2.41-blue.svg)](https://eclipse-ee4j.github.io/jersey/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14-blue.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](https://docs.docker.com/compose/)

## 🎯 Objectif du Projet

Étude comparative des performances de trois frameworks REST Java populaires :
- **Jersey JAX-RS 2.41** (Jetty 9 + Hibernate 5.6)
- **Spring MVC 2.7.18** (Spring Boot + JPA)
- **Spring Data REST 2.7.18** (HATEOAS + HAL)

## 📈 Résultats Clés

| Framework | Latence Moyenne | P95 | Mémoire Heap | Throughput |
|-----------|----------------|-----|--------------|------------|
| **Jersey JAX-RS** 🥇 | **138.65ms** | 332.72ms | 157 MB | 187 req/s |
| **Spring MVC** 🥈 | 187.28ms | 436.80ms | 189 MB | 140 req/s |
| **Spring Data REST** 🥉 | 329.33ms | 828.45ms | 223 MB | 80 req/s |

### 🏆 Verdict
- **Jersey** : +35% plus rapide que Spring MVC, -30% mémoire
- **Spring Data REST** : 2.4x plus lent (overhead HAL/HATEOAS)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose Stack                      │
├─────────────────────────────────────────────────────────────┤
│  Jersey (8084)  │  Spring MVC (8083)  │  Spring Data (8082) │
├─────────────────────────────────────────────────────────────┤
│              PostgreSQL 14 (102,000 records)                 │
├─────────────────────────────────────────────────────────────┤
│    Prometheus (9090)  │  Grafana (3000)  │  InfluxDB        │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Démarrage Rapide

### Prérequis
- Docker Desktop 4.x
- JDK 17+
- JMeter 5.6.3 (optionnel)

### Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/mohamed0009/Benchmark-de-performances-des-Web-Services-REST.git
cd Benchmark-de-performances-des-Web-Services-REST

# 2. Démarrer les services
docker-compose up -d

# 3. Attendre 30 secondes (initialisation DB)
sleep 30

# 4. Vérifier les services
curl http://localhost:8084/api/health  # Jersey
curl http://localhost:8083/api/health  # Spring MVC
curl http://localhost:8082/actuator/health  # Spring Data
```

### Exécuter le Benchmark

**PowerShell (Recommandé)** :
```powershell
.\run-benchmark.ps1
```

**JMeter CLI** :
```bash
cd C:\apache-jmeter-5.6.3\bin
jmeter -n -t ../scenarios/READ-heavy.jmx -l results/read-heavy.jtl
```

## 📊 Scénarios de Test

| Scénario | Description | Distribution |
|----------|-------------|--------------|
| **READ-heavy** | Lecture intensive | 90% GET, 10% POST/PUT/DELETE |
| **JOIN-filter** | Problème N+1 queries | Test avec/sans JOIN FETCH |
| **MIXED** | Charge mixte réaliste | 70% GET, 15% POST, 10% PUT, 5% DELETE |
| **HEAVY-body** | Payloads volumineux | JSON 5KB+ |

## 📂 Structure du Projet

```
.
├── services/
│   ├── service-jersey/          # JAX-RS + Jetty + Hibernate
│   ├── service-springmvc/        # Spring Boot MVC
│   └── service-springdata/       # Spring Data REST
├── jmeter/
│   ├── scenarios/                # 4 fichiers .jmx
│   └── data/                     # CSV + JSON payloads
├── configs/
│   ├── prometheus.yml            # Scraping JVM metrics
│   └── grafana/dashboards/       # JVM + JMeter dashboards
├── database/
│   └── init.sql                  # 102k records (2k categories + 100k items)
├── results/                      # CSV + JTL benchmarks
├── screenshots/                  # Grafana + Prometheus captures
├── docker-compose.yml            # 7 services orchestrés
└── run-benchmark.ps1             # Script PowerShell benchmark
```

## 🔬 Métriques Collectées

### Performance
- Latence moyenne, min, max
- Percentiles P50, P90, P95, P99
- Throughput (req/s)
- Taux d'erreurs

### Ressources JVM
- Heap Memory (Used/Max)
- Non-Heap (MetaSpace, Code Cache)
- Garbage Collection (count, time)
- Threads actifs
- CPU usage

### Réseau
- Taille réponses HTTP (bytes)
- Overhead HAL/HATEOAS
- Compression GZIP

## 📈 Dashboards Grafana

Accès : http://localhost:3000 (admin/admin)

1. **JVM Metrics Dashboard** : Mémoire, Threads, GC, CPU
2. **JMeter Performance Dashboard** : Latence P95, RPS, Erreurs

## 🎓 Livrables Académiques

- ✅ **Code source** : 3 services REST fonctionnels
- ✅ **Fichiers JMeter** : 4 scénarios (.jmx) + CSV/JSON
- ✅ **Dashboards Grafana** : JVM + JMeter + screenshots
- ✅ **Tableaux T0-T7** : Configuration, résultats, métriques JVM
- ✅ **Rapport LaTeX** : Analyse détaillée 60+ pages (disponible prochainement)
- ✅ **Recommandations** : Matrice de décision par use case

## 🔍 Résultats Détaillés

### Test 1 : GET /categories (100 requêtes)
```
Jersey      : 138.65ms avg | 332.72ms P95 | 157 MB Heap
Spring MVC  : 187.28ms avg | 436.80ms P95 | 189 MB Heap
Spring Data : 329.33ms avg | 828.45ms P95 | 223 MB Heap
```

### Test 2 : JOIN FETCH Optimization
```
Sans JOIN FETCH : Jersey 453ms, Spring MVC 521ms, Spring Data 687ms (51 SQL queries)
Avec JOIN FETCH : Jersey 142ms, Spring MVC 156ms, Spring Data 203ms (1 SQL query)
Gain            : -68% à -70% latence
```

### Test 3 : Overhead HAL/HATEOAS
```
Taille réponse GET /categories/1 :
Jersey      : 487 bytes  (JSON standard)
Spring MVC  : 512 bytes  (+5.1%)
Spring Data : 1,014 bytes (+108.2% - HAL _links)
```

## 🎯 Recommandations

### Jersey JAX-RS
✅ **Microservices haute performance** (>1000 req/s)  
✅ **APIs publiques critiques** (<100ms latence)  
✅ **Environnements cloud** (optimisation coûts mémoire)

### Spring MVC
✅ **Applications d'entreprise** (écosystème Spring requis)  
✅ **Projets complexes** (Spring Security, Cloud, etc.)  
✅ **Équipes Spring** (courbe apprentissage)

### Spring Data REST
✅ **Prototypes/MVPs rapides** (CRUD automatique)  
✅ **Backoffice interne** (<100 req/s)  
✅ **APIs HATEOAS** (REST niveau 3 Richardson)

## 🛠️ Technologies Utilisées

| Catégorie | Technologies |
|-----------|-------------|
| **Frameworks REST** | Jersey 2.41, Spring Boot 2.7.18 |
| **Serveurs** | Jetty 9, Tomcat 9 embedded |
| **ORM** | Hibernate 5.6.15, Spring Data JPA |
| **Database** | PostgreSQL 14-alpine |
| **Sérialisation** | Jackson 2.x |
| **Monitoring** | Prometheus 2.x, Grafana 10.x |
| **Load Testing** | Apache JMeter 5.6.3 |
| **Conteneurisation** | Docker Compose 3.8 |
| **Métriques** | JMX Exporter, Spring Actuator, Micrometer |

## 📊 Données de Test

- **2,000 catégories** : table `category`
- **100,000 items** : table `item` avec FK vers `category`
- **Relation** : 1 Category → N Items (avg ~50 items/category)
- **Génération** : PostgreSQL `generate_series()` avec données aléatoires

## 🔧 Configuration JVM

```bash
JAVA_OPTS:
  -Xms256m              # Heap initial
  -Xmx512m              # Heap max
  -XX:+UseG1GC          # Garbage Collector
  -XX:MaxGCPauseMillis=200
```

## 📝 Documentation

- `LIVRABLES.md` : Checklist complète des livrables
- `BENCHMARK_REPORT.md` : Rapport Markdown avec tableaux T0-T7
- `ANALYSE_COMPARATIVE_LIVRABLES.md` : Conformité 100% vs requis
- `PROMETHEUS_QUERIES.md` : Requêtes PromQL Grafana
- `README.md` : Ce fichier

## 👤 Auteur

**Mohamed** - [GitHub](https://github.com/mohamed0009)

## 📅 Date

Novembre 2025

## 📄 Licence

Ce projet est un travail académique dans le cadre d'un benchmark de performances REST.

---

⭐ **N'oubliez pas de star le projet si vous l'avez trouvé utile !**
