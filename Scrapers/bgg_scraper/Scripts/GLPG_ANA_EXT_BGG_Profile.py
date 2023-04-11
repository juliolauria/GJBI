import requests
import xmltodict
import pandas as pd
from datetime import date
from datetime import datetime
from xml.parsers.expat import ExpatError

pd.options.display.max_columns = 99

def check_list(inp, key, par='#text'):
    if key in inp.keys():
        if type(inp[key]) == list:
            return [item[par] for item in inp[key]]
        else:
            return inp[key][par]
    else:
        return None

def check_keys(inp, key):
    if key in inp.keys():
        return inp[key]
    else:
        return None

hoje = date.today().strftime('%Y-%m-%d')
now = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

# Pega informações do Crawler local BGG Boardgames
data = pd.read_csv('Output//BGG_Boardgames.csv', engine = 'python')
data = data[data['rank'].notnull()] # Trata apenas os jogos rankeados (Apenas jogos rankeados tem garantia de possuir informações na API)

INPUT_BGG_ID = data['link'].str.split('/', expand = True)[2]

df_final = pd.DataFrame()

for i, id in enumerate(INPUT_BGG_ID):

    resp = requests.get(API_URL + str(id) + '?comments=1&stats=1')
    try:
        first_parse = xmltodict.parse(resp.text)
    except ExpatError:
        continue

    parse = first_parse['boardgames']['boardgame']

    df_temp = pd.DataFrame()

    df_temp['ID'] = [parse['@objectid']]
    df_temp['year'] = [parse['yearpublished']]
    df_temp['minplayers'] = [parse['minplayers']]
    df_temp['maxplayers'] = [parse['maxplayers']]
    df_temp['playingtime'] = [parse['playingtime']]
    df_temp['minplaytime'] = [parse['minplaytime']]
    df_temp['maxplaytime'] = [parse['maxplaytime']]
    df_temp['age'] = [parse['age']]
    if type(parse['name']) == list:
        for name in parse['name']:
            try:
                name['@primary']
                df_temp['name'] = name['#text']
            except:
                pass
    else:
        df_temp['name'] = parse['name']['#text']
    print(str(i) + ') ' + df_temp['name'].values[0], flush=True)
    # df_temp['image'] = [parse['image']]
    df_temp['image'] =  check_keys(parse, 'image')
    df_temp['boardgamehonor'] = [check_list(parse, 'boardgamehonor')]
    df_temp['category'] = [check_list(parse, 'boardgamecategory')]
    df_temp['mechanic'] = [check_list(parse, 'boardgamemechanic')]
    df_temp['family'] = [check_list(parse, 'boardgamefamily')]
    df_temp['designer'] = [check_list(parse, 'boardgamedesigner')]
    df_temp['artist'] = [check_list(parse, 'boardgameartist')]
    df_temp['expansion'] = [check_list(parse, 'boardgameexpansion')]
    df_temp['subdomain'] = [check_list(parse, 'boardgamesubdomain')]
    ratings = parse['statistics']['ratings']
    df_temp['userrated'] = [ratings['usersrated']]
    df_temp['average'] = [ratings['average']]
    df_temp['bayesaverage'] = [ratings['bayesaverage']]
    df_temp['owned'] = [ratings['owned']]
    df_temp['trading'] = [ratings['trading']]
    df_temp['wanting'] = [ratings['wanting']]
    df_temp['wishing'] = [ratings['wishing']]
    df_temp['numcomments'] = [ratings['numcomments']]
    df_temp['numweights'] = [ratings['numweights']]
    df_temp['weight'] = [ratings['averageweight']]
    if type(ratings['ranks']['rank']) == list:
        for rank in ratings['ranks']['rank']:
            if rank['@name'] == 'boardgame':
                if rank['@value'] == 'Not Ranked':
                    pass
                else:
                    df_temp['ranking_general'] = [rank['@value']]
            else:
                pass
    else:
        df_temp['ranking_general'] = ratings['ranks']['rank']['@value']

    complete_rank = []
    if type(ratings['ranks']['rank']) == list:
        for rank in ratings['ranks']['rank']:
            if rank['@name'] == 'boardgame':
                pass
            else:
                complete_rank.append((rank['@friendlyname'], rank['@value']))
        df_temp['complete_rank'] = [complete_rank]
    else:
        if ratings['ranks']['rank']['@name'] == 'boardgame':
            df_temp['complete_rank'] = None
        else:
            df_temp['complete_rank'] = [(ratings['ranks']['rank']['@friendlyname'], ratings['ranks']['rank']['@value'])]

    df_final = pd.concat([df_final, df_temp])

# Tratar '[]'
cols_brackets = ['boardgamehonor', 'category', 'mechanic', 'family', 'designer', 'artist', 'expansion', 'subdomain', 'complete_rank']

for col in cols_brackets:
    df_final[col] = df_final[col].astype(str).str.strip('[|]')

df_final = df_final.drop_duplicates()

df_final.to_csv('Output//BGG_Historico//BGG_Historico_Profile//BGG_Profile_' + now + '.csv', index=False, na_rep = None)
df_final.to_csv('Output//BGG_Profile.csv', index=False, na_rep = None, encoding='utf-8')
