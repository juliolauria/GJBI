import os
import pandas as pd

# Caminho para os arquivos
home_path = 'Output//ComparaJogos_Histórico//ComparaJogos_Histórico_Home'
jogos_path = 'Output//ComparaJogos_Histórico//ComparaJogos_Histórico_Jogos'

# Pega o nome do último arquivo executado pelo o crawler
home_recent = sorted([x for x in os.listdir(home_path) if 'ComparaJogos_Home_' in x], reverse=True)[0]
jogos_recent = sorted([x for x in os.listdir(jogos_path) if 'ComparaJogos_Jogos_' in x], reverse=True)[0]

home_recent

# Carrega os arquivos CSVs mais recentes
df_home = pd.read_csv(home_path + '//' + home_recent, engine = 'python', encoding = 'utf-8')
df_jogos = pd.read_csv(jogos_path + '//' + jogos_recent, engine = 'python', encoding = 'utf-8')

# Salva os arquivos CSVs para serem adicionados no Google Drive
df_home.to_csv('Output//ComparaJogos_Home.csv', index=False)
df_jogos.to_csv('Output//ComparaJogos_Jogos.csv', index=False)
