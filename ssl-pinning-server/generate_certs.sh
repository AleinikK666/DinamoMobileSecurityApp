#!/bin/bash
echo "Генерация сертификатов для SSL Pinning"
echo "========================================"

# Генерация валидного сертификата для localhost
openssl req -x509 -newkey rsa:2048 -keyout certs/valid_key.pem -out certs/valid_cert.pem -days 365 -nodes -subj "/CN=localhost" 2>/dev/null

# Генерация невалидного сертификата
openssl req -x509 -newkey rsa:2048 -keyout certs/invalid_key.pem -out certs/invalid_cert.pem -days 365 -nodes -subj "/CN=invalid.server.com" 2>/dev/null

# Конвертация в DER для iOS
openssl x509 -in certs/valid_cert.pem -outform DER -out certs/valid_cert.der
openssl x509 -in certs/invalid_cert.pem -outform DER -out certs/invalid_cert.der

echo "Готово!"
echo "Сертификаты созданы в папке certs/"
