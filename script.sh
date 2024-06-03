#!/bin/bash

# Функция для вывода справки
print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --users           Display list of users and their home directories"
    echo "  -p, --processes       Display list of running processes sorted by PID"
    echo "  -h, --help            Display this help message"
    echo "  -l PATH, --log PATH   Redirect output to the specified file"
    echo "  -e PATH, --errors PATH Redirect stderr to the specified file"
}

# Функция для вывода списка пользователей и их домашних директорий
list_users() {
    cut -d: -f1,6 /etc/passwd | sort
}

# Функция для вывода списка запущенных процессов
list_processes() {
    ps -eo pid,cmd --sort=pid
}

# Инициализация переменных
log_file=""
error_file=""
log_output=false
error_output=false

# Обработка аргументов командной строки
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -u|--users)
            action="users"
            shift
            ;;
        -p|--processes)
            action="processes"
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        -l|--log)
            log_file="$2"
            log_output=true
            shift 2
            ;;
        -e|--errors)
            error_file="$2"
            error_output=true
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# Проверка доступности пути для логов
if $log_output; then
    if ! touch "$log_file" 2>/dev/null; then
        echo "Cannot write to log file: $log_file"
        exit 1
    fi
fi

# Проверка доступности пути для ошибок
if $error_output; then
    if ! touch "$error_file" 2>/dev/null; then
        echo "Cannot write to error file: $error_file"
        exit 1
    fi
fi

# Выполнение действия на основе аргументов
if [ "$action" == "users" ]; then
    output=$(list_users)
elif [ "$action" == "processes" ]; then
    output=$(list_processes)
else
    echo "No action specified"
    print_help
    exit 1
fi

# Вывод результата в лог-файл или на экран
if $log_output; then
    echo "$output" > "$log_file"
else
    echo "$output"
fi

# Перенаправление ошибок в файл, если указано
if $error_output; then
    exec 2> "$error_file"
fi
