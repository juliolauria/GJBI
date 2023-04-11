import os
import pickle
import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import codecs

print(os.getcwd())

# Manually navigate in website to solve infinite scrolling issue
SCROLL_PAUSE_TIME = 2

option = Options()
option.headless = False
driver = webdriver.Chrome(options = option)

time.sleep(SCROLL_PAUSE_TIME)
driver.get(URL)
time.sleep(SCROLL_PAUSE_TIME)

botao = driver.find_element_by_xpath('//button[@class="ui tiny compact button go-to-top"]')
time.sleep(SCROLL_PAUSE_TIME)
carregado = botao.text.split(' de ')[0]
time.sleep(SCROLL_PAUSE_TIME)
total = botao.text.split(' de ')[1]

while carregado != total:
    # Scroll down to bottom
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    # Scroll up to top
    driver.execute_script("window.scrollTo(0, 0);")
    # Wait to load page
    time.sleep(SCROLL_PAUSE_TIME)
    # Calculate new itens loaded
    botao = driver.find_element_by_xpath('//button[@class="ui tiny compact button go-to-top"]')
    carregado = botao.text.split(' de ')[0]

    if int(carregado) > int(total):
        break

# Save file in local storage
with codecs.open('Output//ComparaJogos_PaginaCarregada.html', 'w', 'utf-8') as f:
    f.write(driver.page_source)

driver.close()
