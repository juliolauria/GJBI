MERGE
  `production-glpg.External.ComparaJogos_Produtos` P
USING
  (
      SELECT DISTINCT
      H.LinkComparaJogos
    , H.Nome
    , H.Imagem
    , J.LinkBGG
    , H.Jogadores
    , H.Tempo
    , J.Editora
    , J.Designer
    , J.Mecanicas
    , SPLIT(J.LinkBGG, '/')[OFFSET(4)] AS ID_BGG
    
    FROM `production-glpg.Loading.ComparaJogos_Home` H

    INNER JOIN `production-glpg.Loading.ComparaJogos_Jogos` J
    ON J.LinkComparaJogos = H.LinkComparaJogos
   ) L
  ON
  P.LinkComparaJogos = L.LinkComparaJogos
WHEN MATCHED THEN
  UPDATE SET
    P.LinkComparaJogos = L.LinkComparaJogos
    , P.Nome = L.Nome
    , P.Imagem = L.Imagem
    , P.LinkBGG = L.LinkBGG
    , P.Jogadores = L.Jogadores
    , P.Tempo = L.Tempo
    , P.Editora = L.Editora
    , P.Designer = L.Designer
    , P.Mecanicas = L.Mecanicas
    , P.ID_BGG = L.ID_BGG

WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.LinkComparaJogos
    , L.Nome
    , L.Imagem
    , L.LinkBGG
    , L.Jogadores
    , L.Tempo
    , L.Editora
    , L.Designer
    , L.Mecanicas
    , L.ID_BGG
  )