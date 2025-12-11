SELECT
    LANCCAIXA.CDLANCCAIXA,
LEFT(
    CONCAT_WS('|',
(SELECT string_agg(templateexpressao.dsapelido,' ' ORDER BY templateexpressao.CDtemplateexpressao)
    FROM configuracao AS LAYOUTNFS 
    JOIN TEMPLATE on LAYOUTNFS.dsparametro ='CFGLAYOUTNFS' AND LAYOUTNFS.cdtipo = 3 
    AND TEMPLATE.cdtemplate = LAYOUTNFS.nrvalorint AND TEMPLATE.fltipo=0 --Nota fiscal
    JOIN templateexpressao ON templateexpressao.cdtemplate = TEMPLATE.cdtemplate 
    WHERE templateexpressao.dspipeline = 'CabecalhoNotaFiscal'
AND LAYOUTNFS.cdempresa = :CDEMPRESA)
,CASE WHEN LANCCAIXACONTAHOTEL.NMHOSPEDEPRINCIPAL=LANCCAIXACONTAHOTEL.nmdemaishospedes THEN
'Titular: '|| 
    upper(trim(regexp_replace(NULLIF(
    LANCCAIXACONTAHOTEL.NMHOSPEDEPRINCIPAL,'')
    ,'[^0-9A-Za-z ŠŽšžŸÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðñòóôõöùúûüýÿ]',' ','gi')))
ELSE
'Hospedes: ' || 
    upper(trim(regexp_replace(NULLIF(
    LANCCAIXACONTAHOTEL.nmdemaishospedes,'')
    ,'[^0-9A-Za-z ,ŠŽšžŸÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðñòóôõöùúûüýÿ]',' ','gi')))
END
,
CASE WHEN lanccaixacontahotel.DTIN = lanccaixacontahotel.DTOUT THEN
'Day-Use: '||lanccaixacontahotel.DTOUT
WHEN date_trunc('month',lanccaixacontahotel.DTIN) = date_trunc('month',lanccaixacontahotel.DTOUT) THEN
'In: ' || TO_CHAR(lanccaixacontahotel.DTIN,'DD')|| ' à ' ||
'Out: ' || TO_CHAR(lanccaixacontahotel.DTOUT,'DD/MM/YYYY')
WHEN date_trunc('year',lanccaixacontahotel.DTIN) = date_trunc('year',lanccaixacontahotel.DTOUT) THEN
'In: ' || TO_CHAR(lanccaixacontahotel.DTIN,'DD/MM')|| ' à ' ||
'Out: ' || TO_CHAR(lanccaixacontahotel.DTOUT,'DD/MM/YYYY')
ELSE
'In: ' || TO_CHAR(lanccaixacontahotel.DTIN,'DD/MM/YYYY')|| ' - ' ||
'Out: ' || TO_CHAR(lanccaixacontahotel.DTOUT,'DD/MM/YYYY')
END
,
'UH: ' || LANCCAIXACONTAHOTEL.CDUH
,'Razao: '|| LANCCAIXACONTAHOTEL.idcontafechamento
,'Observacoes: ' || 
    NULLIF(TRIM(regexp_replace(
           DOCFISCAL.BLOBSERVACAO     
    ,'[^0-9A-Za-z !"?@#$%.,_&%: \(\)|\[\]\\\/\*\+\-\='||chr(10)||chr(13)||'ŠŽšžŸÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðñòóôõöùúûüýÿ]',' ','gi'))
    ,'')
,
(SELECT string_agg(templateexpressao.dsapelido,' ' ORDER BY templateexpressao.CDtemplateexpressao)
    FROM configuracao AS LAYOUTNFS 
    JOIN TEMPLATE on LAYOUTNFS.dsparametro ='CFGLAYOUTNFS' AND LAYOUTNFS.cdtipo=3 
    AND TEMPLATE.cdtemplate = LAYOUTNFS.nrvalorint AND TEMPLATE.fltipo=0 --Nota fiscal
    JOIN templateexpressao ON templateexpressao.cdtemplate = TEMPLATE.cdtemplate 
    WHERE templateexpressao.dspipeline = 'ServicosNotaFiscal'
AND LAYOUTNFS.cdempresa = :CDEMPRESA)
,
'Reserva: '||LANCCAIXACONTAHOTEL.cdlocalizadorreserva
,
'NF-e:'||DOCFISCAL_NFE.idchave
)
,2000) AS OBSERVACOES
,DOCFISCAL.DSOBSIBPT,
CASE WHEN lanccaixacontahotel.DTOUT is not null THEN  'HOSPEDAGEM' END AS EVENTO_NOME,
lanccaixacontahotel.DTIN,
lanccaixacontahotel.DTOUT,
LANCCAIXACONTAHOTEL.CDUH
FROM DOCFISCAL
 LEFT JOIN LANCCAIXA ON DOCFISCAL.CDDOCFISCAL = LANCCAIXA.CDDOCFISCALNFSER AND LANCCAIXA.CDEMPRESA = DOCFISCAL.CDEMPRESA
 LEFT JOIN LANCCAIXACONTAHOTEL ON LANCCAIXA.CDLANCCAIXA = LANCCAIXACONTAHOTEL.CDLANCCAIXA AND DOCFISCAL.CDEMPRESA = LANCCAIXACONTAHOTEL.CDEMPRESA
 LEFT JOIN NFERETORNO AS DOCFISCAL_NFE ON DOCFISCAL_NFE.CDNOTA= LANCCAIXA.CDDOCFISCALNF AND LANCCAIXA.CDEMPRESA = DOCFISCAL_NFE.CDEMPRESA
 WHERE DOCFISCAL.CDDOCFISCAL = :CDNOTA AND DOCFISCAL.CDEMPRESA = :CDEMPRESA
ORDER BY LANCCAIXA.CDLANCCAIXA,LANCCAIXACONTAHOTEL.CDLANCCAIXACONTAHOTEL