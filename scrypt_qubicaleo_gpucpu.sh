#!/bin/bash
# Обновляем списки пакетов
apt update

# Устанавливаем необходимые пакеты: screen, unzip, nano
apt install -y screen unzip nano

# Проверяем, установлен ли screen
if ! command -v screen &> /dev/null
then
    echo "Ошибка: screen не установлен."
    exit 1
fi

# Проверяем, установлен ли unzip
if ! command -v unzip &> /dev/null
then
    echo "Ошибка: unzip не установлен."
    exit 1
fi

# Создаем директорию для Qubic клиента
mkdir -p ~/qubic
cd ~/qubic

# Загружаем Qubic клиент
wget https://dl.qubic.li/downloads/qli-Client-3.1.1-Linux-x64.tar.gz

# Распаковываем архив с клиентом
tar -xvf qli-Client-3.1.1-Linux-x64.tar.gz

# Удаляем архив после распаковки
rm qli-Client-3.1.1-Linux-x64.tar.gz

# Загружаем Aleo miner
wget https://github.com/LOLPANIC/Mike/raw/refs/heads/main/aleominer+3.0.14.zip

# Распаковываем архив с Aleo miner
unzip aleominer+3.0.14.zip

# Удаляем архив после распаковки
rm aleominer+3.0.14.zip

# Даем права на выполнение для Aleo miner и Qubic клиента
chmod +x ./aleominer
chmod +x ./qli-Client

# Генерация случайного имени для рига, связанного со словом "rent"
random_name="rent_$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"

# Обновляем файл appsettings.json с необходимыми настройками
cat > ./appsettings.json <<EOL
{
  "Settings": {
    "baseUrl": "wss://wps.qubic.li/ws",
    "amountOfThreads": 0,
    "payoutId": null,
    "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6Ijc1M2JiZWQ1LWMyZjEtNGVmZi1iNGU0LTJkMDA5MmI2NjJkYyIsIk1pbmluZyI6IiIsIm5iZiI6MTczMzczNDk2MywiZXhwIjoxNzY1MjcwOTYzLCJpYXQiOjE3MzM3MzQ5NjMsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.bDaTdgHMj6YTwqfBDD6asQF4rnRdCo8t2V8dtXQf1-bRGfV138o6U4TJPzQ1T9_x41MvXM6175cisgZHlog0fain9GFJH2Q-d1lbR4Z1ZqqrVgLX46jeLxNNX4LMc10gB0U38FajNvOp_2SRpqyYunG_3b5HdauADafR9341pYemGyonqQu87bBvIkrV6Y8e1dOAYbKPVQ5pvHmSnEwhiDzIpDxzHwvEWHE4UvDTa-m4p8xkysqHZweo5WpWpTWzR57fGfYNBER-S9WuV5YnbFSaM31oKX2vCCZ2-DcIZBjPSZt4EAm7ymr8JxJVvpFjI7szangR8OQ_zirzHUpqNA",
    "alias": "$random_name",
    "trainer": {
      "gpu": true,
      "gpuVersion": "CUDA12",
      "cpu": true,
      "cpuVersion": ""
	"cpuThreads": 0
    },
    "idleSettings": {
      "command": "/root/qubic/aleominer",
      "arguments": "-u stratum+ssl://aleo-asia.f2pool.com:4420 -w lolpanic.$random_name"
    }
  }
}
EOL

# Запускаем новую сессию screen с названием 'miner' и выполняем в ней запуск Qubic клиента
screen -S miner -dm bash -c './qli-Client'

# Пауза на 5 секунд для гарантии, что Qubic клиент запустился
#sleep 5

# Загружаем XMRig для CPU майнинга
#cd ~
#wget https://github.com/xmrig/xmrig/releases/download/v6.22.1/xmrig-6.22.1-linux-static-x64.tar.gz

# Распаковываем архив с XMRig
#tar -xvf xmrig-6.22.1-linux-static-x64.tar.gz

# Переходим в директорию XMRig
#cd xmrig-6.22.1

# Даем права на выполнение для XMRig
#chmod +x ./xmrig

# Запускаем XMRig в новой screen-сессии 'cpuminer'
#screen -S cpuminer -dm bash -c './xmrig -o hk.zephyr.gfwroute.com:1123 -u ZEPHsBS4KNKFLU5t1CeWNT1NuK8Lgcnp6Mr6hKwnzQCbZsmvx8CvHkfKGHjUMF96oJ2HUks4X2ChNb1LfnT2dqyQh9ksqA7Qz8C -p x --donate-level 1 -a rx/0 --cpu-no-yield --randomx-mode fast --randomx-no-numa'
