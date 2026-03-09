#!/bin/bash
clear
echo "========================================"
echo "SSL PINNING SERVER"
echo "========================================"

if [ "$1" = "valid" ]; then
    python3 server.py --cert valid --port ${2:-8443}
elif [ "$1" = "invalid" ]; then
    python3 server.py --cert invalid --port ${2:-8443}
else
    echo "Использование: ./run.sh [valid|invalid] [порт]"
    echo "Пример: ./run.sh valid 8443"
fi
