MERGE
  `production-glpg.GJBI.PosicaoEstoque` GPE
USING
  `production-glpg.Loading.Oracle_PosicaoEstoque` OPE
  ON
  GPE.CodigoSKU = OPE.Item_Name
  AND GPE.TipoEstoque = OPE.Inventory_Organization_Code
  AND GPE.Data = CURRENT_DATE
WHEN MATCHED THEN
  UPDATE SET
    Data = CURRENT_DATE,
    Quantidade = SAFE_CAST(OPE.Quantity AS INT64),
    TipoEstoque = OPE.Description

WHEN NOT MATCHED THEN
  INSERT VALUES (
    OPE.Item_Name,
    CURRENT_DATE,
    SAFE_CAST(OPE.Quantity AS INT64),
    OPE.Description
  )