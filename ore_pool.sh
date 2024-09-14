#!/bin/bash

mkdir ore-pool
cd ore-pool
rm -rf ore-miner
rm -rf ore-miner.tar.gz
wget http://download.bithunter.store:9999/ore/pool/ore-miner.tar.gz
tar -zxvf ore-miner.tar.gz
chmod u+x ore-miner
# Print the welcome message
echo "-------比特猎人ORE V2主网矿池一键挖矿脚本，无需RPC节点和GAS费-------"
echo "比特猎人社区出品，仅供会员学习使用，请勿用于商业用途"
echo "比特猎人 Telegram 电报群组: https://t.me/BitHunterCN"
echo "比特猎人个人电报号：@bithunter1688"
echo "--------------------------------------------------------------"

# Function to show the menu
show_menu() {
    echo "请选择一个选项，请用root用户操作："
    echo "1. quick"
    echo "2. log"
    echo "3. balance"
    echo "4. stop"
    echo "5. exit"
    echo -n "enter [1-5]: "
}

# Function to start mining
start_mining() {
    echo "开始一键挖矿..."
    read -p "Пожалуйста, введите количество потоков: " threads
    read -p "Пожалуйста, введите адрес рудного кошелька ore: " address
    apt update -y
    apt install screen -y
    pkill -9 screen
    screen -wipe

    # Start mining in the background and redirect output to ~/output.log
    screen -S ore-miner ~/ore-pool/ore-miner  mine --address "$address" --threads "$threads"  --invcode IUSEP7
}



# Function to check mining status
check_mining_status() {
    echo "Посмотреть статус добычи ..."
    screen -r ore-miner
}

# Function to claim rewards
claim_rewards() {
    echo "Ключевая получение награды ..."
    read -p "Пожалуйста, введите адрес рудного кошелька: " address
    ~/ore-pool/ore-miner  claim --address "$address" --invcode IUSEP7
}


# Function to stop mining
stop_mining() {
    echo "Перестань добывать ..."
    pkill -9 screen
	screen -wipe
}

# Main loop
while true; do
    show_menu
    read -r CHOICE
    case $CHOICE in
        1)
            start_mining
            ;;
        2)
            check_mining_status
            ;;

        3)
            claim_rewards
            ;;
        4)
            stop_mining
            ;;
        5)
            echo "Выйдите из сценария ...."
            break
            ;;
        *)
            echo "Если неверный вариант, попробуйте ...."
            ;;
    esac
done

# Clean up
clear
