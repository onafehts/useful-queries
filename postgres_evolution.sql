-- QUERY 1: 
-- Essa query busca todas as mensagens do grupo especificado e dentro do prazo especificado em horas. As mensagens são retornadas como um grande texto
SELECT string_agg(
  sub.nome || ' - ' || sub.mensagem || ' - ' || sub.data_formatada::TEXT, E'\n'
) AS conversa_formatada
FROM (
  SELECT 
    m."key"->>'remoteJid' AS grupo,
    SPLIT_PART(m."key"->>'participant', '@', 1) AS whatsapp,
    m."pushName" AS nome,
    m."message"->>'conversation' AS mensagem,
    TO_CHAR(TO_TIMESTAMP(m."messageTimestamp"), 'YYYY-MM-DD HH24:MI:SS') AS data_formatada
  
  FROM "Message" m 
  WHERE m."messageType" = 'conversation'
        AND m."key"->>'remoteJid' = '{{ $('Config').item.json.Grupo }}' -- O node 'Config' precisa ter um campo Grupo com o ID do grupo. 
        AND m."messageTimestamp" > {{$now.minus($json.Horas, 'hours').toSeconds()}} -- O node 'Config' precisa ter um campo 'Horas' com a quantidade de horas do intervalo
  ORDER BY m."messageTimestamp" ASC
) sub




-- QUERY 2: 
-- Essa query traz uma lista com os 5 números que mais contribuíram no grupo dentro do período especificado na 'Configuração'
SELECT 
  string_agg(
    COALESCE(sub.nome,'sem nome') || ' - ' || sub.total::TEXT || ' mensagens' || ' - (+' || whatsapp || ')',
    E'\n'
  ) AS ranking
FROM (
      SELECT 
        m."key"->>'remoteJid' AS grupo,
        SPLIT_PART(m."key"->>'participant', '@', 1) AS whatsapp,
        MAX(CASE WHEN m."pushName" IS NOT NULL AND m."pushName" <> '' THEN m."pushName" ELSE NULL END) AS nome,
        COUNT(*) AS total
      FROM "Message" m 
      WHERE m."messageType" = 'conversation'
        AND m."key"->>'remoteJid' = '{{ $('Config').item.json.Grupo }}' -- O node 'Config' precisa ter um campo Grupo com o ID do grupo. 
        AND m."messageTimestamp" > {{$now.minus( $('Config').item.json.Horas, 'hours').toSeconds()}} -- O node 'Config' precisa ter um campo 'Horas' com a quantidade de horas do intervalo
      GROUP BY grupo, whatsapp
      ORDER BY total DESC 
      LIMIT 5
) sub;
