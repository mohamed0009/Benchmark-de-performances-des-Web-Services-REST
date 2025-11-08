@echo off
echo ========================================
echo DEMARRAGE STACK COMPLETE (7 services)
echo ========================================
docker-compose up -d
timeout /t 30 /nobreak
docker-compose ps
echo.
echo Services disponibles:
echo   Jersey:      http://localhost:8080/api/categories
echo   Spring MVC:  http://localhost:8081/api/categories  
echo   Spring Data: http://localhost:8082/api/categories
echo   Grafana:     http://localhost:3000 (admin/admin)
pause
