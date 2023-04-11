import os
import pandas as pd

# Cria função para carregar arquivo mais recente e salvar
# o arquivo que será carregado no Google Drive

def salvar_arquivos_ludopedia(string):
    output = 'Output//Ludopedia_Historico//Ludopedia_Histórico_'
    path = output + string
    recent_file = sorted([x for x in os.listdir(path) if (string + '_') in x], reverse=True)[0]
    df = pd.read_csv(path + '//' + recent_file, engine = 'python', encoding = 'utf-8')
    df.to_csv('Output//Ludopedia_' + string + '.csv', index=False, encoding = 'utf-8')
    return None

lista_string = ['Anuncios',
                'Jogos',
                'Ranking',
                'RankingsEspecíficos',
                'JogosLinks',]

for string in lista_string:
    salvar_arquivos_ludopedia(string)
