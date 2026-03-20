#!/bin/bash
# Скрипт синхронизации репозиториев (Bash)

set -e

# Функция безопасного копирования с заменой
copy_repo() {
    src=$1
    dst=$2
    echo "Копирование содержимого из $src в $dst..."
    rsync -av --exclude='.git' "$src/" "$dst/"
    echo "Копирование завершено."
}

# Ввод ссылок на репозитории
read -p "Введите ссылку на ваш репозиторий (куда синхронизировать): " MY_REPO
read -p "Введите ссылку на репозиторий для клонирования: " CLONE_REPO

# Клонирование репозитория для синхронизации во временную папку
TEMP_DIR=$(mktemp -d)
echo "Клонирование $CLONE_REPO в $TEMP_DIR..."
git clone "$CLONE_REPO" "$TEMP_DIR"

# Переход в временный репозиторий и pull
cd "$TEMP_DIR"
git pull origin main || git pull origin master
cd -

# Клонирование или проверка существующего локального репозитория
LOCAL_DIR="./my_repo"
if [ ! -d "$LOCAL_DIR" ]; then
    echo "Клонирование вашего репозитория $MY_REPO в $LOCAL_DIR..."
    git clone "$MY_REPO" "$LOCAL_DIR"
fi

# Копирование содержимого с проверкой пути
copy_repo "$TEMP_DIR" "$LOCAL_DIR"

# Опциональный git push
read -p "Выполнить git push в вашем репозитории? (y/n): " PUSH_CHOICE
if [[ "$PUSH_CHOICE" == "y" || "$PUSH_CHOICE" == "Y" ]]; then
    cd "$LOCAL_DIR"
    git add .
    git commit -m "Sync from remote repo"
    git push origin main || git push origin master
    cd -
fi

# Очистка временной папки
rm -rf "$TEMP_DIR"
echo "Синхронизация завершена."