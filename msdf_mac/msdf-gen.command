#!/bin/bash
# ============================================================
#  MSDF Atlas Generator — macOS
#
#  Використання:
#    1) ./msdf-gen.sh Font.ttf
#    2) або просто ./msdf-gen.sh — і перетягни .ttf у вікно Terminal
#
#  Поруч має лежати charset.txt
#  Потрібен msdf-atlas-gen:  brew install msdf-atlas-gen
# ============================================================

cd "$(dirname "$0")" || exit 1

# ── Перевірки ───────────────────────────────────────────────
if ! command -v msdf-atlas-gen >/dev/null 2>&1; then
    echo
    echo "  ПОМИЛКА: msdf-atlas-gen не знайдено."
    echo "  Встанови:  brew install msdf-atlas-gen"
    echo
    exit 1
fi

if [ ! -f "charset.txt" ]; then
    echo "  ПОМИЛКА: charset.txt не знайдено поруч зі скриптом."
    exit 1
fi

# ── Шрифт ───────────────────────────────────────────────────
FONT="$1"

if [ -z "$FONT" ]; then
    echo
    echo "  Перетягни .ttf файл сюди і натисни Enter:"
    read -r FONT
fi

# Terminal при перетягуванні екранує пробіли і може додати лапки — чистимо
FONT="${FONT%\"}"; FONT="${FONT#\"}"
FONT="${FONT%\'}"; FONT="${FONT#\'}"
FONT="$(echo "$FONT" | sed 's/\\ / /g')"

if [ ! -f "$FONT" ]; then
    echo "  ПОМИЛКА: файл не знайдено: $FONT"
    exit 1
fi

NAME="$(basename "$FONT")"
NAME="${NAME%.*}"

# ── charset без CR ──────────────────────────────────────────
# charset.txt зроблений на Windows (CRLF). Символи \r ламають
# парсер діапазонів, тому працюємо з тимчасовою LF-копією.
CHARSET="charset.txt"
if grep -q $'\r' charset.txt 2>/dev/null; then
    tr -d '\r' < charset.txt > .charset_lf.txt
    CHARSET=".charset_lf.txt"
fi

# ── Параметри ───────────────────────────────────────────────
echo
echo "  Шрифт: $NAME"
echo "  (Enter = значення за замовчуванням)"
echo

read -r -p "  Розмір гліфа [48]: " SIZE
SIZE="${SIZE:-48}"

read -r -p "  Range (товщина ефектів: 8 тонкі / 32 товсті) [32]: " RANGE
RANGE="${RANGE:-32}"

read -r -p "  Розмір атласу px (число, або auto) [auto]: " DIM
DIM="${DIM:-auto}"

echo
echo "  Генерую: size=$SIZE range=$RANGE dim=$DIM ..."
echo

# ── Генерація ───────────────────────────────────────────────
if [ "$DIM" = "auto" ] || [ "$DIM" = "AUTO" ]; then
    msdf-atlas-gen -font "$FONT" -charset "$CHARSET" -type mtsdf -format png \
        -imageout "$NAME.png" -json "$NAME.json" \
        -size "$SIZE" -pxrange "$RANGE" -yorigin top
else
    msdf-atlas-gen -font "$FONT" -charset "$CHARSET" -type mtsdf -format png \
        -imageout "$NAME.png" -json "$NAME.json" \
        -size "$SIZE" -pxrange "$RANGE" -dimensions "$DIM" "$DIM" -yorigin top
fi

STATUS=$?
rm -f .charset_lf.txt

echo
if [ $STATUS -ne 0 ]; then
    echo "  ПОМИЛКА генерації. Якщо \"cannot fit\" — збільш розмір атласу."
else
    echo "  ГОТОВО: $NAME.png + $NAME.json"
    echo "  Копіюй обидва у assets/font/msdf/"
fi
echo
