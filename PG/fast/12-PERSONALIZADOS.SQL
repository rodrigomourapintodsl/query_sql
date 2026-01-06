SELECT 
    DOCFISCAL.CDDOCFISCAL AS nDFSe,
    CASE
        WHEN CIDADE.idibge IN ('3530607')
        THEN 'SilTecnologia_v1.00'
        WHEN CIDADE.idibge ('3518701','3518800','3548500','3143906','2704302','3549805','4128104','3548708','3523909')
       THEN '2.04' -- Gingfes Abrasf 2.04
    END AS verAplic,
    'NFS'
    ||(SELECT ID ||
    CAST(  (SELECT mod(11-MOD(SUM(NFSE_MULT),11),10) AS NFSE_digito FROM (
        SELECT CAST(NFSE as INT) * lINHA as NFSE_MULT FROM (
            select ((ROW_NUMBER() OVER()-1) %8)+2 AS lINHA,NFSE FROM regexp_split_to_table(replace((left(
                    ID
                ,-1)),'-',''), '[&&]*') AS NFSE
            ) as NFSE_DESC
        ) as A) AS CHAR(1)) ---NFSE_digito_esperado -- Calculo DV
    FROM (SELECT ''
    || TRIM(TO_CHAR(CAST( CIDADE.idibge AS INTEGER),'0000000')) --IBGE
    || '1' -- 1==Ambiente Produção
    || '2' -- 2==CNPJ_EMITENTE
    || REGEXP_REPLACE(EMITENTE.iddocident,'[^0-9]','','g')
    || TRIM(TO_CHAR(DOCFISCAL.NRDOCFISCAL,'0000000000000'))
    || TRIM(TO_CHAR(DOCFISCAL.DTENTRADASAIDA,'YYDD'))
    || TRIM(TO_CHAR(DOCFISCAL.CDDOCFISCAL,'000000000'))
    AS ID ) AS NFS
    )
    AS ID_NFS,
    'DPS' 
    || TRIM(TO_CHAR(CAST( CIDADE.idibge AS INTEGER),'0000000')) --IBGE
    || '2' -- 2==CNPJ_EMITENTE
    || REGEXP_REPLACE(EMITENTE.iddocident,'[^0-9]','','g')
    || TRIM(TO_CHAR(CAST( COALESCE(NULLIF(NULLIF(CAST(regexp_replace(DOCFISCAL.IDSERIE, '[^0-9]', '', 'g') AS VARCHAR(5)),'0'),''),'1') AS INTEGER),'00000'))
    || TRIM(TO_CHAR(DOCFISCAL.NRDOCFISCAL,'000000000000000'))
    AS ID_DPS,
    Current_timestamp as dhProc,
    0 AS nNFSe,
    1 as tpEmis, --1==Sistema Próprio da Prefeitura;2==Sefin Webservice Nacional
    '100' as cStat,
    PAISBACEN.CODM49,
    PAISBACEN.CODM49
FROM DOCFISCAL 
  JOIN EMPRESA ON EMPRESA.CDEMPRESA = DOCFISCAL.CDEMPRESA
  JOIN PESSOA EMITENTE ON EMITENTE.CDPESSOA = EMPRESA.CDESTABELECIMENTO
  JOIN PESSOAENDERECO ON PESSOAENDERECO.CDPESSOA = EMITENTE.CDPESSOA AND PESSOAENDERECO.NRTIPOENDERECO = 0
  JOIN CIDADE ON CIDADE.CDCIDADE = PESSOAENDERECO.CDCIDADE
  JOIN ESTADO ESTADO ON ESTADO.CDESTADO = CIDADE.CDESTADO
  JOIN PAIS ON PAIS.CDPAIS = ESTADO.CDPAIS
  LEFT JOIN PESSOACONTATO ON PESSOAENDERECO.CDPESSOAENDERECO = PESSOACONTATO.CDPESSOAENDERECO AND PESSOACONTATO.FLENDERECO = 1
  LEFT JOIN (VALUES
  (  4, 132,'Afeganistão') --
, (710,7560,'África do Sul') --
, (  8, 175,'Albânia') --
, (276, 230,'Alemanha') --
, ( 20, 370,'Andorra') --
, ( 24, 400,'Angola') --
, (660, 418,'Anguilla') --
, ( 10, 420,'Antártida') --
, ( 28, 434,'Antígua e Barbuda') --
, (682, 531,'Arábia Saudita') --
, ( 12, 590,'Argélia') --
, ( 32, 639,'Argentina') --
, ( 51, 647,'Armênia') --
, (533, 655,'Aruba') --
, ( 36, 698,'Austrália') --
, ( 40, 728,'Áustria') --
, ( 31, 736,'Azerbaijão') --
, ( 44, 779,'Bahamas') --
, ( 50, 817,'Bangladesh') --
, ( 52, 833,'Barbados') --
, ( 48, 809,'Barein') --
, ( 56, 876,'Bélgica') --
, ( 84, 884,'Belize') --
, (204,2291,'Benin') --
, ( 60, 906,'Bermuda') --
, (112, 850,'Bielorússia') --
, ( 68, 973,'Bolívia') --
, (535, 990,'Bonaire, Santo Eustáquio e Saba') --
, ( 70, 981,'Bósnia-Herzegovina') --
, ( 72,1015,'Botsuana') --
, ( 76,1058,'Brasil') --
, ( 96,1082,'Brunei') --
, (100,1112,'Bulgária') --
, (854, 310,'Burkina Faso') --
, (108,1155,'Burundi') --
, ( 64,1198,'Butão') --
, (132,1279,'Cabo Verde') --
, (120,1457,'Camarões') --
, (116,1414,'Camboja') --
, (124,1490,'Canadá') --
, (398,1538,'Casaquistão') --
, (634,1546,'Catar') --
, (148,7889,'Chade') --
, (152,1589,'Chile') --
, (156,1600,'China') --
, (344,3514,'China, Hong Kong') --
, (446,4472,'China, Macao') --
, (196,1635,'Chipre') --
, (702,7412,'Cingapura') --
, (170,1694,'Colômbia') --
, (174,1732,'Comores') --
, (178,1775,'Congo') --
, (408,1872,'Coréia do Norte') --
, (410,1902,'Coréia do Sul') --
, (384,1937,'Costa do Marfim') --
, (188,1961,'Costa Rica') --
, (191,1953,'Croácia') --
, (192,1996,'Cuba') --
, (531, 200,'Curaçao') --
, (208,2321,'Dinamarca') --
, (262,7838,'Djibouti') --
, (212,2356,'Dominica') --
, (818,2402,'Egito') --
, (222,6874,'El Salvador') --
, (784,2445,'Emirados Árabes Unidos') --
, (218,2399,'Equador') --
, (232,2437,'Eritréia') --
, (703,2470,'Eslováquia') --
, (705,2461,'Eslovênia') --
, (724,2453,'Espanha') --
, (840,2496,'Estados Unidos da América') --
, (233,2518,'Estônia') --
, (744,7552,'Esvalbarda e Jan Mayen') --
, (231,2534,'Etiópia') --
, (242,8702,'Fiji') --
, (608,2674,'Filipinas') --
, (246,2712,'Finlândia') --
, (250,2755,'França') --
, (266,2810,'Gabão') --
, (270,2852,'Gâmbia') --
, (288,2895,'Gana') --
, (268,2917,'Geórgia') --
, (292,2933,'Gibraltar') --
, (308,2976,'Granada') --
, (300,3018,'Grécia') --
, (304,3050,'Groenlândia') --
, (316,3131,'Guam') --
, (320,3174,'Guatemala') --
, (831,3212,'Guernsey') --
, (328,3379,'Guiana') --
, (254,3255,'Guiana Francesa') --
, (324,3298,'Guiné') --
, (226,3310,'Guiné Equatorial') --
, (624,3344,'Guiné-Bissau') --
, (332,3417,'Haiti') --
, (528,5738,'Holanda') --
, (340,3450,'Honduras') --
, (348,3557,'Hungria') --
, (887,3573,'Iêmen') --
, ( 74,1023,'Ilha Bouvet') --
, (162,5118,'Ilha Christmas') --
, (833,3595,'Ilha de Man') --
, (312,3093,'Ilha Guadalupe') --
, (334,3433,'Ilha Heard e Ilhas McDonald') --
, (574,5355,'Ilha Norfolk') --
, (638,6602,'Ilha Reunião') --
, (248, 153,'Ilhas Alanda') --
, (136,1376,'Ilhas Cayman') --
, (166,1651,'Ilhas Cocos') --
, (184,1830,'Ilhas Cook') --
, (234,2593,'Ilhas Faeroe') --
, (238,2550,'Ilhas Falkland') --
, (239,2925,'Ilhas Geórgia do Sul e Sandwich do Sul') --
, (580,4723,'Ilhas Marianas do norte') --
, (584,4766,'Ilhas Marshall') --
, (581,5665,'Ilhas Menores Distantes dos Estados Unidos') --
, ( 90,6777,'Ilhas Salomão') --
, (796,8230,'Ilhas Turcas e Caicos') --
, (850,8664,'Ilhas Virgens') --
, ( 92,8630,'Ilhas Virgens Britânicas') --
, (876,8753,'Ilhas Wallis e Futuna') --
, (356,3611,'Índia') --
, (360,3654,'Indonésia') --
, (364,3727,'Irã') --
, (368,3697,'Iraque') --
, (372,3751,'Irlanda') --
, (352,3794,'Islândia') --
, (376,3832,'Israel') --
, (380,3867,'Itália') --
, (388,3913,'Jamaica') --
, (392,3999,'Japão') --
, (832,3930,'Jersey') --
, (400,4030,'Jordânia') --
, (296,4111,'Kiribati') --
, (414,1988,'Kuwait') --
, (418,4200,'Laos') --
, (426,4260,'Lesoto') --
, (428,4278,'Letônia') --
, (422,4316,'Líbano') --
, (430,4340,'Libéria') --
, (434,4383,'Líbia') --
, (438,4405,'Liechtenstein') --
, (440,4421,'Lituânia') --
, (442,4456,'Luxemburgo') --
, (807,4499,'Macedônia do norte / Jugoslávi')--
, (450,4502,'Madagáscar') --
, (458,4553,'Malásia') --
, (454,4588,'Malauí') --
, (462,4618,'Maldivas') --
, (466,4642,'Mali') --
, (470,4677,'Malta') --
, (504,4740,'Marrocos') --
, (474,4774,'Martinica') --
, (480,4855,'Maurício') --
, (478,4880,'Mauritânia') --
, (175,4898,'Mayotte') --
, (484,4936,'México') --
, (104, 930,'Mianma') --
, (583,4995,'Micronésia') --
, (508,5053,'Moçambique') --
, (498,4944,'Moldávia') --
, (492,4952,'Mônaco') --
, (496,4979,'Mongólia') --
, (499,4985,'Montenegro') --
, (500,5010,'Montserrat') --
, (516,5070,'Namíbia') --
, (520,5088,'Nauru') --
, (524,5177,'Nepal') --
, (558,5215,'Nicarágua') --
, (562,5258,'Níger') --
, (566,5282,'Nigéria') --
, (570,5312,'Niue') --
, (578,5380,'Noruega') --
, (540,5428,'Nova Caledônia') --
, (554,5487,'Nova Zelândia') --
, (512,5568,'Omã') --
, (585,5754,'Palau') --
, (275,5780,'Palestina') --
, (591,5800,'Panamá') --
, (598,5452,'Papua Nova Guiné') --
, (586,5762,'Paquistão') --
, (600,5860,'Paraguai') --
, (604,5894,'Peru') --
, (612,5932,'Pitcairn') --
, (258,5991,'Polinésia Francesa') --
, (616,6033,'Polônia') --
, (630,6114,'Porto Rico') --
, (620,6076,'Portugal') --
, (404,6238,'Quênia') --
, (417,6254,'Quirguistão') --
, (826,6289,'Reino Unido') --
, (140,6408,'República Centro Africana') --
, (180,8885,'República Democrática do Congo') --
, (214,6475,'República Dominicana') --
, (203,7919,'República Tcheca') --
, (642,6700,'Romênia') --
, (646,6750,'Ruanda') --
, (643,6769,'Rússia (Federação Russa)') --
, (732,6858,'Saara Ocidental') --
, (882,6904,'Samoa') --
, ( 16,6912,'Samoa Americana') --
, (674,6971,'San Marino') --
, (654,7102,'Santa Helena') --
, (662,7153,'Santa Lúcia') --
, (652,6939,'São Bartolomeu') --
, (659,6955,'São Cristóvão e Nevis') --
, (534,6998,'São Martinho (Países Baixos - holandesa)') --
, (663,6980,'São Martinho, parte francesa') --
, (666,7005,'São Pedro e Miquelão') --
, (678,7200,'São Tome e Príncipe') --
, (670,7056,'São Vicente e Granadinas') --
, (690,7315,'Seichelles') --
, (686,7285,'Senegal') --
, (694,7358,'Serra Leoa') --
, (688,7370,'Sérvia') --
, (760,7447,'Síria') --
, (706,7480,'Somália') --
, (144,7501,'Sri Lanka') --
, (748,7544,'Essuatini / Suazilândia') --
, (729,7595,'Sudão') --
, (728,7600,'Sudão do Sul') --
, (752,7641,'Suécia') --
, (756,7676,'Suíça') --
, (740,7706,'Suriname') --
, (762,7722,'Tadjiquistão') --
, (764,7765,'Tailândia') --
, (834,7803,'Tanzânia') --
, (260,7811,'Terras Austrais e Antárticas Francesas') --
, ( 86,7820,'Território Britânico do Oceano Índico') --
, (626,7951,'Timor Leste') --
, (768,8001,'Togo') --
, (772,8052,'Tokelau') --
, (776,8109,'Tonga') --
, (780,8150,'Trinidad e Tobago') --
, (788,8206,'Tunísia') --
, (795,8249,'Turcomenistão') --
, (792,8273,'Turquia') --
, (798,8281,'Tuvalu') --
, (804,8311,'Ucrânia') --
, (800,8338,'Uganda') --
, (858,8451,'Uruguai') --
, (860,8478,'Uzbequistão') --
, (548,5517,'Vanuatu') --
, (336,8486,'Vaticano') --
, (862,8508,'Venezuela') --
, (704,8583,'Vietnã') --
, (894,8907,'Zâmbia') --
, (716,6653,'Zimbábue') --
, (158,1619,'REP. FORMOSA / Taiwan') --
,(NULL, 477,'ANTILHAS HOLANDESAS') -- (Inativo)
,(NULL,1511,'ILHAS CANARIAS') -- (Inativo)
,(NULL,3964,'ILHAS JOHNSTON') -- (Inativo)
,(NULL,4235,'ILHAS LEBUAN') -- (Inativo)
,(NULL,4525,'ILHA DA MADEIRA') -- (Inativo)
,(NULL,4901,'ILHAS MIDWAY') -- (Inativo)
,(NULL,8737,'Ilha Atol Wake') -- (Inativo)
, (831,1504,'GUERNSEY, ILHA DO CANAL (INCLUI ALDERNEY E SARK)') -- Alterado CDPAISBACEN == 3212
, (832,1508,'JERSEY, ILHA DO CANAL') -- Alterado CDPAISBACEN == 3930
, (531,2003,'CURACAO') -- Alterado CDPAISBACEN == 0200
, (535,3599,'BONAIRE') -- Alterado CDPAISBACEN == 0990
, (175,4885,'MAYOTTE (ILHAS FRANCESAS)') -- Alterado CDPAISBACEN == 4898
) AS PAISBACEN(CODM49,CDPAISBACEN,DSPAIS) 
ON DOCFISCAL.idibgepais = TRIM(TO_CHAR(PAISBACEN.CDPAISBACEN, '0000'))
WHERE DOCFISCAL.CDEMPRESA = :CDEMPRESA
  AND DOCFISCAL.CDDOCFISCAL = :CDNOTA
  --AND CONFIGURA3.CODIBGEHOTEL IN ('3530607')SELECT 
