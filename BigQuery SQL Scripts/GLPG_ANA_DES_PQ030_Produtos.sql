MERGE 
  `production-glpg.GJBI.Produtos` P
USING
      (SELECT 

    PRO.*, 
    PSV.UnitListPrice as PrecoSugeridoVenda,
    IMP.StatusImportacao,
    IMG.URL AS ImagemURL

    FROM `production-glpg.Loading.GJPlanner_SKUOficial` PRO  

    LEFT JOIN 
      (SELECT 
      D.ItemName,
      D.UnitListPrice
      FROM (
          SELECT C.*, ROW_NUMBER() OVER (PARTITION BY C.ItemName) AS rownum
          FROM 
            (SELECT * FROM `production-glpg.Loading.Oracle_Vendas`
             ORDER BY OrderedDate DESC) C
           ) D
      WHERE rownum = 1) PSV  
    ON PSV.ItemName = PRO.CodigoSKU

    LEFT JOIN(
            SELECT 

              B.SKU AS CodigoSKU
            , B.Ed as Edicao
            , B.Status as StatusImportacao

            FROM(
                  SELECT A.*, ROW_NUMBER() OVER (PARTITION BY A.SKU) AS rownum
                  FROM (
                         SELECT * FROM `production-glpg.Loading.Importacao`
                         ORDER BY CONCAT(SKU, Ed) DESC
                        ) A
                 ) B

            WHERE rownum = 1
            AND SKU IS NOT NULL) IMP

      ON IMP.CodigoSKU = PRO.CodigoSKU
      
      LEFT JOIN `production-glpg`.Loading.ImagensProdutos IMG
      ON IMG.CodigoSKU = PRO.CodigoSKU

    WHERE PRO.CodigoSKU IS NOT NULL) S
  ON
  S.CodigoSKU = P.CodigoSKU
WHEN MATCHED THEN
  UPDATE SET 
    Nome = S.Nome, 	
    Grupo = S.Grupo, 	
    Familia = S.Familia, 	
    Tipo = S.Tipo, 	
    Idade = S.Idade, 	
    Certificacao = S.Certificacao, 	
    Editora = S.Editora, 	
    Fornecedor = S.Fornecedor,
    Peso = SAFE_CAST(REPLACE(REPLACE(S.Peso, ',', '.'), '-', '0') AS FLOAT64), 
    Comprimento = SAFE_CAST(REPLACE(REPLACE(S.Comprimento, ',', '.'), '-', '0') AS FLOAT64), 
    Largura = SAFE_CAST(REPLACE(REPLACE(S.Largura, ',', '.'), '-', '0') AS FLOAT64), 
    Altura = SAFE_CAST(REPLACE(REPLACE(S.Altura, ',', '.'), '-', '0') AS FLOAT64), 
    Dimensoes = S.Dimensoes, 	
    Volume = SAFE_CAST(REPLACE(REPLACE(S.Volume, ',', '.'), '-', '0') AS FLOAT64),
    EAN13 = S.EAN13, 	
    CaixaMaster = SAFE_CAST(S.CaixaMaster AS INT64),
    CaixaMaster_EAN14 = S.CaixaMasterEAN14, 	
    CaixaConsolidacao = SAFE_CAST(S.CaixaConsolidacao AS INT64),
    CaixaConsolidacao_EAN14 = S.CaixaConsolidacaoEAN14, 	
    NCM = S.NCM, 	
    Nacionalidade = S.Nacionalidade, 	
    Idioma = S.Idioma, 	
    ReferenciaAsmodee = S.ReferenciaEmpresaMae, 	
    Comentarios = S.Comentarios, 	
    UltimaEdicao = S.UltimaEdicao,
    PrecoSugeridoVenda = ROUND(CAST(S.PrecoSugeridoVenda AS FLOAT64), 2),
    StatusImportacao = S.StatusImportacao,
    IDAsmodee = S.IDAsmodee,
    Catalogo = S.Catalogo,
    OP = S.OP,
    Categoria1 = S.Categoria1,
    Categoria2 = S.Categoria2,
    LinkLudopedia = S.LinkLudopedia,
    IPICalculado = (CAST(REPLACE(SUBSTR(S.IPICalculado, 0, CHAR_LENGTH(S.IPICalculado) - 1), ',', '.') AS FLOAT64) / 100),
    PrazoMedioPagamento = S.PrazoMedioPagamento,
    ImagemURL = S.ImagemURL,
    LinkBGG = S.LinkBGG
    
WHEN NOT MATCHED THEN
  INSERT VALUES (
    S.CodigoSKU,
    S.Nome, 	
    S.Grupo, 	
    S.Familia, 	
    S.Tipo, 	
    S.Idade, 	
    S.Certificacao, 	
    S.Editora, 	
    S.Fornecedor,
    SAFE_CAST(REPLACE(REPLACE(S.Peso, ',', '.'), '-', '0') AS FLOAT64), 
    SAFE_CAST(REPLACE(REPLACE(S.Comprimento, ',', '.'), '-', '0') AS FLOAT64), 
    SAFE_CAST(REPLACE(REPLACE(S.Largura, ',', '.'), '-', '0') AS FLOAT64), 
    SAFE_CAST(REPLACE(REPLACE(S.Altura, ',', '.'), '-', '0') AS FLOAT64), 
    S.Dimensoes, 	
    SAFE_CAST(REPLACE(REPLACE(S.Volume, ',', '.'), '-', '0') AS FLOAT64),
    S.EAN13, 	
    SAFE_CAST(S.CaixaMaster AS INT64),
    S.CaixaMasterEAN14, 	
    SAFE_CAST(S.CaixaConsolidacao AS INT64),
    S.CaixaConsolidacaoEAN14, 	
    S.NCM, 	
    S.Nacionalidade, 	
    S.Idioma, 	
    S.ReferenciaEmpresaMae, 	
    S.Comentarios, 	
    S.UltimaEdicao,
    ROUND(CAST(S.PrecoSugeridoVenda AS FLOAT64), 2),
    S.StatusImportacao,
    S.IDAsmodee,
    S.Catalogo,
    S.OP,
    S.Categoria1,
    S.Categoria2,
    S.LinkLudopedia,
    (CAST(REPLACE(SUBSTR(S.IPICalculado, 0, CHAR_LENGTH(S.IPICalculado) - 1), ',', '.') AS FLOAT64) / 100),
    S.PrazoMedioPagamento,
    S.ImagemURL,
    S.LinkBGG
  )
 