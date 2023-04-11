# -*- coding: utf-8 -*-
import scrapy
from datetime import datetime

class JogoslinksSpider(scrapy.Spider):
    name = 'jogoslinks'
    start_urls = [URL]
    date = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

    custom_settings = {'FEED_URI': "Output//Ludopedia_Historico//Ludopedia_Histórico_JogosLinks//Ludopedia_JogosLinks_" + date + ".csv",
                       'FEED_FORMAT': 'csv'}
    encoding='latin1'

    def parse(self, response):
        jogos = response.xpath("//div[@class='media-body']/a/h4/text()").extract()
        links = response.xpath("//div[@class='media-body']/a/@href").extract()

        links = [x for x in links if 'loja' not in x]

        row_data = zip(jogos, links)
        for item in row_data:
            # create a dictionary to store the scraped info
            scraped_info = {
                'jogo': item[0],
                'link': item[1]
            }
            yield scraped_info

            next_page = response.xpath('//li[@class="hidden-xs"]/a[@title="Próxima Página"]/@href').extract_first()
            if next_page:
                yield scrapy.Request(
                    response.urljoin(next_page),
                    callback=self.parse)
