#!/bin/bash

# Проверяем, что переданы обязательные переменные окружения
if [ -z "$TG_LOG_TOKEN" ] || [ -z "$TG_LOG_RECIPIENTS_IDS" ]; then
  echo "Не установлены обязательные переменные окружения TG_LOG_TOKEN и TG_LOG_RECIPIENTS_IDS."
  exit 1
fi

# Парсим аргументы командной строки
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --filter)
      FILTER="$2"
      shift 2
      ;;
    *)
      echo "Неизвестный аргумент: $1"
      exit 1
      ;;
  esac
done

# Переменные для API Telegram
TOKEN="$TG_LOG_TOKEN"
# Разделяем список id получателей по запятой и конвертируем в массив
IFS=',' read -ra RECIPIENT_IDS <<< "$TG_LOG_RECIPIENTS_IDS"

# Создаем временный файл для хранения данных из stdin
temp_file=$(mktemp)


# Считываем данные из stdin и записываем их во временный файл
while IFS= read -r line; do
  echo "$line"
  echo "$line" >> "$temp_file"
done

# Функция отправки сообщения в Telegram
send_message() {
  
  local tag="$1"
  local filter="$2"
  local match=$(cat $temp_file | grep -E "$filter")

  if [ -n "$match" ]; then
    # Создаем имя файла на основе текущей временной метки и тега
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    filename="${timestamp}_${tag}.txt"
    msg="${tag} ${timestamp}"
    mv "$temp_file" "$filename"
    # Отправляем файл в Telegram каждому получателю
    for recipient_id in "${RECIPIENT_IDS[@]}"; do
      curl -s "https://api.telegram.org/bot$TOKEN/sendDocument" \
        -F "chat_id=$recipient_id" \
        -F "document=@$filename" \
        -F "caption=$msg" \
        > /dev/null
    done

    # Удаляем временный файл
    rm "$filename"
  fi
}

# Вызываем функцию отправки сообщения в Telegram
send_message "$TAG" "$FILTER"
exit 0