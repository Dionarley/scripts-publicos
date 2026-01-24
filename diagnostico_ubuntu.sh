#!/bin/bash

# Nome do arquivo de saída com data
ARQUIVO="diagnostico_$(date +%Y%m%d_%H%M%S).txt"

echo "======================================================" > "$ARQUIVO"
echo "RELATÓRIO DE DIAGNÓSTICO DO SISTEMA - $(date)" >> "$ARQUIVO"
echo "======================================================" >> "$ARQUIVO"

# 1. Informações do Sistema Operacional
echo -e "\n[1. SISTEMA OPERACIONAL]" >> "$ARQUIVO"
lsb_release -a 2>/dev/null >> "$ARQUIVO"
echo "Kernel: $(uname -r)" >> "$ARQUIVO"
echo "Uptime: $(uptime -p)" >> "$ARQUIVO"

# 2. Hardware: CPU e Memória
echo -e "\n[2. CPU E MEMÓRIA]" >> "$ARQUIVO"
echo "Modelo CPU: $(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2)" >> "$ARQUIVO"
free -h >> "$ARQUIVO"

# 3. Armazenamento e Saúde do Disco
echo -e "\n[3. ARMAZENAMENTO E DISCO]" >> "$ARQUIVO"
df -h | grep '^/dev/' >> "$ARQUIVO"
echo -e "\n--- Status S.M.A.R.T. ---" >> "$ARQUIVO"
# Lista todos os discos e checa a saúde simplificada
for disco in $(lsblk -dno NAME | grep -E 'sd|nvme'); do
    echo "Disco /dev/$disco:" >> "$ARQUIVO"
    sudo smartctl -H /dev/$disco | grep "result" >> "$ARQUIVO" || echo "S.M.A.R.T. não suportado" >> "$ARQUIVO"
done

# 4. Rede
echo -e "\n[4. REDE]" >> "$ARQUIVO"
ip -brief addr >> "$ARQUIVO"
echo "Gateway: $(ip route | grep default | awk '{print $3}')" >> "$ARQUIVO"

# 5. Top 5 Processos que mais consomem memória
echo -e "\n[5. TOP 5 PROCESSOS (MEMÓRIA)]" >> "$ARQUIVO"
ps aux --sort=-%mem | head -n 6 >> "$ARQUIVO"

echo -e "\n======================================================" >> "$ARQUIVO"
echo "Fim do Relatório. Arquivo gerado: $ARQUIVO"
echo "======================================================"
