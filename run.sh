#!/bin/bash

IP_LIST="ips.txt"
USER="root"
PASSWORD=""

# Verificar que sshpass está instalado
if ! command -v sshpass &> /dev/null; then
    echo "sshpass no está instalado. Instálalo con: sudo apt install sshpass"
    exit 1
fi

# Comando remoto a ejecutar en cada máquina
read -r -d '' REMOTE_COMMAND <<'EOF'
REPO_URL="https://github.com/pepesan/configura_maquina_owasp.git"
CLONE_DIR="/tmp/configura_maquina_owasp"

rm -rf "$CLONE_DIR" &&
git clone "$REPO_URL" "$CLONE_DIR" &&
cd "$CLONE_DIR" &&
sudo bash configura_maquina_root.sh &&
bash configura_maquina_usuario.sh
EOF

# Ejecutar el comando remoto en cada IP
while IFS= read -r ip || [[ -n "$ip" ]]; do
    echo "Conectando a $ip..."
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$USER@$ip" "$REMOTE_COMMAND" \
        && echo "✅ Éxito en $ip" || echo "❌ Error en $ip" &
done < "$IP_LIST"

wait
echo "Tarea completada en todas las máquinas."

