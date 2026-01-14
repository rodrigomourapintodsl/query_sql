/* Gerador NFS-e Nacional
* Versão==1.01
* Gerada em==14/01/2026;
* ENFE==17.13+;
* PostGreSQL==12+;
* Gerencia Hoteleira 4.1/3.1==10.97+
*/
SELECT NOTASFISCAIS.CODNOTA AS CDDOCFISCAL,
    NOTASFISCAIS.TOTALNOTA AS VLTOTAL,
    -- (SELECT SUM(VALTOTAL) FROM DETNOTAFISCAL 
    --           WHERE DETNOTAFISCAL.TIPOIMPOSTO IN ('S') AND DETNOTAFISCAL.ALIQUOTA = 0
    --           AND DETNOTAFISCAL.CODNOTA = NOTASFISCAIS.CODNOTA 
    --           AND DETNOTAFISCAL.CODHOTEL = NOTASFISCAIS.CODHOTEL) 
    0 AS VLDEDUCOES,
    NOTASFISCAIS.VALBASEISS as VLBASEISS,
    NOTASFISCAIS.TOTALPROD AS VLTOTALPRODUTO,
    --NOTASFISCAIS.TOTALSERV AS VLTOTALSERVICO,
    /*
    Valor líquido = Valor do serviço 
    - Desconto condicionado 
    - Desconto incondicionado 
    - Valores retidos (CP, IRRF, CSLL) 
    - Valores retidos (ISSQN, PIS, COFINS)
    */ 
    NOTASFISCAIS.TOTALNOTA
    --descontos
    +COALESCE((SELECT SUM(DESCITEM) FROM DETNOTAFISCAL 
              WHERE DETNOTAFISCAL.CODNOTA = NOTASFISCAIS.CODNOTA 
              AND DETNOTAFISCAL.CODHOTEL = NOTASFISCAIS.CODHOTEL),0)
    --retidos
    +COALESCE(NOTASFISCAIS.VALPISRET,0)  
    +COALESCE(NOTASFISCAIS.VALCOFINSRET,0)
    +COALESCE(NOTASFISCAIS.VALIRRET,0)
    +COALESCE(NOTASFISCAIS.VALCSLLRET,0)
    +COALESCE(NOTASFISCAIS.VALISSRET,0)
    --VALINSSRET contribuição previdenciária RETIDO
    +0 
    AS VLTOTALSERVICO,
    NOTASFISCAIS.TOTALNOTA AS VALORRECEBIDO,
    COALESCE((SELECT SUM(DESCITEM) FROM DETNOTAFISCAL 
              WHERE DETNOTAFISCAL.CODNOTA = NOTASFISCAIS.CODNOTA 
              AND DETNOTAFISCAL.CODHOTEL = NOTASFISCAIS.CODHOTEL),0) AS VLDESCONTO,
    0.00 AS VLDESCONTOCONDICIONADO, 
    CASE WHEN NOTASFISCAIS.VALISSRET > 0 
      THEN 1 
      ELSE 0 
    END AS TEM_ISS_RETIDO,
    CASE PISCOFINS.CSTPISCOFINS
      WHEN '00' THEN 0
      WHEN '01' THEN 1
      WHEN '02' THEN 2
      WHEN '03' THEN 3
      WHEN '04' THEN 4
      WHEN '05' THEN 5
      WHEN '06' THEN 6
      WHEN '07' THEN 7
      WHEN '08' THEN 8
      WHEN '09' THEN 9
    END AS CSTPISCOFINS,
    CASE 
      WHEN PISCOFINS.CSTPISCOFINS NOT IN ('01','08','09') 
      THEN PISCOFINS.BASEPIS 
    END AS BASEPIS,
    PISCOFINS.ALIQPIS,
    ROUND(PISCOFINS.BASEPIS * PISCOFINS.ALIQPIS /100,2) AS VALPIS_ITEM,
    PISCOFINS.ALIQCOFINS,
    ROUND(PISCOFINS.BASEPIS * PISCOFINS.ALIQCOFINS /100,2) AS VALCOFINS_ITEM,
    CASE 
      WHEN COALESCE(NOTASFISCAIS.VALPISRET,0) + COALESCE(NOTASFISCAIS.VALCOFINSRET,0) > 0 THEN 0 
      WHEN COALESCE(NOTASFISCAIS.VALORPIS,0) + COALESCE(NOTASFISCAIS.VALORCOFINS,0) > 0 THEN 1 
      ELSE 2 
    END AS TEM_PISCOFIN_RETIDO,
    COALESCE(NULLIF(NOTASFISCAIS.VALPISRET,0),NOTASFISCAIS.VALORPIS,0) AS VALPISRET,
    COALESCE(NULLIF(NOTASFISCAIS.VALCOFINSRET,0),NOTASFISCAIS.VALORCOFINS,0) AS VALCOFINSRET,
    0 AS VALINSSRET,
    COALESCE(NOTASFISCAIS.VALIRRET,0) AS VALIRRET,
    COALESCE(NOTASFISCAIS.VALCSLLRET,0) AS VALCSLLRET,
    COALESCE(NOTASFISCAIS.VALISSRET,0) AS VALISSRET,
    COALESCE(IBPT.VLIBPT,NOTASFISCAIS.VLIBPT)
    +COALESCE(IBPT.VLIBPTEST,NOTASFISCAIS.VLIBPTEST)
    +COALESCE(IBPT.VLIBPTMUN,NOTASFISCAIS.VLIBPTMUN) AS TOTALAPROXTRIB,
    COALESCE(IBPT.VLIBPTEST,NOTASFISCAIS.VLIBPTEST) AS VLIBPTEST,
    COALESCE(IBPT.pcaliqest,NOTASFISCAIS.PCALIQIBPTEST) AS PCALIQIBPTEST, 
    COALESCE(IBPT.VLIBPTMUN,NOTASFISCAIS.VLIBPTMUN) AS VLIBPTMUN,
    COALESCE(IBPT.pcaliqmun,NOTASFISCAIS.PCALIQIBPTMUN) AS PCALIQIBPTMUN, 
    COALESCE(IBPT.VLIBPT,NOTASFISCAIS.VLIBPT) AS VLIBPTFED,
    COALESCE(IBPT.pcaliqnac,NOTASFISCAIS.pcaliqibpt) AS PCIBPTFED,
    NOTASFISCAIS.DSOBSIBPT,
/*reforma tributaria*/
cbsibs.IDCSTIVADUAL AS cstclassificacaotributaria,
COALESCE(cbsibs.idclassificacaotributaria,'200048') AS idclassificacaotributaria,
CASE WHEN FLCBSIBS = 1 THEN
coalesce(   
 nullif( cbsibs.vlbase_CBS_federal ,0),
 nullif( cbsibs.vlbase_IBS_estadual ,0),
 nullif( cbsibs.vlbase_IBS_municipal ,0)
)
ELSE 
coalesce(
 nullif( cbsibs_calculada.vlbase_CBS_federal ,0),
 nullif( cbsibs_calculada.vlbase_IBS_estadual ,0),
 nullif( cbsibs_calculada.vlbase_IBS_municipal ,0)
)
END AS VALBASECBSIBS,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.aliquota_CBS_federal 
ELSE 
cbsibs_calculada.aliquota_CBS_federal
END as CBS_Aliquota,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.reducao_CBS_federal 
ELSE 
cbsibs_calculada.reducao_CBS_federal
END
as CBS_PercReducao,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.aliqreal_CBS_federal 
ELSE 
cbsibs_calculada.aliqreal_CBS_federal
END as CBS_Valor,
----
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.aliquota_IBS_estadual
ELSE
cbsibs_calculada.aliquota_IBS_estadual
END as ibsUF_aliquota,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.reducao_IBS_estadual 
ELSE 
cbsibs_calculada.reducao_IBS_estadual
END as ibsUF_PercReducao,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.aliqreal_IBS_estadual 
ELSE 
cbsibs_calculada.aliqreal_IBS_estadual
END as IBSUF_aliquotareal_EFETIVA,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.vlimposto_IBS_estadual 
ELSE 
cbsibs_calculada.vlimposto_IBS_estadual
END as IBSUF_Valor,
----
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.aliquota_IBS_municipal
ELSE
cbsibs_calculada.aliquota_IBS_municipal
END as IBSMun_Aliquota,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.reducao_IBS_municipal
ELSE
cbsibs_calculada.reducao_IBS_municipal
END as IBSMun_PercReducao,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.aliqreal_IBS_municipal
ELSE
cbsibs_calculada.aliqreal_IBS_municipal
END as IBSMun_aliquotareal_EFETIVA,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.vlimposto_IBS_municipal
ELSE
cbsibs_calculada.vlimposto_IBS_municipal
END as IBSMun_Valor,
----
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.vlimposto_IBS_estadual+cbsibs.vlimposto_IBS_municipal 
ELSE
cbsibs_calculada.vlimposto_IBS_estadual+cbsibs_calculada.vlimposto_IBS_municipal
END as IBS_Valor_Total,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
notasfiscais.totalserv+cbsibs.vlimposto_IBS_estadual+cbsibs.vlimposto_IBS_municipal+cbsibs.vlimposto_CBS_federal 
ELSE 
notasfiscais.totalserv+cbsibs_calculada.vlimposto_IBS_estadual+cbsibs_calculada.vlimposto_IBS_municipal+cbsibs_calculada.vlimposto_CBS_federal
END as Total_Com_Tributos
----
/*reforma tributaria*/
  FROM NOTASFISCAIS
  JOIN NFERETORNO ON NOTASFISCAIS.CODNOTA = NFERETORNO.CDNOTA AND NOTASFISCAIS.CODHOTEL = NFERETORNO.CDEMPRESA
  JOIN CONFIGURA4 ON CONFIGURA4.CODHOTEL = NOTASFISCAIS.CODHOTEL
  LEFT JOIN (SELECT DETNOTAFISCAL.CODNOTA,
        DETNOTAFISCAL.CODHOTEL,
        MAX(CASE WHEN DETNOTAFISCAL.CSTPIS = DETNOTAFISCAL.CSTCOFINS THEN DETNOTAFISCAL.CSTPIS END ) AS CSTPISCOFINS,
        SUM(DETNOTAFISCAL.BASEPIS) AS BASEPIS,
        AVG(DETNOTAFISCAL.ALIQPIS) AS ALIQPIS,
        SUM(DETNOTAFISCAL.VALPIS ) AS VALPIS_ITEM,
        AVG(DETNOTAFISCAL.ALIQCOFINS) AS ALIQCOFINS,
        SUM(DETNOTAFISCAL.VALCOFINS ) AS VALCOFINS_ITEM
        FROM DETNOTAFISCAL 
        WHERE DETNOTAFISCAL.CODHOTEL = :CDEMPRESA
          AND DETNOTAFISCAL.CODNOTA = :CDNOTA
          AND DETNOTAFISCAL.VALPIS>0 AND DETNOTAFISCAL.VALCOFINS>0
        GROUP BY DETNOTAFISCAL.CODNOTA, DETNOTAFISCAL.CODHOTEL
  ) AS PISCOFINS ON NOTASFISCAIS.CODNOTA = PISCOFINS.CODNOTA AND NOTASFISCAIS.CODHOTEL = PISCOFINS.CODHOTEL 
LEFT JOIN (SELECT DETNOTAFISCAL.CODHOTEL
        ,DETNOTAFISCAL.CODNOTA
        ,ibptitem.pcaliqnac
        ,ibptitem.pcaliqest
        ,ibptitem.pcaliqmun
        ,sum(TRUNC((ibptitem.pcaliqnac/100 *(DETnotafiscal.valtotal))*100)/100) AS VLIBPT
        ,sum(TRUNC((ibptitem.pcaliqest/100 *(DETnotafiscal.valtotal))*100)/100) AS VLIBPTEST
        ,sum(TRUNC((ibptitem.pcaliqmun/100 *(DETnotafiscal.valtotal))*100)/100) AS VLIBPTMUN
        ,ibpt.dschave
    FROM DETnotafiscal
      JOIN cadproduto
        ON cadproduto.codhotel = DETnotafiscaL.codhotel 
       and cadproduto.codproduto = COALESCE(DETnotafiscal.codprodagrupador,DETnotafiscal.codprodcadastro,DETnotafiscal.codproduto)
    JOIN IBPTITEM 
     ON IBPTITEM.fltabela = 2
    AND IBPTITEM.IDIBPT = COALESCE(NULLIF(right('0'||cadproduto.lst,4),''),'0901')
    AND IBPTITEM.CODHOTEL = cadproduto.CODHOTEL
    JOIN IBPT 
     ON IBPT.CODHOTEL=IBPTITEM.CODHOTEL 
    AND IBPT.CDIBPT=IBPTITEM.CDIBPT
    AND IBPT.FLATIVO=1
    WHERE DETNOTAFISCAL.CODHOTEL = :CDEMPRESA
    AND DETNOTAFISCAL.CODNOTA = :CDNOTA
      GROUP BY DETNOTAFISCAL.CODHOTEL,
        DETNOTAFISCAL.CODNOTA,
        DETNOTAFISCAL.CODPRODUTO,
        DETNOTAFISCAL.ALIQUOTA,
        DETNOTAFISCAL.DESCRICAO,
        CADPRODUTO.LST,
        CADPRODUTO.NCM,
        DETNOTAFISCAL.IDCEST,
        CADPRODUTO.CFPSDENTROMUNIC,
        DETNOTAFISCAL.TIPOIMPOSTO,
        cadproduto.CODHOTEL
        ,ibptitem.pcaliqnac
        ,ibptitem.pcaliqest
        ,ibptitem.pcaliqmun
        ,ibpt.dschave
      ORDER BY DETNOTAFISCAL.TIPOIMPOSTO='S' AND MAX(DETNOTAFISCAL.CODPRODUTO) IS NULL AND MAX(DETNOTAFISCAL.UNIDADE) IS NULL AND MAX(DETNOTAFISCAL.VALUNIT) IS NULL
      ,SUM(DETNOTAFISCAL.VALTOTAL) DESC
    ) AS ibpt
 ON ibpt.CODHOTEL=NOTASFISCAIS.CODHOTEL
AND ibpt.CODNOTA=NOTASFISCAIS.CODNOTA
AND NOTASFISCAIS.VLIBPTMUN IS NULL
LEFT JOIN (SELECT 1 AS FLCBSIBS
      ,CBS.idcst AS IDCSTIVADUAL
      ,CBS.idclassificacao AS idclassificacaotributaria
      ,CBS.pcaliquota     AS aliquota_CBS_federal
      ,CBS.pcreducao      AS reducao_CBS_federal
      ,CBS.pcaliquotareal AS aliqreal_CBS_federal
      ,cbs_federal_tot.vlbase     AS vlbase_CBS_federal
      ,cbs_federal_tot.vlimposto  AS vlimposto_CBS_federal
      ,IBSESTADUAL.pcaliquota     AS aliquota_IBS_estadual
      ,IBSESTADUAL.pcreducao      AS reducao_IBS_estadual
      ,IBSMUNICIPAL.PCALIQUOTAREAL AS aliqreal_IBS_estadual
      ,ibs_estadual_tot.vlbase     AS vlbase_IBS_estadual
      ,ibs_estadual_tot.vlimposto  AS vlimposto_IBS_estadual
      ,IBSMUNICIPAL.pcaliquota     AS aliquota_IBS_municipal
      ,IBSMUNICIPAL.pcreducao      AS reducao_IBS_municipal
      ,IBSMUNICIPAL.pcaliquotareal AS aliqreal_IBS_municipal
      ,ibs_municipal_tot.vlbase     AS vlbase_IBS_municipal
      ,ibs_municipal_tot.vlimposto  AS vlimposto_IBS_municipal
      FROM DETnotafiscal
      JOIN FISCALITEMIMPOSTO AS CBS
        ON CBS.CDORIGEMDOCITEM = DETNOTAFISCAL.DETCODNOTA
        AND CBS.CODHOTEL = DETNOTAFISCAL.CODHOTEL
        AND CBS.FLIMPOSTOABRANGENCIA = 0 -- cbs federal
      JOIN FISCALITEMIMPOSTO AS IBSESTADUAL
        ON IBSESTADUAL.CDORIGEMDOCITEM = DETNOTAFISCAL.DETCODNOTA
        AND IBSESTADUAL.CODHOTEL = DETNOTAFISCAL.CODHOTEL
        AND IBSESTADUAL.FLIMPOSTOABRANGENCIA = 1 -- ibs estadual
      JOIN FISCALITEMIMPOSTO AS IBSMUNICIPAL
        ON IBSMUNICIPAL.CDORIGEMDOCITEM = DETNOTAFISCAL.DETCODNOTA
        AND IBSMUNICIPAL.CODHOTEL = DETNOTAFISCAL.CODHOTEL
        AND IBSMUNICIPAL.FLIMPOSTOABRANGENCIA = 2 -- ibs municipal
      JOIN fiscalimposto AS cbs_federal_tot
      ON  cbs_federal_tot.cdorigemdoc = DETnotafiscaL.codnota
      AND cbs_federal_tot.codhotel = DETnotafiscaL.codhotel
      AND cbs_federal_tot.florigemdoc = 2
      AND cbs_federal_tot.flimpostoabrangencia = 0 -- cbs federal
      JOIN fiscalimposto AS ibs_estadual_tot
      ON ibs_estadual_tot.cdorigemdoc = DETnotafiscaL.codnota
      AND ibs_estadual_tot.codhotel = DETnotafiscaL.codhotel
      AND ibs_estadual_tot.florigemdoc = 2
      AND ibs_estadual_tot.flimpostoabrangencia = 1 -- ibs estadual
      JOIN fiscalimposto AS ibs_municipal_tot
      ON  ibs_municipal_tot.cdorigemdoc = DETnotafiscaL.codnota
      AND ibs_municipal_tot.codhotel = DETnotafiscaL.codhotel
      AND ibs_municipal_tot.florigemdoc = 2
      AND ibs_municipal_tot.flimpostoabrangencia = 2 -- ibs municipal
          WHERE DETnotafiscaL.codhotel = :CDEMPRESA 
         AND DETnotafiscaL.CODNOTA = :CDNOTA
       ORDER BY DETnotafiscal.VALTOTAL,
         DETnotafiscal.DETCODNOTA DESC,
      CBS.CDFISCALITEMIMPOSTO DESC,
      IBSESTADUAL.CDFISCALITEMIMPOSTO DESC, 
      IBSMUNICIPAL.cdfiscalitemimposto DESC,
      cbs_federal_tot.cdfiscalimposto DESC,
      ibs_municipal_tot.cdfiscalimposto DESC,
      ibs_estadual_tot.cdfiscalimposto DESC
      LIMIT 1
) AS cbsibs 
ON CONFIGURA4.FLREFORMATRIBUTARIA = 1
LEFT JOIN (
 SELECT cadproduto.codimpostoibscbs
   ,cst_CBS_IBS.cst
   ,cstibscbs.idclassificacaotributaria
   ,cbs_federal.pcaliquota     AS aliquota_CBS_federal
   ,cbs_federal.pcreducao      AS reducao_CBS_federal
   ,cbs_federal.pcaliquotareal AS aliqreal_CBS_federal
   ,(NOTASFISCAIS.TOTALNOTA-NOTASFISCAIS.VALORPIS-NOTASFISCAIS.VALORCOFINS-NOTASFISCAIS.VALISS ) AS vlbase_CBS_federal
   ,(NOTASFISCAIS.TOTALNOTA-NOTASFISCAIS.VALORPIS-NOTASFISCAIS.VALORCOFINS-NOTASFISCAIS.VALISS ) * (cbs_federal.pcaliquota/100) * ((100-cbs_federal.pcreducao)/100) AS vlimposto_CBS_federal
   ,ibs_estadual.pcaliquota     AS aliquota_IBS_estadual
   ,ibs_estadual.pcreducao      AS reducao_IBS_estadual
   ,ibs_estadual.pcaliquotareal AS aliqreal_IBS_estadual
   ,(NOTASFISCAIS.TOTALNOTA-NOTASFISCAIS.VALORPIS-NOTASFISCAIS.VALORCOFINS-NOTASFISCAIS.VALISS ) AS vlbase_IBS_estadual
   ,(NOTASFISCAIS.TOTALNOTA-NOTASFISCAIS.VALORPIS-NOTASFISCAIS.VALORCOFINS-NOTASFISCAIS.VALISS ) * (ibs_estadual.pcaliquota/100) * ((100-ibs_estadual.pcreducao)/100) AS vlimposto_IBS_estadual
   ,ibs_municipal.pcaliquota     AS aliquota_IBS_municipal
   ,ibs_municipal.pcreducao      AS reducao_IBS_municipal
   ,ibs_municipal.pcaliquotareal AS aliqreal_IBS_municipal
   ,(NOTASFISCAIS.TOTALNOTA-NOTASFISCAIS.VALORPIS-NOTASFISCAIS.VALORCOFINS-NOTASFISCAIS.VALISS ) AS vlbase_IBS_municipal
   ,(NOTASFISCAIS.TOTALNOTA-NOTASFISCAIS.VALORPIS-NOTASFISCAIS.VALORCOFINS-NOTASFISCAIS.VALISS ) * (ibs_municipal.pcaliquota/100) * ((100-ibs_municipal.pcreducao)/100) AS vlimposto_IBS_municipal
   FROM DETnotafiscal
   JOIN NOTASFISCAIS
      ON NOTASFISCAIS.CODNOTA = DETnotafiscal.CODNOTA
      AND NOTASFISCAIS.CODHOTEL = DETnotafiscal.CODHOTEL
   JOIN cadproduto
     ON cadproduto.codhotel = DETnotafiscaL.codhotel 
    and cadproduto.codproduto = COALESCE(DETnotafiscal.codprodagrupador,DETnotafiscal.codprodcadastro,DETnotafiscal.codproduto)
   JOIN CADIMPOSTO AS cst_CBS_IBS
   ON  cst_CBS_IBS.codhotel = cadproduto.codhotel
   AND cst_CBS_IBS.codimposto =  cadproduto.codimpostoibscbs
   AND cst_CBS_IBS.tipoimposto = 'B'
   JOIN cstibscbs 
         ON cstibscbs.codhotel = cst_CBS_IBS.codhotel
   AND cstibscbs.cdcstibscbs =  cst_CBS_IBS.cdcst
   AND cst_CBS_IBS.tipoimposto = 'B'
   JOIN CADIMPOSTOALIQUOTA AS cbs_federal
   ON  cbs_federal.codhotel = cadproduto.codhotel
   AND cbs_federal.codimposto =  cadproduto.codimpostoibscbs
   AND cbs_federal.flabrangencia = 0 -- cbs federal
   JOIN CADIMPOSTOALIQUOTA AS ibs_estadual
   ON  ibs_estadual.codhotel = cadproduto.codhotel
   AND ibs_estadual.codimposto =  cadproduto.codimpostoibscbs
   AND ibs_estadual.flabrangencia = 1 -- ibs estadual
   JOIN CADIMPOSTOALIQUOTA AS ibs_municipal
   ON  ibs_municipal.codhotel = cadproduto.codhotel
   AND ibs_municipal.codimposto =  cadproduto.codimpostoibscbs
   AND ibs_municipal.flabrangencia = 2 -- ibs municipal
   WHERE DETNOTAFISCAL.CODHOTEL = :CDEMPRESA
       AND DETNOTAFISCAL.CODNOTA = :CDNOTA
   ORDER BY DETnotafiscal.VALTOTAL,
      DETnotafiscal.DETCODNOTA DESC,
   cbs_federal.CDCADIMPOSTOALIQUOTA DESC,
   ibs_estadual.CDCADIMPOSTOALIQUOTA DESC, 
   ibs_municipal.CDCADIMPOSTOALIQUOTA DESC
) AS cbsibs_calculada
ON CONFIGURA4.FLREFORMATRIBUTARIA = 1
AND cbsibs.vlbase_CBS_federal IS NULL
  WHERE NFERETORNO.CDEMPRESA = :CDEMPRESA
  AND NFERETORNO.CDNOTA = :CDNOTA
  AND NFERETORNO.FLTIPONOTA = 1 