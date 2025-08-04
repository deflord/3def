#!/bin/bash
set -e

# Путь к исходной директории и резервной копии
SOURCE_DIR=~/mainsail
BACKUP_DIR=~/mainsail_backup_$(date +%Y%m%d_%H%M%S)
ZIP_URL="https://github.com/deflord/3def/raw/refs/heads/main/%D0%9A%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D0%BE%D0%BD%D0%BD%D1%8B%D0%B5%20%D1%84%D0%B0%D0%B9%D0%BB%D1%8B/mainsail-AFC/mainsail.zip"

# Функция для восстановления из резервной копии и выхода
restore_and_exit() {
    echo "Ошибка выполнения скрипта, восстанавливаем $SOURCE_DIR из $BACKUP_DIR"
    if [ -d "$BACKUP_DIR" ]; then
        rm -rf "$SOURCE_DIR"
        cp -r "$BACKUP_DIR" "$SOURCE_DIR" || echo "Ошибка при восстановлении из резервной копии"
    else
        echo "Резервная копия не найдена, пропуск восстановления"
    fi
    exit 1
}

# Установка обработчика ошибок
trap 'restore_and_exit' ERR

# 1. Создание резервной копии
if [ -d "$SOURCE_DIR" ]; then
    echo "Создание резервной копии $SOURCE_DIR в $BACKUP_DIR"
    cp -r "$SOURCE_DIR" "$BACKUP_DIR"
else
    echo "Директория $SOURCE_DIR не существует, пропуск резервного копирования"
fi

# 2. Удаление старой директории и создание новой
echo "Удаление старой директории $SOURCE_DIR и создание новой"
rm -rf "$SOURCE_DIR"
mkdir -p "$SOURCE_DIR"

# 3. Переход в директорию
cd "$SOURCE_DIR"

# 4. Загрузка архива
echo "Загрузка архива с $ZIP_URL"
wget "$ZIP_URL" -O mainsail.zip

# 5. Распаковка архива и удаление
echo "Распаковка архива"
unzip mainsail.zip
rm mainsail.zip

# 6. Перезапуск служб
echo "Перезапуск служб nginx, klipper, moonraker"
sudo systemctl restart nginx.service
sudo systemctl restart klipper.service
sudo systemctl restart moonraker.service

echo "Установка mainsail-AFC завершена"