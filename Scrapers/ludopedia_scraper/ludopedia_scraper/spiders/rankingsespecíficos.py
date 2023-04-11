# -*- coding: utf-8 -*-
import scrapy
import pandas as pd
import os
from datetime import datetime

class RankingespecificosSpider(scrapy.Spider):
    name = 'rankingsespecificos'
    # import the newest file
    rank_path = sorted([x for x in os.listdir(PATH) if 'Ludopedia_Ranking' in x], reverse=True)[0]
    lista_jogos = pd.read_csv(PATH + rank_path, engine = 'python')
    rank_site_suffix = '?v=graficos'
    start_urls = (URL + lista_jogos['links'] + rank_site_suffix).values
    date = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

    custom_settings = {'FEED_URI': "Output//Ludopedia_Historico//Ludopedia_Histórico_RankingsEspecíficos//Ludopedia_RankingsEspecíficos_" + date + ".csv",
                       'FEED_FORMAT': 'csv'}

    def parse(self, response):

        jogo = response.xpath('//div[@class="jogo-top-main"]/h3/a/text()').extract_first()
        ranking_geral = response.xpath('//div[@class="btn-rank"]//a/span/text()').extract_first()[2:-1]
        rankings_especificos = response.xpath('//div[@class="btn-rank"]//a/text()').extract()[1:]

        # create a dictionary to store the scraped info

        for rank in rankings_especificos:

            scraped_info = {
                  'Link': response.request.url.split(URL)[1].split('?v=graficos')[0]
                , 'Jogo': jogo
                , 'Ranking Geral': ranking_geral
                , 'Categoria': rank.split('(')[0][:-1]
                , 'Ranking Especifico': rank.split('(')[1][:-1]
            }

            yield scraped_info
