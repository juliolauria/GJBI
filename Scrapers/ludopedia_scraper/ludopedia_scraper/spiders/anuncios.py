# -*- coding: utf-8 -*-
import scrapy
from datetime import datetime

class AnunciosSpider(scrapy.Spider):
    name = 'anuncios'
    start_urls = [URL]
    date = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

    custom_settings = {'FEED_URI': "Output//Ludopedia_Historico//Ludopedia_Histórico_Anuncios//Ludopedia_Anuncios_" + date + ".csv",
                       'FEED_FORMAT': 'csv'}
    encoding='latin1'

    def parse(self, response):
        tipos = response.css(".box-anuncio-title::text").extract()
        jogos = response.xpath('//a[@class="link-elipsis"]/text()').extract()
        cidade = response.xpath('//dl[@style="margin: 0px; margin-bottom:10px; font-size:90%"]/dd[1]/text()').extract()
        preco = response.xpath('//dd[@class="proximo_lance"]/text()').extract()
        link = response.xpath('//a[@class = "link-elipsis"]/@href').extract()
        link = [i.split(URL)[1] for i in link]
        id_anuncio_scrap = response.xpath('//div[@style = "vertical-align:middle; margin : 5px"]//a/@href').extract()

        id_anuncio = []
        for id in id_anuncio_scrap:
            if 'anuncio' in id:
                id_anuncio.append(id.split('=')[1])
            elif 'leilao' in id:
                id_anuncio.append(id.split('leilao/')[1])

        estado_produto_scrap = response.xpath("//li[contains(@class, 'col-xs-6 col-sm-4 col-md-3')]")
        lista_estado_produto = [i.xpath(".//dt").extract() for i in estado_produto_scrap]
        estado_produto = []
        for a in lista_estado_produto:
            if 'Preço' in a[0]: # Anúncio:
                estado_produto.append(a[0].split('(')[1].split(')')[0])
            elif 'lance' in a[1]: # Leilão
                estado_produto.append(a[1].split('(')[1].split(')')[0])

        row_data = zip(tipos, jogos, cidade, preco, link, id_anuncio, estado_produto)
        for item in row_data:
            # create a dictionary to store the scraped info
            scraped_info = {
                'tipos': item[0],
                'jogos': item[1],
                'cidade': item[2],
                'preco': item[3],
                'link': item[4],
                'id_anuncio': item[5],
                'estado_produto': item[6],
            }
            yield scraped_info

            next_page = response.xpath('//li[@class="hidden-xs"]/a[@title="Próxima Página"]/@href').extract_first()
            if next_page:
                yield scrapy.Request(
                    response.urljoin(next_page),
                    callback=self.parse)
