-- ============================================================================
-- BANCO DE DADOS INTERMEDIÁRIO - e-Astronomia — LIneA
-- Seção 1: Consultas SQL Avançadas
-- ============================================================================
--
-- Banco de dados: dados/biblioteca.db
-- Ferramenta: DB Browser for SQLite
--
-- Como usar:
--   1. Abra o DB Browser for SQLite
--   2. Vá em File > Open Database e selecione dados/biblioteca.db
--   3. Clique na aba "Execute SQL"
--   4. Selecione cada bloco abaixo e pressione Ctrl+Enter (ou o botão Play)
--
-- Schema:
--   livros(id, titulo, genero, ano)              — 100.000 linhas
--   usuarios(id, nome, cidade)                   —  10.000 linhas
--   emprestimos(id, usuario_id, livro_id,
--               data_emp, data_dev)              — 500.000 linhas
--
-- ============================================================================


-- ============================================================================
-- 1.1  REVISÃO: SELECT, WHERE, ORDER BY
-- ============================================================================

-- Livros de ficção publicados após 2010
SELECT id, titulo, ano
FROM   livros
WHERE  genero = 'Ficcao'
  AND  ano > 2010
ORDER  BY ano
LIMIT  5;


-- ============================================================================
-- 1.2  JOINS — Combinando Tabelas
-- ============================================================================

-- ── INNER JOIN ───────────────────────────────────────────────────────────────
-- Usuários que fizeram pelo menos um empréstimo (apenas pares com match)
SELECT u.nome, e.data_emp
FROM   usuarios AS u
INNER JOIN emprestimos AS e
        ON u.id = e.usuario_id
LIMIT  10;

-- ── LEFT JOIN ────────────────────────────────────────────────────────────────
-- Todos os livros, com ou sem empréstimo
SELECT l.titulo, e.data_emp
FROM   livros AS l
LEFT JOIN emprestimos AS e
       ON l.id = e.livro_id
LIMIT  10;

-- LEFT JOIN para encontrar livros NUNCA emprestados
SELECT l.titulo
FROM   livros AS l
LEFT JOIN emprestimos AS e
       ON l.id = e.livro_id
WHERE  e.livro_id IS NULL
LIMIT  10;

-- ── FULL OUTER JOIN (emulado no SQLite) ──────────────────────────────────────
-- SQLite não suporta FULL OUTER JOIN nativamente.
-- Emulação: LEFT JOIN + LEFT JOIN invertido com UNION ALL
SELECT l.titulo, e.id AS emprestimo_id
FROM   livros AS l
LEFT JOIN emprestimos AS e ON l.id = e.livro_id

UNION ALL

SELECT l.titulo, e.id AS emprestimo_id
FROM   emprestimos AS e
LEFT JOIN livros AS l ON e.livro_id = l.id
WHERE  l.id IS NULL
LIMIT  10;


-- ============================================================================
-- 1.3  FUNÇÕES DE AGREGAÇÃO
-- ============================================================================

-- Estatísticas gerais dos livros de ficção
SELECT COUNT(*)   AS total,
       MIN(ano)   AS mais_antigo,
       MAX(ano)   AS mais_novo,
       AVG(ano)   AS media_ano
FROM   livros
WHERE  genero = 'Ficcao';

-- Total de empréstimos e quantos ainda estão em aberto (sem devolução)
SELECT COUNT(*)                       AS total_emprestimos,
       COUNT(data_dev)                AS devolvidos,
       COUNT(*) - COUNT(data_dev)     AS em_aberto
FROM   emprestimos;


-- ============================================================================
-- 1.4  GROUP BY — Agrupando Resultados
-- ============================================================================

-- Quantidade de livros por gênero, ordenado do maior para o menor
SELECT genero,
       COUNT(*) AS total,
       MIN(ano) AS mais_antigo
FROM   livros
GROUP  BY genero
ORDER  BY total DESC;

-- Empréstimos por ano
SELECT strftime('%Y', data_emp) AS ano,
       COUNT(*)                 AS total
FROM   emprestimos
GROUP  BY ano
ORDER  BY ano;


-- ============================================================================
-- 1.5  HAVING — Filtrando Grupos
-- ============================================================================

-- Gêneros com mais de 10.000 livros
SELECT genero,
       COUNT(*) AS total
FROM   livros
GROUP  BY genero
HAVING COUNT(*) > 10000
ORDER  BY total DESC;

-- Usuários com mais de 10 empréstimos
SELECT usuario_id,
       COUNT(*) AS total_emprestimos
FROM   emprestimos
GROUP  BY usuario_id
HAVING COUNT(*) > 10
ORDER  BY total_emprestimos DESC
LIMIT  10;


-- ============================================================================
-- 1.6  SUBCONSULTAS
-- ============================================================================

-- ── Subconsulta escalar: livros publicados após a média ───────────────────────
SELECT id, titulo, ano
FROM   livros
WHERE  ano > (
    SELECT AVG(ano)
    FROM   livros
)
LIMIT  10;

-- ── Subconsulta IN: livros com empréstimos em aberto ─────────────────────────
SELECT titulo, genero
FROM   livros
WHERE  id IN (
    SELECT livro_id
    FROM   emprestimos
    WHERE  data_dev IS NULL
)
LIMIT  10;

-- Equivalente com INNER JOIN (geralmente mais eficiente)
SELECT DISTINCT l.titulo, l.genero
FROM   livros AS l
JOIN   emprestimos AS e
    ON l.id = e.livro_id
WHERE  e.data_dev IS NULL
LIMIT  10;

-- ── Subconsulta correlacionada: livros emprestados 3 ou mais vezes ────────────
-- (Atenção: executa uma vez por linha — lento em tabelas grandes)
SELECT l.id, l.titulo
FROM   livros AS l
WHERE (
    SELECT COUNT(*)
    FROM   emprestimos
    WHERE  livro_id = l.id
) >= 3
LIMIT  10;


-- ============================================================================
-- 1.7  CTEs — Common Table Expressions
-- ============================================================================

-- ── CTE simples: livros recentes ──────────────────────────────────────────────
WITH recentes AS (
    SELECT id, titulo, genero
    FROM   livros
    WHERE  ano >= 2020
)
SELECT genero, COUNT(*) AS total
FROM   recentes
GROUP  BY genero;

-- ============================================================================
