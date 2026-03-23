/* Gerador NFS-e Nacional
* Versão==1.01
* Gerada em==19/03/2026;
* ENFE==17.17+;
* PostGreSQL==12+;
* Gerencia Hoteleira 4.1/3.1==10.97+
*/


	

SELECT 
    NOTASFISCAIS.CODNOTA AS CDDOCFISCAL,
    CONFIG.VERSAO_NACIONAL,
/*---ibpt 01/02/2026---*/
	CASE
		WHEN NOTASFISCAIS.VLIBPT+NOTASFISCAIS.VLIBPTEST+NOTASFISCAIS.VLIBPTMUN>0
		THEN 
ELSE
				((15.45))  AS PCIBPTFED,
	TRUNC((		((15.45))     /100 *(NOTASFISCAIS.TOTALNOTA))*100)/100  AS VLIBPTFED,
				(( 0.00)) AS PCALIQIBPTEST, 
				(( 0.00)) AS VLIBPTEST,
				(( 5.00)) AS PCALIQIBPTMUN, 
	TRUNC((		(( 5.00))     /100 *(NOTASFISCAIS.TOTALNOTA))*100)/100 AS VLIBPTMUN, 
	TRUNC(((	((15.45)) + ((5.00))    ) /100 *(NOTASFISCAIS.TOTALNOTA))*100)/100 AS TOTALAPROXTRIB,
    /*---ibpt---*/

/*Valores_Totais*/
    NOTASFISCAIS.TOTALNOTA -COALESCE(notasfiscais.totalterc,0) AS VLTOTAL,
    -- (SELECT SUM(VALTOTAL) FROM DETNOTAFISCAL 
    --           WHERE DETNOTAFISCAL.TIPOIMPOSTO IN ('S') AND DETNOTAFISCAL.ALIQUOTA = 0
    --           AND DETNOTAFISCAL.CODNOTA = NOTASFISCAIS.CODNOTA 
    --           AND DETNOTAFISCAL.CODHOTEL = NOTASFISCAIS.CODHOTEL)
    0 AS VLDEDUCOES,
    CASE 
		WHEN NOTASFISCAIS.SITUACAO = 'C' 
		THEN NOTASFISCAIS.TOTALNOTA-COALESCE(notasfiscais.totalterc,0)
		ELSE NOTASFISCAIS.VALBASEISS 
    END as VLBASEISS,

    NOTASFISCAIS.TOTALPROD AS VLTOTALPRODUTO,
	
    /*--NOTASFISCAIS.TOTALSERV AS VLTOTALSERVICO,
    Valor líquido = Valor do serviço 
    - Desconto condicionado 
    - Desconto incondicionado 
    - Valores retidos (CP, IRRF, CSLL) 
    - Valores retidos (ISSQN, PIS, COFINS)
    *se 1.01+ PIS e COFINS RETIDO não faz mais parte do calculo
    */ 
    +NOTASFISCAIS.TOTALNOTA-COALESCE(notasfiscais.totalterc,0)
    +CASE WHEN NOTASFISCAIS.SITUACAO = 'C' THEN 0 ELSE
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
    END AS VLTOTALSERVICO,

    CASE WHEN NOTASFISCAIS.SITUACAO = 'C' THEN 0 ELSE
    +COALESCE(NOTASFISCAIS.VALPISRET,0)  
    +COALESCE(NOTASFISCAIS.VALCOFINSRET,0)
    +COALESCE(NOTASFISCAIS.VALIRRET,0)
    +COALESCE(NOTASFISCAIS.VALCSLLRET,0)
    +COALESCE(NOTASFISCAIS.VALISSRET,0)
     END AS TOTALRETIDOS, -- vTotalRet

    NOTASFISCAIS.TOTALNOTA AS VALORRECEBIDO,
    COALESCE((SELECT SUM(DESCITEM) FROM DETNOTAFISCAL 
              WHERE DETNOTAFISCAL.CODNOTA = NOTASFISCAIS.CODNOTA 
              AND DETNOTAFISCAL.CODHOTEL = NOTASFISCAIS.CODHOTEL),0)
    AS VLDESCONTO,

  0 AS VLDESCONTOCONDICIONADO, 

    CASE 
      WHEN NOTASFISCAIS.SITUACAO = 'C' THEN 0 
      WHEN NOTASFISCAIS.VALISSRET > 0 
      THEN 1 
      ELSE 0 
    END AS TEM_ISS_RETIDO,

	CASE  CONFIG.VERSAO_NACIONAL
	WHEN 1.00 THEN 
	   CASE WHEN PISCOFINS.CSTPISCOFINS < '40' THEN
		 PISCOFINS.CSTPISCOFINS
	   END
	ELSE -- 1.01+
	PISCOFINS.CSTPISCOFINS
	END AS CSTPISCOFINS,

	CASE CONFIG.VERSAO_NACIONAL
	WHEN 1.00 THEN
		CASE WHEN PISCOFINS.CSTPISCOFINS < '40' THEN
			 COALESCE(NULLIF( PISCOFINS.BASEPIS ,0), ( NOTASFISCAIS.totalprod + NOTASFISCAIS.totalserv ))
	   END 
	ELSE -- 1.01+
	COALESCE(NULLIF( PISCOFINS.BASEPIS ,0), ( NOTASFISCAIS.totalprod + NOTASFISCAIS.totalserv ))
	END AS BASEPIS,

	CASE
		WHEN NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALORPIS = 0 AND NOTASFISCAIS.VALORCOFINS = 0 
		THEN 0
		WHEN NOTASFISCAIS.VALPISRET >0 AND NOTASFISCAIS.VALPISRET / ( NOTASFISCAIS.totalprod + NOTASFISCAIS.totalserv )*100 BETWEEN 0.65 -0.05 and 0.65 +0.05 
		THEN 0.65
		WHEN NOTASFISCAIS.VALPISRET >0 AND NOTASFISCAIS.VALPISRET / ( NOTASFISCAIS.totalprod + NOTASFISCAIS.totalserv )*100 BETWEEN 1.65 -0.05 and 1.65 +0.05 
		THEN 1.65
		WHEN PISCOFINS.ALIQPIS >0 THEN PISCOFINS.ALIQPIS
	END AS ALIQPIS,
--
	CASE
		WHEN NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALORPIS = 0 AND NOTASFISCAIS.VALORCOFINS = 0 THEN 0
		WHEN NOTASFISCAIS.VALPISRET > 0 THEN NOTASFISCAIS.VALPISRET
		WHEN CONFIGURA.CGC IN ('02.227.095/0001-06') THEN 0 -- desativado ticket 811537
		WHEN NOTASFISCAIS.VALORPIS > 0 THEN NOTASFISCAIS.VALORPIS
		ELSE ROUND(PISCOFINS.BASEPIS * PISCOFINS.ALIQPIS) /100 
	END AS VALPIS_ITEM,


	CASE
		WHEN NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALORPIS = 0 AND NOTASFISCAIS.VALORCOFINS = 0 
		THEN 0
		WHEN NOTASFISCAIS.VALCOFINSRET >0 AND NOTASFISCAIS.VALCOFINSRET / ( NOTASFISCAIS.totalprod + NOTASFISCAIS.totalserv )*100 BETWEEN 3.00 -0.05 and 3.00 +0.05 
		THEN 3.00
		WHEN NOTASFISCAIS.VALCOFINSRET >0 AND NOTASFISCAIS.VALCOFINSRET / ( NOTASFISCAIS.totalprod + NOTASFISCAIS.totalserv )*100 BETWEEN 7.60 -0.05 and 7.60 +0.05 
		THEN 7.60
		WHEN PISCOFINS.ALIQCOFINS   >0   THEN PISCOFINS.ALIQCOFINS
	END AS ALIQCOFINS,

	CASE
		WHEN NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALORPIS = 0 AND NOTASFISCAIS.VALORCOFINS = 0 THEN 0
		WHEN NOTASFISCAIS.VALCOFINSRET > 0 THEN NOTASFISCAIS.VALCOFINSRET
		WHEN CONFIGURA.CGC IN ('02.227.095/0001-06') THEN 0 -- desativado ticket 811537
		WHEN NOTASFISCAIS.VALORCOFINS > 0 THEN NOTASFISCAIS.VALORCOFINS
		ELSE ROUND(PISCOFINS.BASEPIS * PISCOFINS.ALIQCOFINS) /100 
	END AS VALCOFINS_ITEM,

/*tem retenção de pis e cofins*/
	CASE WHEN NOT CAST( :VERSAO AS TEXT) LIKE '%.%' 
	-- Versão antes da 17.16 12/03/2026
	THEN
		CASE
			WHEN 0 = (COALESCE(NOTASFISCAIS.VALPISRET,0)+COALESCE(NOTASFISCAIS.VALPISRET,0)+COALESCE(NOTASFISCAIS.VALPISRET,0)+COALESCE(NOTASFISCAIS.VALPISRET,0))
			THEN 1 -- xml(2) PIS/COFINS Não Retido, 1.00 Antigo;
			WHEN NOTASFISCAIS.VALPISRET > 0 AND NOTASFISCAIS.VALCOFINSRET > 0 THEN 0 -- xml(1) PIS/COFINS Retido, 1.00 Antigo;
			WHEN CONFIGURA.CGC IN ('02.227.095/0001-06') THEN NULL  -- desativado ticket 811537
			ELSE 1
		END + CASE WHEN CONFIG.IDMODELO=0 THEN 0 ELSE 1 END
	ELSE 
	-- Versão após da 17.16 12/03/2026
	CASE  CONFIG.VERSAO_NACIONAL
	WHEN 1.00 THEN
		CASE
			WHEN NOTASFISCAIS.VALPISRET > 0 AND NOTASFISCAIS.VALCOFINSRET > 0 THEN 1
			WHEN CONFIGURA.CGC IN ('02.227.095/0001-06') THEN 99  -- desativado ticket 811537 
			ELSE 2
		END
	ELSE -- 1.01+
	CASE WHEN NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALORPIS = 0 AND NOTASFISCAIS.VALORCOFINS = 0 THEN 0
	  ELSE CASE   
		+ CASE WHEN NOTASFISCAIS.VALPISRET    > 0 THEN 100 ELSE 0 END
		+ CASE WHEN NOTASFISCAIS.VALCOFINSRET > 0 THEN  10 ELSE 0 END
		+ CASE WHEN NOTASFISCAIS.VALCSLLRET   > 0 THEN   1 ELSE 0 END
		WHEN 000 THEN 0 -- PIS/COFINS/CSLL Não Retidos;
		--Retido      1 -- PIS/COFINS Retido, 1.00 Antigo;
		--NaoRetido   2 -- PIS/COFINS Não Retido, 1.00 Antigo;
		WHEN 111 THEN 3 -- PIS/COFINS/CSLL Retidos;
		WHEN 110 THEN 4 -- PIS/COFINS Retidos, CSLL Não Retido;
		WHEN 100 THEN 5 -- PIS Retido, COFINS/CSLL Não Retido;
		WHEN 010 THEN 6 -- COFINS Retido, PIS/CSLL Não Retido;
		WHEN 011 THEN 7 -- PIS Não Retido, COFINS/CSLL Retidos;
		WHEN 001 THEN 8 -- PIS/COFINS Não Retidos, CSLL Retido;
		WHEN 101 THEN 9 -- COFINS Não Retido, PIS/CSLL Retidos;
		END
	END END
	END 
	AS TEM_PISCOFIN_RETIDO,

	CASE
		WHEN NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALORPIS = 0 AND NOTASFISCAIS.VALORCOFINS = 0 THEN 0
		ELSE COALESCE(NULLIF(NOTASFISCAIS.VALPISRET,0),NOTASFISCAIS.VALORPIS,0)
	END AS VALPISRET,

	CASE
		WHEN NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALPISRET = 0 AND NOTASFISCAIS.VALORPIS = 0 AND NOTASFISCAIS.VALORCOFINS = 0 THEN 0
		ELSE  COALESCE(NULLIF(NOTASFISCAIS.VALCOFINSRET,0),NOTASFISCAIS.VALORCOFINS,0) 
	END AS VALCOFINSRET,

	0 AS VALINSSRET,
	NOTASFISCAIS.VALIRRET AS VALIRRET,

	+COALESCE(NOTASFISCAIS.VALPISRET,0)  --*se 1.01+ PIS e COFINS RETIDO não faz mais parte do calculo
	+COALESCE(NOTASFISCAIS.VALCOFINSRET,0) --*se 1.01+ PIS e COFINS RETIDO não faz mais parte do calculo
	+COALESCE(NOTASFISCAIS.VALCSLLRET,0) AS VALCSLLRET,
	COALESCE(NOTASFISCAIS.VALISSRET,0) AS VALISSRET,
/*IBPT*/
	+NOTASFISCAIS.VLIBPT
	+NOTASFISCAIS.VLIBPTEST
	+NOTASFISCAIS.VLIBPTMUN 	AS TOTALAPROXTRIB,
	NOTASFISCAIS.VLIBPTEST 		AS VLIBPTEST,
	NOTASFISCAIS.PCALIQIBPTEST 	AS PCALIQIBPTEST, 
	NOTASFISCAIS.VLIBPTMUN 		AS VLIBPTMUN,
	NOTASFISCAIS.PCALIQIBPTMUN 	AS PCALIQIBPTMUN, 
	NOTASFISCAIS.VLIBPT 		AS VLIBPTFED,
	NOTASFISCAIS.pcaliqibpt 	AS PCIBPTFED,
	NOTASFISCAIS.DSOBSIBPT,
/*reforma tributaria*/
-- cbsibs.IDCSTIVADUAL AS cstclassificacaotributaria,
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
END as CBS_Aliquotareal_EFETIVA,
CASE WHEN cbsibs.FLCBSIBS = 1 THEN
cbsibs.vlimposto_CBS_federal 
ELSE 
cbsibs_calculada.vlimposto_CBS_federal
END AS CBS_Valor,
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
  JOIN CONFIGURA ON configura.CODHOTEL = NOTASFISCAIS.CODHOTEL
  JOIN CONFIGURA4 ON CONFIGURA4.CODHOTEL = NOTASFISCAIS.CODHOTEL
  LEFT JOIN (  SELECT DETNOTAFISCAL.CODNOTA,
        DETNOTAFISCAL.CODHOTEL,
        MAX(CASE WHEN DETNOTAFISCAL.CSTPIS = DETNOTAFISCAL.CSTCOFINS THEN DETNOTAFISCAL.CSTPIS END ) AS CSTPISCOFINS,
        SUM(DETNOTAFISCAL.BASEPIS) AS BASEPIS,
        MAX(DETNOTAFISCAL.ALIQPIS) AS ALIQPIS,
        SUM(DETNOTAFISCAL.VALPIS ) AS VALPIS_ITEM,
        MAX(DETNOTAFISCAL.ALIQCOFINS) AS ALIQCOFINS,
        SUM(DETNOTAFISCAL.VALCOFINS ) AS VALCOFINS_ITEM
        FROM DETNOTAFISCAL 
        WHERE DETNOTAFISCAL.CODHOTEL = :CDEMPRESA
          AND DETNOTAFISCAL.CODNOTA = :CDNOTA
          --AND DETNOTAFISCAL.VALPIS>0 AND DETNOTAFISCAL.VALCOFINS>0
        GROUP BY DETNOTAFISCAL.CODNOTA, DETNOTAFISCAL.CODHOTEL
  ) AS PISCOFINS ON NOTASFISCAIS.CODNOTA = PISCOFINS.CODNOTA AND NOTASFISCAIS.CODHOTEL = PISCOFINS.CODHOTEL 
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
LEFT JOIN (SELECT CDEMPRESA, 
    CAST((regexp_match(NFECONFIG.blconfig,'(\[NF.)+'||
            'SERVICO'      ||'\][\r\n]{1,2}.*[\r\n]{1,2}'||
            'MODELO'       ||'=([^\n\r]{0,2})[\r\n]{1,2}'
    ))[2] AS INT) 
    AS IDMODELO,
    CAST(COALESCE((regexp_match(NFECONFIG.blconfig,'(\[NF.)+'||
        'SERVICO'      ||'\][\r\n]{1,2}.*[\r\n]{1,2}'||
        'VERSAO'       ||'=([^\n\r]{0,6})[\r\n]{1,2}'
    ))[2],'1.00') AS NUMERIC(5,2)) 
   AS VERSAO_NACIONAL
   FROM nfeconfig WHERE NFECONFIG.cdempresa = :CDEMPRESA AND NFECONFIG.fltiponotaes = 0
) AS CONFIG ON CONFIG.CDEMPRESA = NFERETORNO.CDEMPRESA
  WHERE NFERETORNO.CDEMPRESA = :CDEMPRESA
  AND NFERETORNO.CDNOTA = :CDNOTA
  AND NFERETORNO.FLTIPONOTA = 1 