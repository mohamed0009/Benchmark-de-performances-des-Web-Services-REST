@echo off
echo ========================================
echo BUILD TOUS LES SERVICES
echo ========================================
docker-compose build --no-cache
docker images | findstr benchmark
echo Build termine!
pause
