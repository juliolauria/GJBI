# -*- coding: utf-8 -*-
import scrapy
from scrapy_splash import SplashRequest
import pandas as pd
import os
from datetime import datetime

def limpa_string(str):
    str = str.replace('\t', '')
    str = str.replace(' ', '')
    return str

def limpa_tab(str):
    str = str.replace('\t', '')
    return str

class ProfileScraperSpider(scrapy.Spider):
    name = 'profilescraper'
    # start_urls = [MASK_START_URLS]

    date = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

    custom_settings = {'FEED_URI': "Output//BGG_Profile//BGG_Profile_" + date + ".csv",
                       'FEED_FORMAT': 'csv'}

    def start_requests(self):
        boardgame_path = sorted([x for x in os.listdir('Output//BGG_Boardgames') if 'BGG_Boardgames_' in x], reverse=True)[0]
        link_list = pd.read_csv('Output//BGG_Boardgames//' + boardgame_path)
        start_urls = URL + link_list['link'].values
        for url in start_urls:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        # url = start_urls
        print(response.url)
        yield SplashRequest(url=response.url, callback=self.parse_item, args={'wait': 1.0})

    def parse_item(self, response):

        link = response.url.split(URL)[1]
        print(link)
        image = response.xpath("//img[@no-animate]/@src").extract_first()
        ranking_category = response.xpath("//span[@class = 'rank-title ng-binding']/text()").extract()
        for category in ranking_category:
            category = limpa_string(category)
        # ranking_category[0] = ranking_category[0][1:]
        ranking_rank = response.xpath("//a[@class='rank-value ng-binding ng-scope']/text()").extract()
        for rank in ranking_rank:
            rank = limpa_string(rank)
        # ranking_rank[0] = ranking_rank[0][1:]
        try:
            response.xpath("//span[@ng-show='showRating']/text()").extract()[0]
        except:
            rating = None
        else:
            rating = response.xpath("//span[@ng-show='showRating']/text()").extract()[0]
            rating = limpa_string(rating)
        title = response.xpath("//a[@ui-sref='geekitem.overview']/text()").extract()[2]
        title = limpa_tab(title)
        year = response.xpath("//span[@class='game-year ng-binding ng-scope']/text()").extract()[0]
        year = limpa_string(year)
        year = year.split('(')[1].split(')')[0]
        num_rating = response.xpath("//a[contains(@ui-sref, 'comment')]/text()").extract()[3]
        num_rating = limpa_string(num_rating)
        num_rating = num_rating.split('Rating')[0]
        num_comments = response.xpath("//a[contains(@ui-sref, 'comment')]/text()").extract()[5]
        num_comments = limpa_string(num_comments)
        num_comments = num_comments.split('Comment')[0]
        min_player = response.xpath("//span[@ng-if='min > 0']/text()").extract()[0]
        try:
            response.xpath("//span[contains(@ng-if, 'max>0')]/text()").extract()[0]
        except:
            max_player = None
        else:
            max_player = response.xpath("//span[contains(@ng-if, 'max>0')]/text()").extract()[0]
        min_time = response.xpath("//span[@ng-if='min > 0']/text()").extract()[1]
        try:
            response.xpath("//span[contains(@ng-if, 'max>0')]/text()").extract()[1]
        except:
            max_time = None
        else:
            max_time = response.xpath("//span[contains(@ng-if, 'max>0')]/text()").extract()[1]
        com_player = response.xpath("//span[contains(@ng-show, 'userplayers')]/text()").extract()[1]
        com_player = limpa_string(com_player)
        com_min_player = com_player.split('-')[0]
        try:
            com_player.split('-')[1]
        except:
            com_max_player = None
        else:
            com_max_player = com_player.split('-')[1]
        com_best_player = response.xpath("//span[contains(@ng-show, 'userplayers')]/text()").extract()[2]
        com_best_player = limpa_string(com_best_player)
        com_best_player = com_best_player.split(':')[1]
        min_age = response.xpath("//span[contains(@ng-if, 'minage')]/text()").extract()[0]
        min_age = limpa_string(min_age)
        com_min_age = response.xpath("//span[contains(@ng-bind-html, 'polls.playerage')]/text()").extract()[0]
        weight = response.xpath("//span[contains(@ng-class, 'weight')]/text()").extract()[0]
        weight = limpa_string(weight)
        designers = response.xpath("//popup-list[contains(@items, 'designer')]//span//a/text()").extract()
        artists = response.xpath("//popup-list[contains(@items, 'artist')]//span//a/text()").extract()
        publisher_main = response.xpath("//popup-list[contains(@items, 'publisher')]//span//a/text()").extract()[0]
        fans = response.xpath("//span[@class = 'btn-group']/@uib-tooltip").extract_first().split(' Fans')[0]

        classif = response.xpath(".//li[@class = 'feature']")
        type = classif[0].xpath(".//a[@class = 'ng-binding']/text()").extract()
        category = classif[1].xpath(".//popup-list//span//a//text()").extract()
        mechanisms = classif[2].xpath(".//popup-list//span//a//text()").extract()
        family = classif[3].xpath(".//popup-list//span//a//text()").extract()
        reimplemented = set([ref for ref in response.xpath("//popup-list[contains(@items, 'reimplementation')]//span//a/text()").extract() if '…' not in ref])
        if reimplemented == set():
            reimplemented = None

        language_dependence = response.xpath("//span[contains(@ng-bind-html, 'languagedependence')]/text()").extract()[0]
        own = response.xpath("//a[contains(@ui-sref, 'own')]/text()").extract()[0]
        own = limpa_string(own)
        wishlist = response.xpath("//a[contains(@ui-sref, 'wishlist')]/text()").extract()[0]
        wishlist = limpa_string(wishlist)
        fortrade = response.xpath("//a[contains(@ui-sref, 'fortrade')]/text()").extract()[1] # Verificar se essa posição da lista se aplica para todos os outros jogos
        fortrade = limpa_string(fortrade)
        wantintrade = response.xpath("//a[contains(@ui-sref, 'want')]/text()").extract()[0]
        wantintrade = limpa_string(wantintrade)
        hasparts = response.xpath("//a[contains(@ui-sref, 'hasparts')]/text()").extract()[0]
        hasparts = limpa_string(hasparts)
        wantparts = response.xpath("//a[contains(@ui-sref, 'wantparts')]/text()").extract()[0]
        wantparts = limpa_string(wantparts)

        # msrp = response.xpath("//div[contains(@class, 'price-retail')]//strong/text()").extract()[0]
        # amazonprice = response.xpath("//a[contains(@ng-show, 'amazonadctrl')]//div[contains(@class, 'sale-item-price')]//strong/text()").extract()[0]

        fans_also_like = response.xpath("//div[@class='panel ng-isolate-scope']//h2[@class='rec-title ng-binding']/text()").extract()

        scraped_info = {
            'link': link,
            'image': image,
            'ranking_category': ranking_category,
            'ranking_rank': ranking_rank,
            'rating': rating,
            'title': title,
            'year': year,
            'num_rating': num_rating,
            'num_comments': num_comments,
            'min_player': min_player,
            'max_player': max_player,
            'min_time': min_time,
            'max_time': max_time,
            'com_min_player': com_min_player,
            'com_max_player': com_max_player,
            'com_best_player': com_best_player,
            'min_age': min_age,
            'com_min_age': com_min_age,
            'weight': weight,
            'designers': designers,
            'artists': artists,
            'publisher_main': publisher_main,
            'fans': fans,
            'type': type,
            'category': category,
            'mechanisms': mechanisms,
            'family': family,
            'reimplemented': reimplemented,
            'language_dependence': language_dependence,
            'own': own,
            'wishlist': wishlist,
            'fortrade': fortrade,
            'wantintrade': wantintrade,
            'hasparts': hasparts,
            'wantparts': wantparts,
            # 'msrp': msrp,
            # 'amazonprice': amazonprice,
            'fans_also_like': fans_also_like,
            }

        yield scraped_info
