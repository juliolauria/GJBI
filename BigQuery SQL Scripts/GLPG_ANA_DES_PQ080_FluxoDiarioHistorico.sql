MERGE
  `production-glpg.GJBI.FluxoDiarioHistorico` P
USING
    (SELECT
    
    CURRENT_DATE AS Data,
    GJP.CodigoSKU,
    PRO.Nome,
    GJP.Edicao,
    -- Ativo no site,
    -- Data Lançamento,
    (CASE WHEN CAST(IFNULL(EST.`Quantidade`, 0) AS INT64) > 0 THEN 'Disponível' 
          WHEN GJP.PlanejadoDisponivelEstoque > Current_date AND CAST(IFNULL(EST.`Quantidade`, 0) AS INT64) = 0 AND GJP.Edicao = 'E01' THEN 'Não Lançado' 
          ELSE 'Esgotado' END) AS `Status`, -- Mudar esgotado para não-lançado em casos de lançamentos
    CAST(IFNULL(EST.`Quantidade`, 0) AS INT64) AS EstoqueDisponivel,
    CAST(((IFNULL((EST.`Quantidade` / PREVISAO.PrevisaoMes), 0)) * 30) AS INT64) AS DiasEmEstoque,  
    CASE WHEN GJP.PlanejadoDisponivelEstoque < CURRENT_DATE() THEN NULL ELSE GJP.PlanejadoDisponivelEstoque END AS `DataProximaEntradaPrevista`,
    CASE WHEN GJP.PlanejadoDisponivelEstoque < CURRENT_DATE() THEN 0 ELSE GJP.Quantidade END AS `QuantidadeEncomendada`,
    PREVISAO.PrevisaoMes,
    VEN_DIA.VendaDiaAnterior,
    VEN_MES.VendaMesCorrente,
    VEN_30.Venda30Dias,
    VEN_TOT.VendaTotal,
    QTD_TOT.QtdTotal,
    ROUND((VEN_TOT.VendaTotal / QTD_TOT.QtdTotal), 2) AS `PercTotalVendido`,
    FAT_DIA.FaturamentoDiaAnterior,
    FAT_MES.FaturamentoMesCorrente,
    FAT_30.Faturamento30Dias

  FROM (SELECT 
  B.*
  FROM
  (SELECT
      A.*,
      ROW_NUMBER() OVER (Partition BY A.CodigoSKU) AS rownum

    FROM (SELECT * FROM `production-glpg.GJBI.LeanPlanner`
  ORDER BY CONCAT(CodigoSKU, Edicao)  DESC) A) B

  WHERE rownum = 1) GJP

  INNER JOIN `production-glpg.GJBI.Produtos` PRO
  ON PRO.CodigoSKU = GJP.CodigoSKU

  LEFT JOIN (
    SELECT
      *
    FROM
      `production-glpg.GJBI.PosicaoEstoque`
    WHERE
      Data = CURRENT_DATE()
      AND TipoEstoque = 'B2B1_SC') EST
  ON
    GJP.CodigoSKU = EST.`CodigoSKU`


  LEFT JOIN (
    SELECT
      CodigoSKU,
      SUM(`QtdItem`) AS PrevisaoMes
    FROM
      `production-glpg.GJBI.NFS_Saida`
    WHERE
     DataProcesso BETWEEN DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)
      AND DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 DAY)
    GROUP BY `CodigoSKU`) PREVISAO
  ON
    GJP.CodigoSKU = PREVISAO.`CodigoSKU`


  LEFT JOIN (
    SELECT
      CodigoSKU,
      SUM(`QtdItem`) AS VendaDiaAnterior
    FROM
      `production-glpg.GJBI.NFS_Saida`
    WHERE
     DataProcesso = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY `CodigoSKU`) VEN_DIA
  ON
    GJP.CodigoSKU = VEN_DIA.`CodigoSKU`

  LEFT JOIN (
    SELECT
      CodigoSKU,
      SUM(`QtdItem`) AS VendaMesCorrente
    FROM
      `production-glpg.GJBI.NFS_Saida`
    WHERE
     DataProcesso BETWEEN DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)
      AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY `CodigoSKU`) VEN_MES
  ON
    GJP.CodigoSKU = VEN_MES.`CodigoSKU`

  LEFT JOIN (
    SELECT
      CodigoSKU,
      SUM(`QtdItem`) AS Venda30Dias
    FROM
      `production-glpg.GJBI.NFS_Saida`
    WHERE
     DataProcesso BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY)
      AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY `CodigoSKU`) VEN_30
  ON
    GJP.CodigoSKU = VEN_30.`CodigoSKU`

  LEFT JOIN (
    SELECT
      CodigoSKU,
      SUM(`QtdItem`) AS VendaTotal
    FROM
      `production-glpg.GJBI.NFS_Saida`
    WHERE
     DataProcesso BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 731 DAY) -- Vend total = Até 2 anos
      AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY `CodigoSKU`) VEN_TOT
  ON
    GJP.CodigoSKU = VEN_TOT.`CodigoSKU`

  LEFT JOIN (
    SELECT
      CodigoSKU,
      SUM(`Quantidade`) AS QtdTotal
    FROM
      `production-glpg.GJBI.LeanPlanner`
    WHERE PlanejadoDisponivelEstoque >= DATE_SUB(CURRENT_DATE(), INTERVAL 731 DAY) -- 2 anos para frente
    GROUP BY `CodigoSKU`) QTD_TOT
  ON
    GJP.CodigoSKU = QTD_TOT.`CodigoSKU`

  LEFT JOIN(
    SELECT 
    CodigoSKU,
    ROUND(SUM(ReceitaBruta), 2) AS FaturamentoDiaAnterior
    FROM `production-glpg.GJBI.MargemContribuicao`
    WHERE DataProcesso = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY CodigoSKU) FAT_DIA
  ON GJP.CodigoSKU = FAT_DIA.CodigoSKU

  LEFT JOIN(
    SELECT 
    CodigoSKU,
    ROUND(SUM(ReceitaBruta), 2) AS FaturamentoMesCorrente
    FROM `production-glpg.GJBI.MargemContribuicao`
    WHERE DataProcesso BETWEEN DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), MONTH)
    AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY CodigoSKU) FAT_MES
  ON GJP.CodigoSKU = FAT_MES.CodigoSKU

  LEFT JOIN(
    SELECT 
    CodigoSKU,
    ROUND(SUM(ReceitaBruta), 2) AS Faturamento30Dias
    FROM `production-glpg.GJBI.MargemContribuicao`
    WHERE DataProcesso BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY)
    AND DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY CodigoSKU) FAT_30
  ON GJP.CodigoSKU = FAT_30.CodigoSKU

  ORDER BY CodigoSKU) L

  ON
  P.CodigoSKU = L.CodigoSKU
  AND P.Data = L.Data
WHEN MATCHED THEN
  UPDATE SET
    P.Data = L.Data,
    P.CodigoSKU = L.CodigoSKU,
    P.Nome = L.Nome,
    P.Edicao = L.Edicao,
    P.Status = L.Status,
    P.EstoqueDisponivel = L.EstoqueDisponivel,
    P.DiasEmEstoque = L.DiasEmEstoque,
    P.DataProximaEntradaPrevista = L.DataProximaEntradaPrevista,
    P.QuantidadeEncomendada = L.QuantidadeEncomendada,
    P.PrevisaoMes = L.PrevisaoMes,
    P.VendaDiaAnterior = L.VendaDiaAnterior,
    P.VendaMesCorrente = L.VendaMesCorrente,
    P.Venda30Dias = L.Venda30Dias,
    P.VendaTotal = L.VendaTotal,
    P.QtdTotal = L.QtdTotal,
    P.PercTotalVendido = L.PercTotalVendido,
    P.FaturamentoDiaAnterior = L.FaturamentoDiaAnterior,
    P.FaturamentoMesCorrente = L.FaturamentoMesCorrente,
    P.Faturamento30Dias = L.Faturamento30Dias

WHEN NOT MATCHED THEN
  INSERT VALUES (
    L.Data,
    L.CodigoSKU,
    L.Nome,
    L.Edicao,
    L.Status,
    L.EstoqueDisponivel,
    L.DiasEmEstoque,
    L.DataProximaEntradaPrevista,
    L.QuantidadeEncomendada,
    L.PrevisaoMes,
    L.VendaDiaAnterior,
    L.VendaMesCorrente,
    L.Venda30Dias,
    L.VendaTotal,
    L.QtdTotal,
    L.PercTotalVendido,
    L.FaturamentoDiaAnterior,
    L.FaturamentoMesCorrente,
    L.Faturamento30Dias
  )