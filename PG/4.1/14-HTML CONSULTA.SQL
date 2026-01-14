SELECT
NFERETORNO.CDNOTA AS CODNOTA, 
NFERETORNO.CDEMPRESA AS CODHOTEL,
RAZOES.NRORAZAO,
COALESCE(NOTASFISCAIS.SERIE,NOTAENTRADA.SERIE, notadevolucao.SERIENF) AS SERIE,  
COALESCE(NOTASFISCAIS.NRONOTA,NOTAENTRADA.NRONOTA, notadevolucao.NRONOTADEV) AS NRONOTA, 
CASE NFERETORNO.FLTIPONOTA
   WHEN 1 THEN 'NFS-e'
   WHEN 0 THEN CASE NFERETORNO.FLTIPOOPERACAO
     WHEN 16 THEN 'MD-e'
     WHEN 0 THEN CASE CADMODELOSFISCAIS.CODFISCAL
       WHEN '55' THEN 'NF-e'
       WHEN '65' THEN 'NFC-e'
       WHEN '59' THEN 'CF-e-SAT'
       WHEN '67' THEN 'CT-e'
   ELSE 'NF' END ELSE 'NF' END ELSE 'NF'
END AS TIPO_NOTA,
NFERETORNO.IDNOTA AS NFE_SERVICOS,
COALESCE(NOTASFISCAIS.DATAEMISSAO,NOTAENTRADA.DATAEMISSAO, notadevolucao.dataemissaodev) AS DATAEMISSAO,
CASE NFERETORNO.FLTIPONOTA
  WHEN 0 THEN 'PRODUTOS'
  WHEN 1 THEN 'SERVICOS'
END AS TIPONOTA,
NFERETORNO.FLSTATUS AS STATUS,
CASE NFERETORNO.FLSTATUS
  WHEN 0 THEN 'GERADA*'
  WHEN 1 THEN 'ENVIADA SEM CONFIRMAÇÃO*'
  WHEN 2 THEN CASE WHEN NOTASFISCAIS.SITUACAO='C'  OR LENGTH(RAZOES.MOTCANC) > 10 THEN 'CANCELADA* NO SISTEMA' WHEN NFERETORNO.FLTIPONOTA = 1 AND COALESCE(NFERETORNO.IDNOTA,'')='' THEN 'ENVIADA *' ELSE 'ENVIADA' END
  WHEN 3 THEN CASE WHEN NFERETORNO.DSMENSAGEM LIKE '% (12029) %' THEN 'PREFEITURA * FORA OU SEM CONEXÃO' ELSE 'ENVIADA COM ERRO*' END
  WHEN 4 THEN 'REJEITADA*'
  WHEN 5 THEN CASE WHEN NOTASFISCAIS.SITUACAO='C'  OR LENGTH(RAZOES.MOTCANC) > 10 THEN 'CANCELADA' ELSE CASE NFERETORNO.FLTIPONOTA WHEN 0 THEN 'CANCELADA* SOMENTE NO SEFAZ' WHEN 1 THEN 'CANCELADA* SOMENTE NA PREFEITURA' END END
  WHEN 6 THEN 'CANCELADA COM ERRO*'
  WHEN 7 THEN CASE NFERETORNO.FLTIPONOTA WHEN 0 THEN 'CONTINGeNCIA*' WHEN 1 THEN 'PREFEITURA FORA*' END
  WHEN 8 THEN 'NF MANUAL'
  WHEN 9 THEN CASE WHEN (NOTASFISCAIS.SITUACAO<>'C'  OR LENGTH(RAZOES.MOTCANC) > 10) AND NFERETORNO.FLTIPONOTA=0 THEN 'NF INUTILIZADA* SOMENTE NO SEFAZ' ELSE 'NF INUTILIZADA' END
  WHEN 10 THEN 'NF DENEGADA'
END AS STATUSNF,
NOTASFISCAIS.NOME, 
NOTASFISCAIS.EMAIL,
NOTASFISCAIS.CGCCPF,
NOTASFISCAIS.HOSPEDE1,
NOTASFISCAIS.HOSPEDE2,
NFERETORNO.IDERRO, 
NFERETORNO.DSMENSAGEM,
NFERETORNO.DSCORRECAO, 
NOTASFISCAIS.DATAHORASAIDA, 
NOTASFISCAIS.CODFISCAL, 
NOTASFISCAIS.ENDERECO, 
NOTASFISCAIS.NROENDERECO, 
NOTASFISCAIS.COMPLEMENTO, 
NOTASFISCAIS.BAIRRO,
NOTASFISCAIS.CEP, 
NOTASFISCAIS.CIDADE, 
NOTASFISCAIS.CODMUNICIPIO, 
NOTASFISCAIS.CODMUNICIPIOSIAF, 
NOTASFISCAIS.FONEFAX, 
NOTASFISCAIS.ESTADO, 
NOTASFISCAIS.CODESTADO, 
NOTASFISCAIS.PAIS, 
NOTASFISCAIS.CODPAIS,
NOTASFISCAIS.INSCEST, 
NOTASFISCAIS.INSCMUNICIPAL, 
NOTASFISCAIS.TOTALNOTA, 
NOTASFISCAIS.TOTALPROD, 
NOTASFISCAIS.TOTALSERV,
NOTASFISCAIS.VALBASEISS,
NOTASFISCAIS.VALISS,
NOTASFISCAIS.VALISSRET,
NOTASFISCAIS.VALPISRET,
NOTASFISCAIS.VALIRRET,
NOTASFISCAIS.VALCOFINSRET,
NOTASFISCAIS.VALCSLLRET,      
COALESCE(NOTASFISCAIS.SITUACAO,NOTAENTRADA.SITUACAO, notadevolucao.STATUS) AS SITUACAO,
CASE WHEN NFERETORNO.FLTIPONOTA = 1 THEN COALESCE(NULLIF(RAZOES.MOTCANC,''),NULLIF(NOTASFISCAIS.DESCMOTIVOCANCEL,''),CASE WHEN NOTASFISCAIS.SITUACAO = 'C' THEN 'CANCELAMENTO DE NOTA DE SERVIÇOS PELO ENFE MANUTENÇÃO' END)
  WHEN NOTASFISCAIS.SITUACAO = 'C' THEN COALESCE(NULLIF(RAZOES.MOTCANC,''),NULLIF(NOTASFISCAIS.DESCMOTIVOCANCEL,''))
  WHEN NOTAENTRADA.SITUACAO = 'C' THEN 'nota de entrada cancelada'
  WHEN notadevolucao.STATUS = 'C' THEN NULLIF(notadevolucao.MOTIVOCANCELAMENTO,'') 
END AS MOTIVO_CANCELAMENTO, 
NFERETORNO.CDEMPRESA,
NFERETORNO.FLTIPONOTA, 
CASE 
     WHEN NOTASFISCAIS.CODNOTA IS NOT NULL THEN 0 
     WHEN NFERETORNO.FLMODOEMISSAO = 16   THEN 0 
     WHEN NOTADEVOLUCAO.CHAVE  IS NOT NULL THEN 2 
     WHEN NOTAENTRADA.CODNOTA IS NOT NULL THEN 1 
     ELSE NFERETORNO.FLTIPONOTAES 
END AS FLTIPONOTAES,
NFERETORNO.FLTIPOOPERACAO,
NFERETORNO.FLMODOEMISSAO,
NFERETORNO.IDNOTA, 
NFERETORNO.IDCHAVE, 
NFERETORNO.IDRECIBO, 
NFERETORNO.IDPROTOCOLO, 
NFERETORNO.IDPROTOCOLOCANC, 
NFERETORNO.IDLOTE, 
NFERETORNO.IDCODVERIFICACAO, 
NFERETORNO.DHRECEBIMENTO, 
NFERETORNO.HRECEBIMENTO, 
NFERETORNO.CDNOTA, 
IMPRESSAO.DSHTMLRPS,
NOTASFISCAIS.CODEMPRESA,
CASE WHEN CADMODELOSFISCAIS.CODFISCAL='65' THEN 1 ELSE 0 END AS TIPONFENFCE
FROM NOTASFISCAIS
RIGHT JOIN NFERETORNO ON NOTASFISCAIS.CODNOTA = NFERETORNO.CDNOTA AND NOTASFISCAIS.CODHOTEL = NFERETORNO.CDEMPRESA
LEFT JOIN NOTAENTRADA ON  NOTAENTRADA.CODNOTA = NFERETORNO.CDNOTA AND  NOTAENTRADA.CODHOTEL = NFERETORNO.CDEMPRESA
LEFT JOIN notadevolucao ON  notadevolucao.chave = NFERETORNO.CDNOTA AND  notadevolucao.CODHOTEL = NFERETORNO.CDEMPRESA
LEFT JOIN NOTAENTRADA AS devent ON  notadevolucao.codnotaent = devent.CODNOTA AND  devent.CODHOTEL = NFERETORNO.CDEMPRESA
LEFT JOIN CADFORNEC ON CADFORNEC.CODFORNEC IN (NOTAENTRADA.CODFORNECEDOR,DEVENT.CODFORNECEDOR) AND CADFORNEC.CODHOTEL = NFERETORNO.CDEMPRESA
JOIN CONFIGURA ON CONFIGURA.CODHOTEL = NFERETORNO.CDEMPRESA
JOIN CONFIGURA3 ON CONFIGURA3.CODHOTEL = NFERETORNO.CDEMPRESA
LEFT JOIN RAZOES ON NOTASFISCAIS.CODRAZAO = RAZOES.CODRAZAO AND NOTASFISCAIS.CODHOTEL = RAZOES.CODHOTEL
LEFT JOIN CADMODELOSFISCAIS ON CADMODELOSFISCAIS.CODMODELO = NOTASFISCAIS.MODELOFISCAL
-- LEFT JOIN nfeconfig on NFECONFIG.FLTIPONOTAES = 0 AND nfeconfig.CDEMPRESA = NFERETORNO.CDEMPRESA
CROSS JOIN LATERAL (SELECT 
CAST(CASE 
WHEN nferetorno.fltiponota = 1
      and nferetorno.flstatus in (2,5,3,6)
      and nferetorno.idcodverificacao IS NULL
      and LENGTH(nferetorno.idchave) = 50
THEN ''
         ||lower('<html lang="pt-')||UPPER('BR">')
         ||lower('<head><meta charset="utf-8"><script type="text/javascript">')
         ||lower('var url = "')||lower('https://www.nfse.gov.br/consulta')||'P'||lower('ublica/?tpc=1&chave=')||nferetorno.idchave||'";'
         ||lower('var urllogado = "')||lower('https://www.nfse.gov.br/')||INITCAP('Emissor')||INITCAP('Nacional/')||INITCAP('Notas/')||INITCAP('Visualizar/')||INITCAP('Index/')||nferetorno.idchave||'";'
         ||lower('var idchave = "')||nferetorno.idchave||'";'
         ||lower('var isie = window.navigator.app')||INITCAP('Name === "')||INITCAP('Microsoft Internet Explorer";')
         ||lower('var fso = new ')||INITCAP('Active')||upper('X')||INITCAP('Object( "')||INITCAP('Scripting.')||INITCAP('File')||INITCAP('System')||INITCAP('Object");')
         ||lower('var shell = new ')||upper('A')||lower('ctive')||upper('XO')||lower('bject( "')||upper('WS')||lower('cript.')||upper('S')||lower('hell");')
         ||lower('var caminhoEdge = "C:\\\\Program Files (x86)\\\\Microsoft\\\\Edge\\\\Application\\\\msedge.exe";')
         ||lower('var caminhoChrome = "C:\\\\Program Files\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe";')
         ||lower('function inicio() {')
         ||lower('if (isIE) {')
         ||lower('document.get')||INITCAP('Element')||INITCAP('By')||INITCAP('Id')||lower('("txtChaveIdentificacao").inner')||upper('HTML')||lower('=idchave;')
         ||lower('}')
         ||lower('}')
         ||lower('function Executar_Edge() {')
          ||lower('if (fso.')||INITCAP('File')||INITCAP('Exists')||lower('(caminhoEdge)) {')
           ||lower('shell.run(''"'' + caminhoEdge + ''" --app='' + url);')
           ||lower('} else {')
           ||lower('shell.run(''"'' + caminhoChrome + ''" --app='' + url);')
          ||lower('}')
         ||lower('}')
         ||lower('function Executar_Edge_logado() {')
          ||lower('if (fso.')||INITCAP('File')||INITCAP('Exists')||lower('(caminhoEdge)) {')
           ||lower('shell.run(''"'' + caminhoEdge + ''" --app='' + urllogado);')
           ||lower('} else {')
           ||lower('shell.run(''"'' + caminhoChrome + ''" --app='' + urllogado);')
          ||lower('}')
         ||lower('}')
        --  ||lower('function Teste_IE() {')
        --    ||lower('shell.run(''"'' + caminhoChrome + ''" --app='' + window.location.href);')
        --  ||lower('}')
         ||lower('</script>')
         ||Lower('</head>')
         ||lower('<body onload="inicio()">')
         ||lower('<div id="iexplorer">')
          ||lower('<h1>')||INITCAP('Autenticação de notas')||lower('</h1>')
          ||Lower('<button onclick="Executar_Edge()" style="width:200px">')||INITCAP('Consulta Pública')||lower('</button>')
          ||Lower('<button onclick="Executar_Edge_logado()" style="width:200px">')||INITCAP('Consulta Logado')||lower('</button>')
          -- ||Lower('<button onclick="Teste_IE()" style="width:120px">')||INITCAP('Teste IE')||lower('</button>')
          ||Lower('<br/>')
          ||Lower('<div><label>')||lower('https://www.nfse.gov.br/consultaPublica/')||lower('</label>')||lower('</div>')
          ||Lower('<div><label>')||INITCAP('Chave ')||lower('da ')||upper('NFS')||lower('-e:')||lower('</label><label id="txtChaveIdentificacao" style="color:RoyalBlue"></label></div>')
         ||lower('</div>')
         ||Lower('</body>')
         ||Lower('</html>')
WHEN nferetorno.fltiponota = 1 
      and nferetorno.flstatus in (2,5,3,6) 
      and coalesce(nferetorno.idcodverificacao, '') <> '' 
      and coalesce(nferetorno.idnota, '') <> '' 
THEN 
CASE CONFIGURA3.CODIBGEHOTEL 
 WHEN '3550308' THEN ''
          ||lower('<script>window.location = "' 
          ||'https://nfe.prefeitura.sp.gov.br/contribuinte/notaprintimg.aspx?ccm='
          ||regexp_replace(configura.inscmunicip, '[^0-9]', '', lower('gi'))
          ||'&nf='||NFERetorno.IDNota
          ||'&cod=')||REPLACE(NFERetorno.IDCodVerificacao,'-','')
          ||lower('&imprimir=1'
          || '";</script>')
ELSE 
   CASE  WHEN COALESCE(DSHTMLRPS,'') ILIKE 'HTTP%' THEN ''
          ||lower('<script>window.location = "')
          ||NFERETORNO.DSHTMLRPS
          ||lower('";</script>')
        ELSE ''
||REPLACE(REPLACE(REPLACE(REPLACE(
NFERETORNO.DSHTMLRPS
,'#IDCODVERIFICACAO#',nferetorno.idcodverificacao)
,'#IDNOTA#',nferetorno.idnota)
,'#INSCMUNICIP#',configura.inscmunicip)
,'#CGC#',configura.cgc)
   END
END 
END 
as bytea)  
as DSHTMLRPS
) AS IMPRESSAO
WHERE
      NOTASFISCAIS.DATAEMISSAO BETWEEN :DATAINI AND :DATAFIM AND NOTASFISCAIS.CODHOTEL = :CDEMPRESA 
OR NOTAENTRADA.DATAEMISSAO BETWEEN :DATAINI AND :DATAFIM AND NOTAENTRADA.CODHOTEL = :CDEMPRESA 
OR notadevolucao.dataemissaodev BETWEEN :DATAINI AND :DATAFIM AND notadevolucao.CODHOTEL = :CDEMPRESA 
ORDER BY COALESCE(NOTASFISCAIS.DATAEMISSAO,NOTAENTRADA.DATAEMISSAO, notadevolucao.dataemissaodev) DESC ,NFERETORNO.CDNOTA DESC