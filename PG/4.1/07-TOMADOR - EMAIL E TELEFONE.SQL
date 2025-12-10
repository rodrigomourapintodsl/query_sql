SELECT EMAIL,EMAIL_DESTINATARIO,TELEFONE FROM (
SELECT ROW_NUMBER() OVER(ORDER BY ID) AS IDEMAIL,
    EMAIL,
    EMAIL_DESTINATARIO
FROM (
--remover caracteres especiais
SELECT EMAILS AS EMAILS 
    ,TRIM(
        REGEXP_REPLACE(
            SPLIT_PART(EMAIL, ';', 1),
            '[^abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\@\.\;\_\-]',
            '',
            'g'
        )
    ) AS EMAIL,STRING_AGG(EMAIL,';') OVER() AS EMAIL_DESTINATARIO,
    ROW_NUMBER() OVER(
        ORDER BY MIN(ID)
    ) AS ID
FROM (
--split nome definido <>
        SELECT ID
            ,COALESCE(
                (regexp_match(EMAIL, '<(.*)>'))[1],
                EMAIL
            ) AS EMAIL,
            EMAILS
        FROM (
--adicionar ordem
                SELECT ROW_NUMBER() OVER() AS ID 
                    ,*
                FROM (
--split multiplos emails ;
                        SELECT 
                            EMAIL AS EMAILS,
                            regexp_split_to_table(EMAIL, ';') AS EMAIL
                        FROM (
-- unindo registros
                                SELECT string_agg(EMAIL, ';') AS EMAIL 
                                FROM (
--query normal da tabela de emails
SELECT notasfiscais.EMAIL
FROM notasfiscais
WHERE notasfiscais.codhotel = :CDEMPRESA
AND notasfiscais.codnota = :CDNOTA
                                    ) AS NOTASFISCAIS
                            ) AS CONTATO_EMAIL_UNINDO
                    ) AS CONTATO_EMAIL_MULTIPLOS
            ) AS CONTATO_EMAIL_ORDEM
    ) AS CONTATO_EMAIL_NOME_DEFINIDO
WHERE CHAR_LENGTH(EMAIL) >= 10
    AND EMAIL LIKE '%@%.%'
    AND TRIM(SPLIT_PART(EMAIL, ';', 1)) NOT LIKE '% %'
    AND EMAIL NOT LIKE '%<%'
    AND EMAIL NOT LIKE '%>%'
    AND EMAIL NOT LIKE '%,%'
    AND EMAIL NOT LIKE '%"%'
    AND EMAIL NOT LIKE '%''%'
    AND EMAIL NOT LIKE '%@%@%'
    AND EMAIL NOT LIKE '%@.%'
    AND EMAIL NOT LIKE '%@.%'
    AND EMAIL NOT LIKE '%@'
    AND EMAIL NOT LIKE '@%'
    AND EMAIL NOT LIKE '%..%'
    AND EMAIL NOT LIKE '%.'
    AND EMAIL NOT LIKE '.%'
    AND EMAIL NOT LIKE 'naotem@%'
    AND EMAIL NOT LIKE 'sememail@%'
    AND EMAIL NOT LIKE 'sem@%'
    AND EMAIL NOT LIKE 'naoinfo@%'
    AND EMAIL NOT LIKE 'naoinformado@%'
    AND EMAIL NOT LIKE 'naoinformou@%'
    AND EMAIL NOT LIKE 'nao@%'
    AND LEFT(TRIM(EMAIL),-1) NOT LIKE '%;%'
    AND EMAIL NOT SIMILAR TO '%[ŠŽšžŸÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïðñòóôõöùúûüýÿ]%'
GROUP BY EMAIL,
    EMAILS
) AS T
ORDER BY ID
) AS E
FULL OUTER JOIN (
SELECT ROW_NUMBER() OVER() AS IDFONE,
   CASE WHEN notasfiscais.fonefax LIKE '+55%' 
       THEN REGEXP_REPLACE(RIGHT(notasfiscais.fonefax,-3),'[^0-9]','','g')
       ELSE  regexp_replace(notasfiscais.fonefax, '[^0-9]', '', 'g')
   END  AS telefone
FROM notasfiscais
WHERE notasfiscais.codhotel = :CDEMPRESA
AND notasfiscais.codnota = :CDNOTA
  AND (LENGTH(notasfiscais.fonefax) BETWEEN 8 AND 14 
    OR LENGTH(notasfiscais.fonefax) BETWEEN 8 AND 20 AND notasfiscais.fonefax LIKE '+%'
    )
) AS F ON IDFONE=IDEMAIL
WHERE IDFONE IS NOT NULL OR IDEMAIL IS NOT NULL 
ORDER BY IDEMAIL