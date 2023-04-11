# -*- coding: utf-8 -*-
import scrapy
from scrapy.selector import Selector
import selenium
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import os
import pandas as pd
from datetime import date
from datetime import datetime
import time

class JogosSpider(scrapy.Spider):
    name = 'jogos'
    # Import newest file:
    links = sorted([x for x in os.listdir('Output//ComparaJogos_Histórico//ComparaJogos_Histórico_Home') if 'ComparaJogos_Home' in x], reverse=True)[0]
    lista_links = pd.read_csv('Output//ComparaJogos_Histórico//ComparaJogos_Histórico_Home//' + links, engine = 'python')
    # allowed_domains = ['www.comparajogos.com.br']
    start_urls = (URL + lista_links['link']).values
    start_urls = list(set(start_urls))
    data = datetime.now().strftime('%Y-%m-%d %H-%M-%S')
    custom_settings = {'FEED_URI': "Output//ComparaJogos_Histórico//ComparaJogos_Histórico_Jogos//ComparaJogos_Jogos_" + data + ".csv",
                       'FEED_FORMAT': 'csv'}

    def __init__(self):
        options = Options()
        options.headless = True
        self.driver = webdriver.Firefox(options = options)

    def parse(self, response):

        # driver = webdriver.Firefox()
        self.driver.get(response.url)
        time.sleep(2.0)
        link_comparajogos = response.request.url.split(URL)[1]

        response = Selector(text = self.driver.page_source)

        titulo = response.xpath('//div[@class = "bigger"]/text()').extract_first()
        link_bgg = response.xpath('//div[@class = "header attached card-header"]/a/@href').extract_first()
        editora = response.xpath('//div[@class = "description"]//a[contains(@href, "editora")]/text()').extract_first()
        designer = response.xpath('//div[@class = "description"]//a[contains(@href, "designer")]/text()').extract_first()
        mecanicas = response.xpath('//div[@class = "description"]//a[contains(@href, "mecanica")]/text()').extract()
        mecanicas = list(set(mecanicas))

        # jogadores = response.xpath('//div[@class = "ui mini secondary labeled icon four item compact-card menu"]/div').extract()
        # tempo = response.xpath('//div[@class = "ui mini secondary labeled icon four item compact-card menu"]/div').extract()
        # nota = response.xpath('//div[@class = "ui mini secondary labeled icon four item compact-card menu"]/div').extract()
        # complexidade = response.xpath('//div[@class = "ui mini secondary labeled icon four item compact-card menu"]/div').extract()

        # nome_loja = nome_lojas = response.xpath('//div[@class = "nine wide computer sixteen wide tablet column"]' +
        #                                         '//div[@style = "overflow:hidden"]/text()').extract()

        table = response.xpath('//tbody//tr')

        for i, a in enumerate(table):
            nomeloja = a.xpath('.//div[@style = "overflow: hidden;"]/text()').extract()[0]
            try:
                preco_principal = a.xpath('.//div[@class = "price" or @class = "text red"]/text()').extract()[0]
                preco_principal = preco_principal.replace('.', '')
            except IndexError:
                preco_principal = 'Indisponível'
            try:
                preco_boleto = a.xpath('.//div[@class = "price" or @class = "text red"]/text()').extract()[2]
                preco_boleto = preco_boleto.replace('.', '')
            except IndexError:
                preco_boleto = 'Indisponível'
            titulo_anuncio = response.xpath("//div[@class='sub header']/text()").extract()[i]


            scrapped_info = {
            # 'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'titulo': titulo,
            'link_comparajogos': link_comparajogos,
            'link_bgg': link_bgg,
            'editora': editora,
            'designer': designer,
            'mecanicas': mecanicas,
            'loja': nomeloja,
            'preco_principal': preco_principal,
            'preco_boleto': preco_boleto,
            'titulo_anuncio': titulo_anuncio
            }

            yield scrapped_info

            # self.driver.quit()
