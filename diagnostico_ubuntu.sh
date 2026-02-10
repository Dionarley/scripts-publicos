#!/usr/bin/env bash


# 1. Verificar se o usuário é root (necessário para instalar pacotes e ler hardware)
if [ "$EUID" -ne 0 ]; then 
  echo "Por favor, execute como root (use sudo ./nome_do_script.sh)"
  exit 1
fi

# 2. Mapeamento de comandos para pacotes
declare -A DEPS=( ["smartctl"]="smartmontools" ["lsb_release"]="lsb-release" ["free"]="procps" ["ip"]="iproute2" ["lsblk"]="util-linux" )
FALTANDO=()

echo "--- Iniciando Verificação de Dependências ---"

for cmd in "${!DEPS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Ferramenta '$cmd' não encontrada. Preparando instalação de '${DEPS[$cmd]}'."
        FALTANDO+=("${DEPS[$cmd]}")
    fi
done

# 3. Instalação automática se houver algo faltando
if [ ${#FALTANDO[@]} -ne 0 ]; then
    echo "Instalando dependências: ${FALTANDO[*]}..."
    apt update -qq && apt install -y "${FALTANDO[@]}" -qq
    echo "Dependências instaladas com sucesso."
else
    echo "Todas as ferramentas já estão presentes."
fi

# --- 4. Geração do Relatório ---

ARQUIVO="diagnostico_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "======================================================"
    echo "RELATÓRIO COMPLETO DE SISTEMA - $(date)"
    echo "======================================================"

    echo -e "\n[1. INFO DO SISTEMA]"
    lsb_release -d | cut -f2
    echo "Kernel: $(uname -r)"
    echo "Tempo de atividade: $(uptime -p)"

    echo -e "\n[2. RECURSOS (CPU/RAM)]"
    echo "Modelo CPU: $(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2)"
    free -h

    echo -e "\n[3. SAÚDE FÍSICA DOS DISCOS (S.M.A.R.T.)]"
    for disco in $(lsblk -dno NAME | grep -E 'sd|nvme'); do
        echo "--- Disco /dev/$disco ---"
        smartctl -H /dev/"$disco" | grep "result" || echo "Status: Não disponível."
        # Adiciona a temperatura se disponível
        smartctl -A /dev/"$disco" | grep -i "Temperature" | awk '{print "Temperatura: " $2 " " $10}' || true
    done

    echo -e "\n[4. USO DE DISCO (PARTIÇÕES)]"
    df -h -x tmpfs -x devtmpfs

    echo -e "\n[5. REDE E CONECTIVIDADE]"
    ip -brief addr
    echo "Teste de Ping (Google DNS):"
    ping -c 2 8.8.8.8 > /dev/null && echo "Internet: OK" || echo "Internet: FALHA"

    echo -e "\n[6. PROCESSOS QUE MAIS CONSOMEM]"
    ps aux --sort=-%mem | head -n 6

    echo "======================================================"
} > "$ARQUIVO"

echo -e "\nPronto! O diagnóstico foi salvo em: **$ARQUIVO**"
