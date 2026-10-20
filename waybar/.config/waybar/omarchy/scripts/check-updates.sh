#!/bin/bash
# Omarchy update checker

count=0

if which checkupdates >/dev/null 2>&1; then
    count=$(checkupdates 2>/dev/null | wc -l)
elif which pacman >/dev/null 2>&1; then
    count=$(pacman -Qu 2>/dev/null | wc -l)
fi

if (( count > 0 )); then
    echo "{\"text\": \"\", \"tooltip\": \"${count} package update(s) available\nClick to upgrade\"}"
else
    echo '{"text": ""}'
fi
