# -*- coding: utf-8 -*-
import scrapy
from scrapy.selector import Selector
import selenium
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from datetime import datetime
import time

class BoardgamesSpider(scrapy.Spider):
    name = 'boardgames'
    start_urls = [MASK_START_URLS]

    date = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

    custom_settings = {'FEED_URI': "Output//BGG_Historico//BGG_Historico_Boardgames//BGG_Boardgames_" + date + ".csv",
                       'FEED_FORMAT': 'csv'}

    def __init__(self):
        options = Options()
        options.headless = True
        self.driver = webdriver.Chrome(options = options)

    def parse(self, response):

        self.driver.get(response.url)
        time.sleep(2.0)
        response = Selector(text = self.driver.page_source)

        row = response.xpath('//tr[@id="row_"]')

        for r in row:
            if r.xpath(".//td[@class = 'collection_rank']/a/@name") != []:
                rank = r.xpath(".//td[@class = 'collection_rank']/a/@name").extract()[0]
            else:
                rank = None
            if r.xpath(".//td[@class = 'collection_thumbnail']//img/@src") != []:
                image = r.xpath(".//td[@class = 'collection_thumbnail']//img/@src").extract()[0]
            else:
                image = None
            link = r.xpath('.//div[contains(@id, "results_objectname")]/a/@href').extract()[0]
            name = r.xpath('.//div[contains(@id, "results_objectname")]/a/text()').extract()[0]
            if r.xpath('.//span[@class="smallerfont dull"]/text()').extract() != []:
                year = r.xpath('.//span[@class="smallerfont dull"]/text()').extract()[0].split('(')[1].split(')')[0]
            else:
                year = None
            geekrating = r.xpath(".//td[@class = 'collection_bggrating']/text()").extract()[0]
            geekrating = geekrating.split('\n\t\t\t')[1].split('\t')[0]
            avgrating = r.xpath(".//td[@class = 'collection_bggrating']/text()").extract()[1]
            avgrating = avgrating.split('\n\t\t\t')[1].split('\t')[0]
            numvoters = r.xpath(".//td[@class = 'collection_bggrating']/text()").extract()[2]
            numvoters = numvoters.split('\n\t\t\t')[1].split('\t')[0]

            shop = r.xpath(".//td[@class='collection_shop']")
            price = r.xpath(".//td[@class='collection_shop']//div/text()").extract()

            list_price = None
            for p in price:
                if 'List' in p:
                    list_price = p.split('List: ')[1].split('\n')[0]

            new_amazon_price = None
            for i,a in enumerate(shop.xpath(".//a[@class='ulprice']/text()").extract()):
                if 'New Amazon' in a:
                    new_amazon_price = shop.xpath(".//a[@class='ulprice']/span/text()").extract()[i]

            # linkbgg = r.xpath('.//div[contains(@id, "results_objectname")]/a/@href').extract()[0]

            scraped_info = {
                'rank': rank
                , 'image': image
                , 'link': link
                , 'name': name
                , 'year': year
                , 'geekrating': geekrating
                , 'avgrating': avgrating
                , 'numvoters': numvoters
                , 'list_price': list_price
                , 'new_amazon_price': new_amazon_price
            #   , 'linkbgg': linkbgg

            }
            yield scraped_info

        next_page = response.xpath('//a[@title = "next page"]/@href').extract_first()
        if next_page:
            if URL in next_page:
                pass
            else:
                next_page = URL + next_page
            yield scrapy.Request(

                # response.urljoin(next_page),
                url = next_page,
                callback=self.parse)
