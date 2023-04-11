import os
import pandas as pd

print(os.getcwd())

path = 'Output//BGG_Historico//BGG_Historico_Boardgames//'
recent_file = sorted(os.listdir(path), reverse=True)[0]

df = pd.read_csv(path + recent_file, engine='python', encoding='utf-8')
df.to_csv('Output//BGG_Boardgames.csv', index=False)
