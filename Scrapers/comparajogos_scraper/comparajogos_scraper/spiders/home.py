# -*- coding: utf-8 -*-
import scrapy
import os
import pandas as pd
import numpy as np
from datetime import date
from datetime import datetime

def bgg_stats(dic, string, element):
    if any([string in elem for elem in element]):
        for elem in element:
            if string in elem:
                dic[string].append(elem)
            else:
                pass
    else:
        dic[string].append(None)

    return None

class homeSpider(scrapy.Spider):
    name = 'home'
    start_urls = [MASK_URL_LINKS]

    data = datetime.now().strftime('%Y-%m-%d %H-%M-%S')
    custom_settings = {'FEED_URI': "Output//ComparaJogos_Histórico//ComparaJogos_Histórico_Home//ComparaJogos_Home_" + data + ".csv",
                       'FEED_FORMAT': 'csv'}

    def parse(self, response):

        titulo = response.xpath('//div[@class = "ui doubling five cards"]//div[@class = "bigger"]/text()').extract()
        imagem = response.xpath('//div[@class = "ui doubling five cards"]//img//@src').extract()
        link = response.xpath('//div[@class = "ui doubling five cards"]//a/@href').extract()

        ranking_bgg_ini = response.xpath("//div[@class = 'content card-content']")
        ranking_bgg = [a.xpath('.//div[@class = "ui mini basic top right attached label"]/text()').extract() for a in ranking_bgg_ini]
        ranking_bgg = ['Sem ranking' if a == [] else a[0] for a in ranking_bgg]

        """
        quero = response.xpath('//div[@class = "ui doubling five cards"]' +
                                '//div[@data-tooltip = "Quero"]' +
                                '//div[@class = "ui basic circular label"]/text()').extract()

        tenho = response.xpath('//div[@class = "ui doubling five cards"]' +
                                '//div[@data-tooltip = "Tenho"]' +
                                '//div[@class = "ui basic circular label"]/text()').extract()
        """

        info_quero_tenho = response.xpath('//div[@class = "ui doubling five cards"]' +
                                '//div[@class = "ui basic circular label"]/text()').extract()

        quero = info_quero_tenho[::2]
        tenho = info_quero_tenho[1::2]

        preco = response.xpath('//div[@class = "ui doubling five cards"]' +
                               '//div[@class = "price" or @class = "text red"]/text()').extract()
        preco = [r[3:] for r in preco if r is not ' ']
        preco = [r if r != 'isponível' else 'Indisponível' for r in preco]

        #"""
        #num_lojas_ini = response.xpath('//small[@class="payment-term"]/text()').extract()
        #"""

        num_lojas_ini = []
        for item in response.xpath('//a[@class = "ui fluid link raised card card-mobile"]'):
            if item.xpath('.//small[@class="payment-term"]/text()') != []:
                nloja = item.xpath('.//small[@class="payment-term"]/text()').extract()[0]
            else:
                nloja = None
            num_lojas_ini.append(nloja)

        """
        num_lojas_ini = [n for n in num_lojas_ini if n != "em "]
        num_lojas_ini = [n for n in num_lojas_ini if n != ' loja']
        num_lojas_ini = [n for n in num_lojas_ini if n != 's']
        num_lojas_int = []
        for elem in [n.split('em ') for n in num_lojas_ini]:
            if elem[0] == '':
                num_lojas_int.append(elem[1])
            else:
                num_lojas_int.append(elem[0])
        num_lojas = [n.split(' loja')[0] for n in num_lojas_int]
        """

        num_lojas_int = []
        for item in num_lojas_ini:
            if item == None:
                num_lojas_int.append(None)
            else:
                elem = item.split('em ')
                if elem[0] == '':
                    num_lojas_int.append(elem[1])
                else:
                    num_lojas_int.append(elem[0])

        num_lojas = []
        for n in num_lojas_int:
            if n == None:
                num_lojas.append("Indisponível")
            else:
                num_lojas.append(n.split(' loja')[0])

        bgg_ini = response.xpath("//div[@class = 'ui mini text four item compact-card menu']")
        bgg_int = [a.xpath(".//div/@data-tooltip").extract() for a in bgg_ini]

        d_bgg = {'jogador': [],
                 'min': [],
                 'Nota': [],
                 'Complexidade': []}

        for element in bgg_int:
            for key in d_bgg:
                bgg_stats(d_bgg, key, element)

        jogadores = [a if a == None else a.split(' jogador')[0] for a in d_bgg['jogador']]
        tempo = [a if a == None else a.split(' minuto')[0] for a in d_bgg['min']]
        nota = [a if a == None else a.split('Nota média')[1].split(' de')[0] for a in d_bgg['Nota']]
        complexidade = [a if a == None else a.split('Complexidade ')[1].split(' de')[0] for a in d_bgg['Complexidade']]

        row_data = zip(titulo, imagem, link, ranking_bgg, quero, tenho, preco, num_lojas, jogadores, tempo, nota, complexidade)
        for item in row_data:
            scrapped_info = {
              # 'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
              'titulo': item[0],
              'imagem': item[1],
              'link': item[2],
              'ranking_bgg': item[3],
              'quero': item[4],
              'tenho': item[5],
              'preco': item[6],
              'num_lojas': item[7],
              'jogadores': item[8],
              'tempo': item[9],
              'nota': item[10],
              'complexidade': item[11]
            }

            yield scrapped_info
