MERGE
  `production-glpg.External.ComparaJogos_Precos` P
USING
  (
    SELECT DISTINCT

      CURRENT_DATE() as Timestamp
    , J.LinkComparaJogos
    , J.Loja
    , ROUND(SAFE_CAST(REPLACE(REPLACE(J.PrecoPrincipal, 'R$ ', ''), ',', '.') AS FLOAT64), 2) AS PrecoPrincipal
    , ROUND(SAFE_CAST(REPLACE(REPLACE(J.PrecoBoleto, 'R$ ', ''), ',', '.') AS FLOAT64), 2) AS PrecoBoleto
    , J.TituloAnuncio

    FROM `production-glpg.Loading.ComparaJogos_Jogos` J
   ) L
  ON P.Timestamp = L.Timestamp
  AND P.LinkComparaJogos = L.LinkComparaJogos
  AND P.Loja = L.Loja
  AND P.TituloAnuncio = L.TituloAnuncio
WHEN MATCHED THEN
  UPDATE SET
      P.Timestamp = L.Timestamp
    , P.LinkComparaJogos = L.LinkComparaJogos
    , P.Loja = L.Loja
    , P.PrecoPrincipal = L.PrecoPrincipal
    , P.PrecoBoleto = L.PrecoBoleto
    , P.TituloAnuncio = L.TituloAnuncio

WHEN NOT MATCHED THEN
  INSERT VALUES (
      L.Timestamp
    , L.LinkComparaJogos
    , L.Loja
    , L.PrecoPrincipal
    , L.PrecoBoleto
    , L.TituloAnuncio
  )