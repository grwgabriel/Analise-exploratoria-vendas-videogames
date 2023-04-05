-- Databricks notebook source
-- MAGIC %md
-- MAGIC #Introdução
-- MAGIC 
-- MAGIC A análise abaixo foi feita em SQL utilizando dados do dataset "Video Games Sales" que foram disponibilizados no site www.kaggle.com
-- MAGIC 
-- MAGIC O objetivo principal dessa análise é entender como os jogos estão performando em diferentes mercados e regiões e quais são as tendências que estão emergindo. 
-- MAGIC A partir dessas informações, é possível tomar decisões importantes, como quais plataformas ou regiões devem receber mais investimentos ou quais gêneros de jogos devem ser priorizados no desenvolvimento.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #Entendendo o dataset
-- MAGIC <br>
-- MAGIC Nossa base de dados possui informação até o ano de 2020.<br>
-- MAGIC Abaixo temos o que cada coluna do nosso dataset significa.<br>
-- MAGIC <br>
-- MAGIC 
-- MAGIC * **Rank:** Posição no ranking de vendas;
-- MAGIC * **Nome:** Nome do jogo;
-- MAGIC * **Plataforma:** Plataforma em que o jogo foi liberado (PC, PS4, Xbox, etc.);
-- MAGIC * **Ano:** Ano de lançamento do game;
-- MAGIC * **Gênero:** Gênero do jogo;
-- MAGIC * **Desenvolvedora:** Empresa que publicou o jogo;
-- MAGIC * **Vendas_NA:** Vendas na América do Norte (quantidade em milhões);
-- MAGIC * **Vendas_EU:** Vendas na Europa (quantidade em milhões);
-- MAGIC * **Vendas_JP:** Vendas no Japão (quantidade em milhões);
-- MAGIC * **Vendas_Outras:** Vendas no restante do mundo (quantidade em milhões);
-- MAGIC * **Total_Vendas:** Total de vendas no mundo inteiro.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #Análise Exploratória

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##Tratamento do dataset

-- COMMAND ----------

--Visualizando nossa tabela
SELECT * FROM vendas_videogames

-- COMMAND ----------

--Procurando por valores nulos
SELECT * FROM vendas_videogames
WHERE RANK IS NULL OR
      NOME IS NULL OR
      PLATAFORMA IS NULL OR
      ANO IS NULL OR
      GENERO IS NULL OR
      DESENVOLVEDORA IS NULL OR
      VENDAS_NA IS NULL OR
      VENDAS_EU IS NULL OR
      VENDAS_jp IS NULL OR
      VENDAS_OUTRAS IS NULL OR
      TOTAL_VENDAS IS NULL

--Aqui percebemos que temos vários valores nulos nas colunas Ano, Genero, Desenvolvedora, Plataforma e nas nossas colunas de quantidades vendidas.

-- COMMAND ----------

--Vamos criar uma tabela nova excluindo as linhas que não contenham as informações de quantidades vendidas pois não serão úteis para a análise.

CREATE TABLE dbvendas_ AS
  SELECT * FROM vendas_videogames
    WHERE VENDAS_NA IS NOT NULL AND
    VENDAS_EU IS NOT NULL AND
    VENDAS_JP IS NOT NULL AND
    VENDAS_OUTRAS IS NOT NULL AND
    TOTAL_VENDAS IS NOT NULL;

-- COMMAND ----------

--Também vamos substituir os valores nulos nas demais colunas para "Desconhecido".

UPDATE dbvendas_
SET
  ano = COALESCE(ano, 'desconhecido'),
  genero = COALESCE(genero, 'desconhecido'),
  desenvolvedora = COALESCE(desenvolvedora, 'desconhecido'),
  plataforma = COALESCE(plataforma, 'desconhecido')
WHERE 
  ano IS NULL OR
  genero IS NULL OR
  desenvolvedora IS NULL OR
  plataforma IS NULL


-- COMMAND ----------

-- MAGIC %md 
-- MAGIC ##Análises Univariadas

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Quantidade de jogos vendidos por ano de lançamento.**

-- COMMAND ----------

SELECT
  Ano,
  SUM(Total_vendas) AS Total_Vendas
FROM dbvendas_
GROUP BY ANO
ORDER BY Total_vendas DESC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Aqui percebemos que nossa base de dados após o ano de 2014 contém poucas informações, pois várias pesquisas indicam um número crescente de vendas de games conforme os anos vão passando.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Quantidade de jogos lançados por ano**

-- COMMAND ----------

SELECT
  Ano,
  COUNT(Nome) AS Quantidade_Jogos
FROM dbvendas_
GROUP BY ANO
ORDER BY Quantidade_Jogos DESC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Quantidade de jogos lançados por plataforma**

-- COMMAND ----------

SELECT
  Plataforma,
  COUNT(Nome) AS Quantidade_Jogos
FROM dbvendas_
GROUP BY Plataforma
ORDER BY Quantidade_Jogos DESC

-- COMMAND ----------

SELECT
  Plataforma,
  sum(Total_vendas) AS Vendas
FROM dbvendas_
GROUP BY Plataforma
ORDER BY Vendas DESC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Quantidade de jogos lançados por gênero**

-- COMMAND ----------

SELECT
  Genero,
  COUNT(Nome) AS Quantidade_Jogos
FROM dbvendas_
GROUP BY Genero
ORDER BY Quantidade_Jogos DESC;


-- COMMAND ----------

-- MAGIC %md 
-- MAGIC **Quantidade de vendas por gênero**

-- COMMAND ----------

SELECT
  Genero,
  SUM(Total_Vendas) AS Qtd_vendas
FROM dbvendas_
GROUP BY Genero
ORDER BY Qtd_vendas DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Quantidade de jogos lançados por desenvolvedora (TOP 50)**

-- COMMAND ----------

SELECT
  Desenvolvedora,
  COUNT(Nome) AS Quantidade_Jogos
FROM dbvendas_
GROUP BY Desenvolvedora
ORDER BY Quantidade_Jogos DESC
LIMIT 50;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Boxplot quantidade vendida por categoria**

-- COMMAND ----------

SELECT
  Genero,
  Total_vendas
FROM dbvendas_
ORDER BY Total_Vendas DESC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Com esse boxplot podemos visualizar vários outliers que são jogos que venderam um quantidade fora da curva. Vamos ver qual foi o jogo do maior outlier do gráfico, que foi da categoria de esportes.

-- COMMAND ----------

SELECT
  *
FROM dbvendas_
WHERE Genero = 'Sports'
ORDER BY Total_Vendas DESC
LIMIT 2

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Podemos notar que o jogo foi o "Wii Sports" que teve 82.74 milhões de vendas, muito maior que o segundo lugar "Wii Sports Resort" com 33 milhões de vendas.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Vendas por regiões**

-- COMMAND ----------

--A quantidade de vendas da base de dados está separada por colunas nas regiões. Para fazer um gráfico precisamos que as regiões estejam em apenas uma coluna.
--Também foram acrescentadas outras informações para serem usadas em outras análises.

ALTER VIEW Vendas_Regiao AS
SELECT 'América do Norte' as Regiao, ano,Genero, SUM(vendas_na) as vendas, AVG(vendas_na) as media FROM dbvendas_ GROUP BY REGIAO, ANO, Genero
UNION ALL
SELECT 'Europa' as Regiao, ano,Genero, SUM(vendas_eu) as vendas, AVG(vendas_eu) as media FROM dbvendas_ GROUP BY REGIAO, ANO, Genero
UNION ALL
SELECT 'Japão' as Regiao,ano,Genero, SUM(vendas_jp) as vendas, AVG(vendas_jp) as media  FROM dbvendas_ GROUP BY REGIAO, ANO, Genero
UNION ALL
SELECT 'Restante do Mundo' as Regiao,ano,Genero, SUM(vendas_outras) as vendas, AVG(vendas_outras) as media FROM dbvendas_ GROUP BY Regiao, ANO, Genero;
SELECT * FROM Vendas_Regiao

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Média de vendas de jogo por categoria**

-- COMMAND ----------

SELECT 
  t1.Plataforma,
  t2.Media_Vendas/t1.Qtd_jogos AS Media_Vendas_por_jogo,
  t1.Qtd_jogos
FROM (SELECT
        Plataforma, COUNT(*) AS Qtd_Jogos
      FROM dbvendas_
      GROUP BY Plataforma
      ) as t1
INNER JOIN (
       SELECT
         Plataforma, AVG(Total_vendas) AS Media_Vendas
       FROM dbvendas_
       GROUP BY Plataforma
       ) as t2
ON t1.Plataforma = t2. Plataforma
ORDER BY Media_Vendas_por_jogo DESC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Até aqui tiramos algumas conclusões:<br>
-- MAGIC * O ano de lançamento dos jogos que mais venderam foi 2008;
-- MAGIC * O ano em que mais foram lançados jogos foi em 2009, com 1 jogo a mais comparando a 2008;
-- MAGIC * Nintendo DS foi a plataforma que mais recebeu jogos, com 3 jogos a mais comparando ao famoso PS2;
-- MAGIC * O gênero com mais jogos é ação;
-- MAGIC * Desenvolvedora que mais produziu jogos foi a Eletronic Arts;
-- MAGIC * A mediana de quantidade vendida por jogo é de 2.9M, porém existem vários outliers que são jogos que venderam uma quantidade muito maior que a média;
-- MAGIC * Normalmente quanto maior a quantidade de jogos na plataforma mais a média de vendas é baixa;
-- MAGIC * América do Norte corresponde a quase 50% das vendas de jogos.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##Análises Bivariadas

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Quantidade de jogos por desenvolvedora e Gênero**

-- COMMAND ----------

SELECT
  Desenvolvedora,
  Genero,
  COUNT(Nome) AS Quantidade_Jogos
FROM dbvendas_
GROUP BY Desenvolvedora, Genero
ORDER BY Quantidade_Jogos DESC


-- COMMAND ----------

-- MAGIC %md 
-- MAGIC **Vendas por ano em cada região**

-- COMMAND ----------

SELECT * FROM Vendas_Regiao

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Podemos ver uma forte queda nas vendas após 2010, possivelmente isso está atrelado a falta de informações em nossa base de dados.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Relação entre as duas maiores regiões de venda**

-- COMMAND ----------

SELECT
  Genero,
  Vendas_NA,
  Vendas_EU,
  VENDAS_JP,
  VENDAS_OUTRAS
FROM
  dbvendas_

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Percebemos uma relação positiva forte entre os dois mercados, isso pode ser um indicador de que há uma demanda semelhante ou uma tendência de consumo semelhante entre esses dois continentes.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Mapa de calor de vendas por gênero e plataforma**

-- COMMAND ----------

SELECT
  GENERO,
  PLATAFORMA,
  SUM(TOTAL_VENDAS)
FROM
  dbvendas_
  GROUP BY GENERO, PLATAFORMA
  ORDER BY SUM(TOTAL_VENDAS) DESC

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Podemos ver que existem plataformas que perfomaram bem em alguns generos como o Wii, também existem plataformas que perfomaram bem em praticamente todos os gêneros como PS3 e PS2.

-- COMMAND ----------

-- MAGIC %md 
-- MAGIC **Média de vendas por categoria e região**

-- COMMAND ----------

SELECT 'América do Norte' as Regiao, Genero, vendas_na as Media_vendas FROM dbvendas_ 
UNION ALL
SELECT 'Europa' as Regiao, Genero, vendas_eu as Media_vendas FROM dbvendas_ 
UNION ALL
SELECT 'Japão' as Regiao,Genero, vendas_jp as Media_vendas FROM dbvendas_ 
UNION ALL
SELECT 'Restante do Mundo' as Regiao,Genero, vendas_outras as Media_vendas FROM dbvendas_ 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #Conclusão
-- MAGIC <br>
-- MAGIC 
-- MAGIC * América do Norte e Japão são as regiões de maior destaque para a venda de games. Esses mercados devem ser levados em consideração pelos desenvolvedores de jogos em termos de marketing e localização do lançamento;
-- MAGIC * As regiões de maior relevância tem relações positivas fortes entre si, isso pode indicar que há uma demanda semelhante ou uma tendência de consumo semelhante entre elas;
-- MAGIC * A quantidade de jogos em uma plataforma tem uma relação inversa com a média de vendas. Indicando que uma maior oferta de jogos pode levar à dispersão das vendas em uma plataforma, tornando mais difícil para um jogo se destacar e obter vendas significativas;
-- MAGIC * As plataformas que mais se destacam em vendas são PS2, Xbox360 e PS3. Elas também demonstraram que se dão bem nas vendas de praticamente todos os gêneros de jogos;
-- MAGIC * Cada desenvolvedora demonstrou foco em um gênero específico de game;
-- MAGIC * A preferência dos jogadores da América do Norte se inclina pelos gêneros "Platform" e "Shooter", enquanto no Japão, "RPG" e "Platform" são mais populares. Já o resto do mundo tem maior afinidade por "Shooter" e "Racing".
