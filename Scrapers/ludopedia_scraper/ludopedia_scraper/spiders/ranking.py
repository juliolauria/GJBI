# -*- coding: utf-8 -*-
import scrapy
from datetime import datetime

class RankingSpider(scrapy.Spider):
    name = 'ranking'
    start_urls = [URL]
    date = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

    custom_settings = {'FEED_URI': "Output//Ludopedia_Historico//Ludopedia_Histórico_Ranking//Ludopedia_Ranking_" + date + ".csv",
                       'FEED_FORMAT': 'csv'}

    def parse(self, response):
        ranks = response.xpath('//span[@class="rank"]/text()').extract()
        jogos = response.xpath('//h4[@class="media-heading"]/a/text()').extract()
        anos = response.xpath('//h4[@class="media-heading"]/small/i/text()').extract()
        links = response.xpath('//h4[@class="media-heading"]/a/@href').extract()
        links = [i.split('https://www.ludopedia.com.br/jogo')[1] for i in links]
        scores = response.xpath('//div[@class="rank-info"]/span[1]/b/text()').extract()
        scores_medios = response.xpath('//div[@class="rank-info"]/span[2]/b/text()').extract()
        n_scores = response.xpath('//div[@class="rank-info"]/span[3]/a/b//text()').extract()

        row_data = zip(ranks, jogos, anos, links, scores, scores_medios, n_scores)
        for item in row_data:
            # create a dictionary to store the scraped info
            scraped_info = {
                  'ranks': item[0]
                , 'jogos': item[1]
                , 'anos': item[2]
                , 'links': item[3]
                , 'scores': item[4]
                , 'scores_medios': item[5]
                , 'n_scores': item[6]
            }
            yield scraped_info

            next_page = response.xpath('//li[@class="hidden-xs"]/a[@title="Próxima Página"]/@href').extract_first()
            if next_page:
                yield scrapy.Request(
                    response.urljoin(next_page),
                    callback=self.parse)
