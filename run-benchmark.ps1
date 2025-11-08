# 📊 Script de Benchmark Automatisé (sans JMeter)
# Exécute des tests de charge sur les 3 services REST

param(
    [int]$Requests = 100,
    [int]$Concurrency = 1,
    [switch]$Verbose
)

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║    🚀 BENCHMARK REST API - PowerShell Load Test       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Configuration
$services = @(
    @{Name="Jersey"; URL="http://localhost:8084/api/categories?page=0&size=10"; Port=8084}
    @{Name="Spring MVC"; URL="http://localhost:8083/api/categories?page=0&size=10"; Port=8083}
    @{Name="Spring Data REST"; URL="http://localhost:8082/api/categories?page=0&size=10"; Port=8082}
)

$results = @()

# Vérification des services
Write-Host "`n📡 Vérification des services..." -ForegroundColor Yellow
foreach($svc in $services) {
    try {
        $response = Invoke-WebRequest -Uri $svc.URL -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ $($svc.Name) - UP (Port $($svc.Port))" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ $($svc.Name) - DOWN" -ForegroundColor Red
        Write-Host "      Erreur: $($_.Exception.Message)" -ForegroundColor Gray
        exit 1
    }
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "`n🔥 Démarrage des tests ($Requests requêtes par service)" -ForegroundColor Cyan
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

# Boucle sur chaque service
foreach($svc in $services) {
    Write-Host "`n🎯 Test: $($svc.Name)" -ForegroundColor Yellow
    Write-Host "   URL: $($svc.URL)" -ForegroundColor Gray
    
    $times = @()
    $errors = 0
    $totalBytes = 0
    
    # Warmup (5 requêtes)
    Write-Host "   🔥 Warmup..." -ForegroundColor Gray -NoNewline
    for($i=1; $i -le 5; $i++) {
        try {
            Invoke-WebRequest -Uri $svc.URL -UseBasicParsing | Out-Null
        } catch { }
    }
    Write-Host " OK" -ForegroundColor Green
    
    # Tests réels
    Write-Host "   📊 Exécution: " -ForegroundColor Gray -NoNewline
    $globalStart = Get-Date
    
    for($i=1; $i -le $Requests; $i++) {
        try {
            $start = Get-Date
            $response = Invoke-WebRequest -Uri $svc.URL -UseBasicParsing
            $end = Get-Date
            
            $elapsed = ($end - $start).TotalMilliseconds
            $times += $elapsed
            $totalBytes += $response.RawContentLength
            
            # Affichage progression
            if ($i % 20 -eq 0) {
                Write-Host "$i " -ForegroundColor Cyan -NoNewline
            }
            
        } catch {
            $errors++
            if ($Verbose) {
                Write-Host "`n   ⚠️  Erreur requête $i : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    $globalEnd = Get-Date
    $totalDuration = ($globalEnd - $globalStart).TotalSeconds
    
    Write-Host "`n   ✅ Terminé!" -ForegroundColor Green
    
    # Calculs statistiques
    $avg = ($times | Measure-Object -Average).Average
    $min = ($times | Measure-Object -Minimum).Minimum
    $max = ($times | Measure-Object -Maximum).Maximum
    $sorted = $times | Sort-Object
    $p50 = $sorted[[math]::Floor($sorted.Count * 0.50)]
    $p90 = $sorted[[math]::Floor($sorted.Count * 0.90)]
    $p95 = $sorted[[math]::Floor($sorted.Count * 0.95)]
    $p99 = $sorted[[math]::Floor($sorted.Count * 0.99)]
    $throughput = $Requests / $totalDuration
    $avgKB = ($totalBytes / $Requests) / 1KB
    
    # Affichage résultats
    Write-Host "`n   📈 RÉSULTATS:" -ForegroundColor Cyan
    Write-Host "      ├─ Requêtes réussies : $($Requests - $errors)/$Requests" -ForegroundColor White
    Write-Host "      ├─ Erreurs          : $errors" -ForegroundColor $(if($errors -gt 0){"Red"}else{"White"})
    Write-Host "      ├─ Durée totale     : $([math]::Round($totalDuration, 2)) s" -ForegroundColor White
    Write-Host "      ├─ Throughput       : $([math]::Round($throughput, 2)) req/s" -ForegroundColor Green
    Write-Host "      ├─ Taille moyenne   : $([math]::Round($avgKB, 2)) KB" -ForegroundColor White
    Write-Host "      └─ Latence:" -ForegroundColor White
    Write-Host "         ├─ Moyenne (Avg) : $([math]::Round($avg, 2)) ms" -ForegroundColor Cyan
    Write-Host "         ├─ Minimum (Min) : $([math]::Round($min, 2)) ms" -ForegroundColor Green
    Write-Host "         ├─ Maximum (Max) : $([math]::Round($max, 2)) ms" -ForegroundColor Yellow
    Write-Host "         ├─ P50 (Médiane) : $([math]::Round($p50, 2)) ms" -ForegroundColor White
    Write-Host "         ├─ P90           : $([math]::Round($p90, 2)) ms" -ForegroundColor White
    Write-Host "         ├─ P95           : $([math]::Round($p95, 2)) ms" -ForegroundColor Magenta
    Write-Host "         └─ P99           : $([math]::Round($p99, 2)) ms" -ForegroundColor Red
    
    # Stockage résultats
    $results += [PSCustomObject]@{
        Service = $svc.Name
        Requests = $Requests
        Errors = $errors
        AvgMs = [math]::Round($avg, 2)
        MinMs = [math]::Round($min, 2)
        MaxMs = [math]::Round($max, 2)
        P50Ms = [math]::Round($p50, 2)
        P90Ms = [math]::Round($p90, 2)
        P95Ms = [math]::Round($p95, 2)
        P99Ms = [math]::Round($p99, 2)
        Throughput = [math]::Round($throughput, 2)
        AvgKB = [math]::Round($avgKB, 2)
    }
}

# Tableau comparatif
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "`n📊 TABLEAU COMPARATIF" -ForegroundColor Green -BackgroundColor Black
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

$results | Format-Table -AutoSize

# Classement
Write-Host "`n🏆 CLASSEMENT PAR PERFORMANCE (Latence moyenne):" -ForegroundColor Yellow
$ranked = $results | Sort-Object AvgMs
$medals = @("🥇", "🥈", "🥉")
for($i=0; $i -lt $ranked.Count; $i++) {
    $medal = if($i -lt 3){$medals[$i]}else{"  "}
    Write-Host "   $medal $($i+1). $($ranked[$i].Service) - $($ranked[$i].AvgMs) ms" -ForegroundColor Cyan
}

Write-Host "`n🚀 CLASSEMENT PAR THROUGHPUT (req/s):" -ForegroundColor Yellow
$rankedThroughput = $results | Sort-Object Throughput -Descending
for($i=0; $i -lt $rankedThroughput.Count; $i++) {
    $medal = if($i -lt 3){$medals[$i]}else{"  "}
    Write-Host "   $medal $($i+1). $($rankedThroughput[$i].Service) - $($rankedThroughput[$i].Throughput) req/s" -ForegroundColor Green
}

# Export CSV
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$csvPath = "results/benchmark-$timestamp.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "`n💾 Résultats sauvegardés: $csvPath" -ForegroundColor Green

# Export JSON
$jsonPath = "results/benchmark-$timestamp.json"
$results | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding UTF8
Write-Host "💾 Résultats JSON: $jsonPath" -ForegroundColor Green

# Analyse comparative
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "`n📊 ANALYSE COMPARATIVE:" -ForegroundColor Cyan

$fastest = $ranked[0]
$slowest = $ranked[-1]
$percentFaster = [math]::Round((($slowest.AvgMs - $fastest.AvgMs) / $slowest.AvgMs) * 100, 1)

Write-Host "`n   🏃 $($fastest.Service) est le plus RAPIDE" -ForegroundColor Green
Write-Host "      → $percentFaster% plus rapide que $($slowest.Service)" -ForegroundColor White
Write-Host "      → Latence: $($fastest.AvgMs) ms vs $($slowest.AvgMs) ms" -ForegroundColor Gray

if ($results.Count -eq 3) {
    $middle = $ranked[1]
    $vsMiddle = [math]::Round((($middle.AvgMs - $fastest.AvgMs) / $middle.AvgMs) * 100, 1)
    Write-Host "`n   ⚖️  $($middle.Service) est INTERMÉDIAIRE" -ForegroundColor Yellow
    Write-Host "      → $vsMiddle% plus lent que $($fastest.Service)" -ForegroundColor White
}

Write-Host "`n   🐌 $($slowest.Service) est le plus LENT" -ForegroundColor Red
Write-Host "      → Possible overhead: JSON HAL, auto-configuration" -ForegroundColor Gray

# Recommandations
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "`n💡 RECOMMANDATIONS:" -ForegroundColor Yellow

foreach($r in $results) {
    Write-Host "`n   🔹 $($r.Service):" -ForegroundColor Cyan
    
    if ($r.Service -like "*Jersey*") {
        Write-Host "      ✅ Meilleure performance brute" -ForegroundColor Green
        Write-Host "      ✅ Idéal pour: Microservices haute performance" -ForegroundColor White
        Write-Host "      ⚠️  Attention: Plus de code boilerplate" -ForegroundColor Yellow
    }
    elseif ($r.Service -like "*Spring MVC*") {
        Write-Host "      ✅ Bon équilibre performance/productivité" -ForegroundColor Green
        Write-Host "      ✅ Idéal pour: Applications d'entreprise" -ForegroundColor White
        Write-Host "      ⚠️  Attention: Overhead Spring Framework" -ForegroundColor Yellow
    }
    elseif ($r.Service -like "*Spring Data*") {
        Write-Host "      ✅ Développement ultra-rapide (pas de code)" -ForegroundColor Green
        Write-Host "      ✅ Idéal pour: Prototypes, CRUD simples" -ForegroundColor White
        Write-Host "      ⚠️  Attention: Overhead JSON HAL, moins de contrôle" -ForegroundColor Yellow
    }
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "`n✅ BENCHMARK TERMINÉ!" -ForegroundColor Green -BackgroundColor Black
Write-Host "`n📂 Fichiers générés:" -ForegroundColor Cyan
Write-Host "   • $csvPath" -ForegroundColor White
Write-Host "   • $jsonPath" -ForegroundColor White
Write-Host "`n🌐 Dashboards disponibles:" -ForegroundColor Cyan
Write-Host "   • Grafana: http://localhost:3001" -ForegroundColor White
Write-Host "   • Prometheus: http://localhost:9091" -ForegroundColor White
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
