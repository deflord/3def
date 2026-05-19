#!/bin/bash

# Пути к файлам и ключам
SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"
KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"

# Проверяем наличие системных ключей безопасности Debian
if [ ! -f "$KEYRING" ]; then
    echo "Системные GPG ключи Debian не найдены. Устанавливаем..."
    sudo apt-get update && sudo apt-get install -y debian-archive-keyring
fi

# Создание резервной копии текущего файла
if [ -f "$SOURCES_FILE" ]; then
    sudo cp "$SOURCES_FILE" "${SOURCES_FILE}.bak"
    echo "Создана резервная копия: ${SOURCES_FILE}.bak"
fi

# Запись конфигурации DEB822 полностью через mirror.yandex.ru
sudo tee "$SOURCES_FILE" > /dev/null << EOF
Types: deb deb-src
URIs: https://mirror.yandex.ru/debian/
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Architectures: arm64
Signed-By: $KEYRING

Types: deb deb-src
URIs: https://mirror.yandex.ru/debian-security/
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Architectures: arm64
Signed-By: $KEYRING
EOF

echo "Файл $SOURCES_FILE успешно настроен на зеркала Яндекса."

# Запуск обновления списков пакетов
echo "Запуск sudo apt update..."
sudo apt update
sudo rm update_repo.sh
