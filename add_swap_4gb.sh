#!/bin/bash

set -e  # Остановить скрипт при ошибке

echo "🔧 Создание swap-файла размером 4 ГБ..."

# 1. Создаём файл
sudo fallocate -l 4G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress

# 2. Назначаем права
sudo chmod 600 /swapfile

# 3. Инициализируем swap
sudo mkswap /swapfile

# 4. Включаем swap
sudo swapon /swapfile

# 5. Добавляем в /etc/fstab
if ! grep -q '/swapfile' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# 6. Настройка swappiness (оптимизация использования swap)
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# 7. Подтверждение
echo "✅ Swap успешно создан и активирован:"
free -h
