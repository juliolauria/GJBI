# -*- coding: utf-8 -*-
import scrapy
import pandas as pd
import os
from datetime import datetime

class JogosSpider(scrapy.Spider):
    name = 'jogos'
    # import the newest file
    rank_path = sorted([x for x in os.listdir(PATH) if 'Ludopedia_JogosLinks' in x], reverse=True)[0]
    lista_jogos = pd.read_csv(PATH + rank_path, engine = 'python')
    start_urls = lista_jogos['link'].values
    # start_urls = [URL]

    date = datetime.now().strftime('%Y-%m-%d %H-%M-%S')

    custom_settings = {'FEED_URI': "Output//Ludopedia_Historico//Ludopedia_Histórico_Jogos//Ludopedia_Jogos_" + date + ".csv",
                       'FEED_FORMAT': 'csv'}

    def parse(self, response):

        jogo = response.xpath('//div[@class="jogo-top-main"]/h3/a/text()').extract_first()
        idade = response.xpath('//div[@class="jogo-top-main"]/ul/li[1]/text()').extract_first()
        tempo_jogo = response.xpath('//div[@class="jogo-top-main"]/ul/li[2]/text()').extract_first()
        n_jogadores = response.xpath('//div[@class="jogo-top-main"]/ul/li[3]/text()').extract_first()
        designers = str(response.xpath('//div[@class="jogo-top-main"]/div[@class="hidden-xs"]/span/a/text()').extract())
        editoras = str(response.xpath('//div[@class="jogo-top-main"]/span[@class="info-span text-sm"]/a/text()').extract())
        tenho = response.xpath('//button[@id="btn-colecao-fl-tem"]/text()').extract_first()[7:-1] # Arrumar aqui!
        quero = response.xpath('//button[@id="btn-colecao-fl-quer"]/text()').extract_first()[7:-1]
        tive = response.xpath('//button[@id="btn-colecao-fl-teve"]/text()').extract_first()[6:-1]
        favoritos = response.xpath('//button[@id="btn-colecao-fl-favorito"]/text()').extract_first()[10:-1]
        joguei = response.xpath('//button[@id="btn-colecao-fl-jogou"]/text()').extract_first()[8:-1]
        editora_nacional = response.xpath('//div[@class="media-body"]//*[contains(@href, "editora")]/text()').extract_first()
        caracteristicas_jogo = response.xpath("//div[@class = 'mar-btm bg-gray-light pad-all']/a/text()").extract()
        URL_imagem = response.xpath("//img[@id = 'img-capa']/@src").extract()[0]

        ## Lançamento nacional pouco reproduzível
        ## lancamento_nacional = response.xpath('//div[@class="mar-btm bg-gray-light pad-all"]/text()').re('\\b\\d+\\b')[0]

        lista_temas = ['Adulto', 'Animais', 'Anime / Manga', 'Arte', 'Aventura',
                       'Ciências', 'Civilização', 'Cultura Africana', 'Cultura Brasileira',
                       'Cultura Oriental', 'Cultura Pop ou Geek', 'Economia / Produção',
                       'Educacional', 'Esportes', 'Fantasia', 'Faroeste', 'Ficção Científica',
                       'Gastronomia', 'Guerra', 'História', 'Horror', 'Humor', 'Literatura',
                       'Luta / Artes Marciais', 'Medieval', 'Meio Ambiente', 'Mitologia',
                       'Piratas', 'Policial', 'Política', 'Pré-Histórico', 'Quadrinhos',
                       'Religião', 'Tema de Video Game', 'Transportes', 'Vikings']

        lista_mecanicas = ['Ação / Movimento Programado', 'Ação Simultânea',
                           'Alocação de Trabalhadores', 'Apostas', 'Atuação', 'Blefe',
                           'Campanha/ Batalhas Dirigidas por Cartas', 'Cantar', 'Cerco de Área',
                           'Colecionar Componentes', 'Colocação de Peças', 'Construção a partir de Modelo',
                           'Construção de Baralho/Peças', 'Construção de Rotas', 'Controle/Influência de Área',
                           'Cooperativo', 'Dedução', 'Desenhar', 'Desenhar Rota com Lápis',
                           'Eliminação de Jogadores', 'Especulação Financeira', 'Force sua sorte',
                           'Gestão de Mão', 'Impulso de Área', 'Jogadores com Diferentes Habilidades',
                           'Jogo em Equipe', 'Leilão', 'Linha de Tempo', 'Marcadores e Hexágonos', 'Memória',
                           'Mercado de Ações', 'Movimento de Área', 'Movimento em Grades', 'Movimento Ponto-a-Ponto',
                           'Narração de Histórias', 'Negociação', 'Ordem de Fases Variável', 'Papel e Caneta',
                           'Pedra, Papel e Tesoura', 'Pegar e Entregar', 'Posicionamento Secreto',
                           'Reconhecimento de Padrão', 'Rolagem de Dados', 'Rolar e Mover', 'RPG', 'Seleção de Cartas',
                           'Simulação', 'Sistema de Pontos de Ação', 'Sistema por Impulsos', 'Tabuleiro Modular',
                           'Tempo real', 'Toma essa', 'Vazas/Truques', 'Votação']

        lista_dominios = ["Jogos Expert", "Jogos Familiares", "Jogos Infantis", "RPG"]

        lista_categorias = ["4x", "Campanha", "Colecionável", "Dungeon Crawler",
                            "Estratégia Abstrata", "Expansão ou Suplemento",
                            "Imprima e Jogue", "Integrado com Aplicativo",
                            "Jogo Assimétrico", "Jogo de Cartas", "Jogo de Dados",
                            "Jogo de Entrada", "Jogo de Guerra", "Jogo Festivo", "Legacy",
                            "Livro-jogo", "Miniaturas", "Quebra-Cabeça", "Trivia"]

        temas = []
        mecanicas = []
        dominios = []
        categorias = []

        for i in caracteristicas_jogo:
            if i in lista_temas:
                temas.append(i)
            if i in lista_mecanicas:
                mecanicas.append(i)
            if i in lista_dominios:
                dominios.append(i)
            if i in lista_categorias:
                categorias.append(i)

        # create a dictionary to store the scraped info
        scraped_info = {
            'jogo': jogo
            , 'idade': idade
            , 'tempo_jogo': tempo_jogo
            , 'n_jogadores': n_jogadores
            , 'designers': designers
            , 'editoras': editoras
            , 'editora nacional': editora_nacional
            , 'tenho': tenho
            , 'quero': quero
            , 'tive': tive
            , 'favoritos': favoritos
            , 'joguei': joguei
            , 'tema': temas
            , 'mecanica': mecanicas
            , 'dominio': dominios
            , 'categoria': categorias
            , 'link': response.request.url.split(URL)[1]
            , 'URL_imagem': URL_imagem
        }
        yield scraped_info
