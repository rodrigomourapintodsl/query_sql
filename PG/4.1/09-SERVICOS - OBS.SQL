SELECT 
    NOTASFISCAIS.CODNOTA,NOTASFISCAIS.CODRAZAO,
LEFT(
    CONCAT_WS('|',NULL
/*,(SELECT --OBS FIXA INICIO
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
(regexp_match(REPLACE(
    (regexp_match(convert_from(modelosrel.modelo, 'UTF8') ,'\:\ TppLabel\r\n[^A-Za-z0-9]{0,30}UserName\ \=\ \'''||'CabecalhoNotaFiscal'||'\''\r\n[^'']{1,255}Caption\ \=[^A-Za-z0-9]{0,30}([^\\]{1,255})'))[1]
,''' +'||chr(13)||chr(10)||'        ''',''),'([^\r]{1,255})'''))[1]
,
'''#'||ascii('À')||'''','À'),
'''#'||ascii('Á')||'''','Á'),
'''#'||ascii('Â')||'''','Â'),
'''#'||ascii('Ã')||'''','Ã'),
'''#'||ascii('Ç')||'''','Ç'),
'''#'||ascii('È')||'''','È'),
'''#'||ascii('É')||'''','É'),
'''#'||ascii('Ê')||'''','Ê'),
'''#'||ascii('Ì')||'''','Ì'),
'''#'||ascii('Í')||'''','Í'),
'''#'||ascii('Î')||'''','Î'),
'''#'||ascii('Ò')||'''','Ò'),
'''#'||ascii('Ó')||'''','Ó'),
'''#'||ascii('Ô')||'''','Ô'),
'''#'||ascii('Õ')||'''','Õ'),
'''#'||ascii('Ù')||'''','Ù'),
'''#'||ascii('Ú')||'''','Ú'),
'''#'||ascii('Û')||'''','Û'),
'''#'||ascii('à')||'''','à'),
'''#'||ascii('á')||'''','á'),
'''#'||ascii('â')||'''','â'),
'''#'||ascii('ã')||'''','ã'),
'''#'||ascii('ç')||'''','ç'),
'''#'||ascii('è')||'''','è'),
'''#'||ascii('é')||'''','é'),
'''#'||ascii('ê')||'''','ê'),
'''#'||ascii('ì')||'''','ì'),
'''#'||ascii('í')||'''','í'),
'''#'||ascii('î')||'''','î'),
'''#'||ascii('ò')||'''','ò'),
'''#'||ascii('ó')||'''','ó'),
'''#'||ascii('ô')||'''','ô'),
'''#'||ascii('õ')||'''','õ'),
'''#'||ascii('ù')||'''','ù'),
'''#'||ascii('ú')||'''','ú'),
'''#'||ascii('û')||'''','û')
FROM modelosrel 
WHERE modelosrel.tiporel = 9  
AND modelosrel.CODHOTEL = :CDEMPRESA
LIMIT 1 --OBS FIXA INICIO
)*/
,CASE 
    WHEN NOTASFISCAIS.HOSPEDE1 > ' ' AND NOTASFISCAIS.HOSPEDE2 > ' ' 
    AND NOTASFISCAIS.HOSPEDE2 NOT IN ('HOSPEDE;','PASSANTE;','CONSUMIDOR;','ACOMPANHANTE;','ACOMPANHANTE1;','ACOMPANHANTE2;','ACOMPANHANTE3;','ACOMPANHANTE4;','ACOMPANHANTE5;','ACOMPANHANTE6;')
    THEN 
        'Hospedes: '|| 
            upper(trim(regexp_replace(NULLIF(
            TRIM(NOTASFISCAIS.HOSPEDE1)||',sv '||REPLACE(LEFT(NOTASFISCAIS.HOSPEDE2,-1),';',', '),'')
            ,'[^0-9A-Za-z ,ŠŽšžŸÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðñòóôõöùúûüýÿ]',' ','gi')))
    WHEN NOTASFISCAIS.HOSPEDE1 > ' '
    THEN
        'Titular: '|| 
            upper(trim(regexp_replace(NULLIF(
            NOTASFISCAIS.HOSPEDE1,'')
            ,'[^0-9A-Za-z ŠŽšžŸÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðñòóôõöùúûüýÿ]',' ','gi')))
END
,
CASE WHEN NOTASFISCAIS.DATAHORAIN = NOTASFISCAIS.DATAHORAOUT THEN
'Day-Use: '||NOTASFISCAIS.DATAHORAOUT
WHEN date_trunc('month',NOTASFISCAIS.DATAHORAIN) = date_trunc('month',NOTASFISCAIS.DATAHORAOUT) THEN
'In: ' || TO_CHAR(NOTASFISCAIS.DATAHORAIN,'DD')|| ' à ' ||
'Out: ' || TO_CHAR(NOTASFISCAIS.DATAHORAOUT,'DD/MM/YYYY')
WHEN date_trunc('year',NOTASFISCAIS.DATAHORAIN) = date_trunc('year',NOTASFISCAIS.DATAHORAOUT) THEN
'In: ' || TO_CHAR(NOTASFISCAIS.DATAHORAIN,'DD/MM')|| ' à ' ||
'Out: ' || TO_CHAR(NOTASFISCAIS.DATAHORAOUT,'DD/MM/YYYY')
ELSE
'In: ' || TO_CHAR(NOTASFISCAIS.DATAHORAIN,'DD/MM/YYYY')|| ' - ' ||
'Out: ' || TO_CHAR(NOTASFISCAIS.DATAHORAOUT,'DD/MM/YYYY')
END
,'Observacoes: ' || NULLIF(CONVERT_FROM(NOTASFISCAIS.OBSERVACAO, 'LATIN1'),'')
,(SELECT STRING_AGG(OBSIMPFISCAL,'|') FROM (
        SELECT CADIMPOSTO.OBSIMPFISCAL
        FROM DETNOTAFISCAL 
         JOIN CADPRODUTO ON CADPRODUTO.CODPRODUTO=
          COALESCE(NULLIF( DETNOTAFISCAL.CODPRODAGRUPADOR,0),
          COALESCE(NULLIF( DETNOTAFISCAL.CODPRODCADASTRO ,0),
          COALESCE(NULLIF( DETNOTAFISCAL.CODPRODUTO,0)
          )))
          AND CADPRODUTO.CODHOTEL=DETNOTAFISCAL.CODHOTEL
        JOIN CADIMPOSTO ON CADIMPOSTO.CODIMPOSTO = COALESCE(DETNOTAFISCAL.CODIMPOSTO,CADPRODUTO.CODIMPOSTO)
          AND CADIMPOSTO.TIPOIMPOSTO = 'S'
          AND CADIMPOSTO.CODHOTEL = DETNOTAFISCAL.CODHOTEL
        WHERE DETNOTAFISCAL.CODHOTEL = :CDEMPRESA
          AND DETNOTAFISCAL.CODNOTA = :CDNOTA
          AND DETNOTAFISCAL.CODPRODUTO IS NOT NULL 
          AND DETNOTAFISCAL.TIPOIMPOSTO = 'S'
        GROUP BY CADIMPOSTO.OBSIMPFISCAL
) AS OBSIMPFISCAL_SERVICOSNOTAFISCAL)
,'UH: ' || CASE WHEN RAZOES.TIPOCONTA = '1' THEN RAZOES.CODCONTA END
,COALESCE(NULL
,'Razao: '||RAZOES.NRORAZAO
,'PdvaRazao: '||PDVARAZAO.NRORAZAO
)
,'Reserva: '       ||(SELECT MAX(reserva.localizadorol) FROM detestat JOIN ESTATISTICA ON detestat.ACESSO = ESTATISTICA.ACESSO JOIN RESERVA ON RESERVA.CODRESERVA = ESTATISTICA.NRORESERVA  WHERE detestat.ACESSODET = RAZOES.ACESSO AND reserva.localizadorol > '0')
--,'Reserva Balcão: '||(SELECT MAX(reserva.NRORESERVA   ) FROM detestat JOIN ESTATISTICA ON detestat.ACESSO = ESTATISTICA.ACESSO JOIN RESERVA ON RESERVA.CODRESERVA = ESTATISTICA.NRORESERVA  WHERE detestat.ACESSODET = RAZOES.ACESSO AND NOT reserva.localizadorol > '0')
,'NF-e: '||(
SELECT STRING_AGG(NFERETORNO.IDCHAVE,',')
    FROM NOTASFISCAIS
    JOIN NOTASFISCAIS AS NOTASFISCAIS_PRODUTO
    ON NOTASFISCAIS_PRODUTO.CODRAZAO = NOTASFISCAIS.CODRAZAO
    AND NOTASFISCAIS_PRODUTO.CODHOTEL = NOTASFISCAIS.CODHOTEL
    JOIN NFERETORNO ON NOTASFISCAIS_PRODUTO.CODNOTA=NFERETORNO.CDNOTA
     AND NOTASFISCAIS_PRODUTO.CODHOTEL=NFERETORNO.CDEMPRESA 
    WHERE NOTASFISCAIS.CODHOTEL = :CDEMPRESA
    AND NOTASFISCAIS.CODNOTA = :CDNOTA
    AND NOT NOTASFISCAIS_PRODUTO.CODHOTEL = :CDEMPRESA
    AND NOT NOTASFISCAIS_PRODUTO.CODNOTA = :CDNOTA
    AND NFERETORNO.FLSTATUS = 2
    AND NOT NOTASFISCAIS_PRODUTO.SITUACAO='C' 
    AND NFERETORNO.FLTIPONOTA = 0
    LIMIT 1
)
),2000) AS OBSERVACOES
,NOTASFISCAIS.DSOBSIBPT,
CASE WHEN NOTASFISCAIS.DATAHORAOUT IS NOT NULL THEN  'HOSPEDAGEM' END AS EVENTO_NOME,
NOTASFISCAIS.DATAHORAIN AS DTIN,
NOTASFISCAIS.DATAHORAOUT AS DTOUT,
CASE WHEN RAZOES.TIPOCONTA = '1' THEN RAZOES.CODCONTA END AS CDUH
FROM NOTASFISCAIS
  LEFT JOIN RAZOES
         ON NOTASFISCAIS.CODRAZAO = RAZOES.CODRAZAO
        AND NOT NOTASFISCAIS.ORIGEM IN (5) 
        AND NOTASFISCAIS.CODHOTEL = RAZOES.CODHOTEL
  LEFT JOIN PDVARAZAO
         ON NOTASFISCAIS.CODRAZAO = PDVARAZAO.CODRAZAO
        AND NOTASFISCAIS.ORIGEM IN (5) 
        AND NOTASFISCAIS.CODHOTEL = PDVARAZAO.CODHOTEL
WHERE NOTASFISCAIS.CODHOTEL = :CDEMPRESA
AND   NOTASFISCAIS.CODNOTA = :CDNOTA