#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Помощь
usage() {
    echo -e "${GREEN}Jane the Helper — защитник паролей${NC}"
    echo "Использование:"
    echo "  ./jane-the-helper.sh --generate [длина]  → сгенерировать пароль"
    echo "  ./jane-the-helper.sh --check 'пароль'    → проверить сложность"
    echo "  ./jane-the-helper.sh --hash 'пароль'     → получить bcrypt-хеш"
    echo "  ./jane-the-helper.sh --clean файл        → удалить слабые пароли из файла"
    exit 1
}

# Генерация пароля
generate_password() {
    local length=${1:-12}
    echo -e "${GREEN}Сгенерированный пароль:${NC}" 
    tr -dc 'A-Za-z0-9!@#$%^&*()_+' </dev/urandom | head -c "$length" | xargs -0
    echo ""
}

# Проверка сложности
check_password() {
    local password="$1"
    local score=0

    [ ${#password} -ge 8 ] && ((score++))
    [[ "$password" =~ [A-Z] ]] && ((score++))
    [[ "$password" =~ [a-z] ]] && ((score++))
    [[ "$password" =~ [0-9] ]] && ((score++))
    [[ "$password" =~ [!@#$%^&*()_+] ]] && ((score++))

    if [ $score -eq 5 ]; then
        echo -e "${GREEN}✅ Отличный пароль! (5/5)${NC}"
    elif [ $score -ge 3 ]; then
        echo -e "${YELLOW}⚠️ Средний пароль ($score/5)${NC}"
    else
        echo -e "${RED}❌ Очень слабый пароль ($score/5)${NC}"
    fi
}

# Хеширование (bcrypt)
hash_password() {
    local password="$1"
    if ! command -v htpasswd &> /dev/null; then
        echo -e "${RED}Ошибка: установите apache2-utils (apt install apache2-utils)${NC}"
        exit 1
    fi
    echo -e "${GREEN}Хеш (bcrypt):${NC}"
    htpasswd -bnBC 10 "" "$password" | tr -d ':\n'
    echo ""
}

# Удаление слабых паролей из файла
clean_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo -e "${RED}Файл не найден!${NC}"
        exit 1
    fi

    echo -e "${GREEN}Удаление слабых паролей...${NC}"
    grep -v -E '^(123456|password|qwerty|admin|welcome|123456789|12345678|12345|111111|sunshine)$' "$file" > "clean_$file"
    echo -e "✅ Готово! Новый файл: ${YELLOW}clean_$file${NC}"
}

# Разбор аргументов
case "$1" in
    --generate)
        generate_password "$2"
        ;;
    --check)
        check_password "$2"
        ;;
    --hash)
        hash_password "$2"
        ;;
    --clean)
        clean_file "$2"
        ;;
    *)
        usage
        ;;
esac
