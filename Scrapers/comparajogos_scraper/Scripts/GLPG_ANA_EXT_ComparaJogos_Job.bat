D:

CD Scrapers\comparajogos_scraper

call "D:\Program Files\Anaconda\Scripts\activate.bat"

python Scripts\GLPG_ANA_EXT_ComparaJogos_SalvarHTMLCarregada.py

scrapy crawl home

scrapy crawl jogos

python Scripts\GLPG_ANA_EXT_ComparaJogos_GravarArquivosBigQuery.py

exit