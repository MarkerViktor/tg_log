# Скрипт для логирования вывода STDOUT через Telegram-бота
## Параметры
- `--filter` принимает на вход регулярное выражение аналогично grep -E. Если тект из STDIN удовблетворяет этому выражение, то лог будет отправлен через бота.
- `--tag` принимает на вход строку, которая будет добавлена в сообщение и в название прикрепляемого текстового файла.
- Переменная среды `TG_LOG_TOKEN` должна содержать Telegram Bot API токен
- Переменная среды `TG_LOG_RECIPIENTS_IDS` должна содержать идентификаторы пользователей через запятую (можно получить с помощью [бота](https://t.me/username_to_id_bot))

## Пример
```bash
export TG_LOG_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
export TG_LOG_RECIPIENTS_IDS=432141,4213532421
echo 'hello world' | tg_log.sh --tag 'hello_world' --filter 'hello'
```
После этого Telegram-бот, чей токен был указан, отправит пользователеям с идентификаторами 432141 и 4213532421 сообщение `hello_world 2023-09-19T05:56:23Z`, к которому прикреплён текстовы файл `2023-09-19T05:56:23Z_hello_world.txt`, содержащий `hello world`.

## Пример cron
```bash
TG_LOG_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TG_LOG_RECIPIENTS_IDS=432141
* * * * * python3 ~/script.py | ~/tg_log.sh --tag 'script_Error' --filter 'error'
TG_LOG_RECIPIENTS_IDS=65746546345
* 5 * * * python3 ~/script2.py | ~/tg_log.sh --tag 'script_Error' --filter 'error'
```
