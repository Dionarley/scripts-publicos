#!/usr/bin/env bash

git init

# Cria um arquivo .gitignore e adiciona um conteúdo básico
echo "# Ignora arquivos de log e temporários" > .gitignore
echo "*.log" >> .gitignore
echo "tmp/" >> .gitignore

# Cria um arquivo README.md com um título inicial
echo "# scripts-publicos" > README.md

# Adiciona todos os arquivos novos ao staging
git add .

# Faz o commit dos arquivos
git commit -m "Configuração inicial: adiciona script, .gitignore e README"

# Configura o branch e o repositório remoto
git branch -M main
git remote add origin https://github.com/Dionarley/scripts-publicos.git
git push -u origin main
