-- ============================================================================
-- BANCO DE DADOS INTERMEDIÁRIO - e-Astronomia — LIneA
-- Seção 2: Otimização e Performance de Queries
-- ============================================================================
--
-- Bancos de dados:
--   dados/biblioteca.db          — sem índices (demonstra full table scan)
--   dados/biblioteca_indexada.db — com índices (demonstra busca via B-tree)
--
-- Ferramenta: DB Browser for SQLite
--
-- Dica: use Ctrl+Enter para executar o bloco selecionado.
--       Observe o tempo de execução exibido na barra inferior do DB Browser.
--
-- ============================================================================


-- ============================================================================
-- 2.1  O PROBLEMA: VARREDURA COMPLETA DA TABELA (Full Table Scan)
-- ============================================================================
-- Abra: dados/biblioteca.db  (SEM índices)

-- Esta query examina TODAS as 100.000 linhas de livros
EXPLAIN QUERY PLAN
SELECT id, titulo, genero
FROM   livros
WHERE  genero = 'Ficcao'
  AND  ano > 2000;
-- Resultado esperado: SCAN livros  (varredura completa)

-- Execute sem o EXPLAIN para ver o tempo real
SELECT id, titulo, genero
FROM   livros
WHERE  genero = 'Ficcao'
  AND  ano > 2000
LIMIT  10;


-- ============================================================================
-- 2.2  CRIANDO ÍNDICES
-- ============================================================================
-- Ainda em: dados/biblioteca.db

-- Índice simples em uma coluna
CREATE INDEX IF NOT EXISTS idx_genero
    ON livros(genero);

-- Índice em coluna usada em JOIN
CREATE INDEX IF NOT EXISTS idx_emp_livro
    ON emprestimos(livro_id);

-- Índice em coluna usada em JOIN (outro lado)
CREATE INDEX IF NOT EXISTS idx_emp_usuario
    ON emprestimos(usuario_id);

-- Verificar índices criados
PRAGMA index_list('livros');
PRAGMA index_list('emprestimos');


-- ============================================================================
-- 2.3  EXPLAIN QUERY PLAN — SCAN vs SEARCH
-- ============================================================================

-- Após criar idx_genero, a mesma query agora usa o índice
EXPLAIN QUERY PLAN
SELECT id, titulo, genero
FROM   livros
WHERE  genero = 'Ficcao'
  AND  ano > 2000;
-- Resultado esperado: SEARCH livros USING INDEX idx_genero (genero=?)

-- Removendo o índice para voltar ao estado anterior
DROP INDEX IF EXISTS idx_genero;

-- Confirmando que voltou ao SCAN
EXPLAIN QUERY PLAN
SELECT id, titulo, genero
FROM   livros
WHERE  genero = 'Ficcao'
  AND  ano > 2000;
-- Resultado esperado: SCAN livros


-- ============================================================================
-- 2.4  ÍNDICES COMPOSTOS: MÚLTIPLOS FILTROS
-- ============================================================================

-- Índice composto em (genero, ano)
CREATE INDEX IF NOT EXISTS idx_gen_ano
    ON livros(genero, ano);

-- Esta query USA o índice composto (filtra por genero E ano)
EXPLAIN QUERY PLAN
SELECT id, titulo
FROM   livros
WHERE  genero = 'Ficcao'
  AND  ano > 2010;
-- Resultado esperado: SEARCH livros USING INDEX idx_gen_ano (genero=? AND ano>?)

-- Esta query usa apenas o primeiro campo do índice (genero)
EXPLAIN QUERY PLAN
SELECT id, titulo
FROM   livros
WHERE  genero = 'Ficcao';
-- Resultado esperado: SEARCH livros USING INDEX idx_gen_ano (genero=?)

-- Esta query NÃO usa o índice (segundo campo sem o primeiro)
EXPLAIN QUERY PLAN
SELECT id, titulo
FROM   livros
WHERE  ano > 2010;
-- Resultado esperado: SCAN livros


-- ============================================================================
-- 2.5  COMPARAÇÃO: biblioteca.db vs biblioteca_indexada.db
-- ============================================================================
-- Feche biblioteca.db e abra: dados/biblioteca_indexada.db
-- (já contém índices pré-criados nas colunas principais)

-- Verifique os índices existentes
PRAGMA index_list('livros');
PRAGMA index_list('emprestimos');

-- JOIN com índices — observe o tempo comparado ao banco sem índice
EXPLAIN QUERY PLAN
SELECT u.nome,
       l.titulo,
       e.data_emp
FROM   emprestimos AS e
JOIN   usuarios    AS u ON e.usuario_id = u.id
JOIN   livros      AS l ON e.livro_id   = l.id
WHERE  l.genero = 'Ficcao'
  AND  e.data_dev IS NULL
LIMIT  20;

-- Execute sem o EXPLAIN para medir o tempo real
SELECT u.nome,
       l.titulo,
       e.data_emp
FROM   emprestimos AS e
JOIN   usuarios    AS u ON e.usuario_id = u.id
JOIN   livros      AS l ON e.livro_id   = l.id
WHERE  l.genero = 'Ficcao'
  AND  e.data_dev IS NULL
LIMIT  20;


-- ============================================================================
-- 2.6  BOAS PRÁTICAS DE ESCRITA SQL
-- ============================================================================

-- ── Evite: funções sobre colunas indexadas desabilitam o índice ───────────────
EXPLAIN QUERY PLAN
SELECT id FROM livros
WHERE  UPPER(genero) = 'FICCAO';
-- Resultado: SCAN livros  (índice ignorado)

-- Prefira: coluna isolada no filtro
EXPLAIN QUERY PLAN
SELECT id FROM livros
WHERE  genero = 'Ficcao';
-- Resultado: SEARCH livros USING INDEX ...


-- ── Evite: múltiplos OR na mesma coluna ──────────────────────────────────────
SELECT id, titulo
FROM   livros
WHERE  genero = 'Ficcao'
   OR  genero = 'Romance'
   OR  genero = 'Historia';

-- Prefira: IN (mais legível e melhor otimizado)
SELECT id, titulo
FROM   livros
WHERE  genero IN ('Ficcao', 'Romance', 'Historia');


-- ── Evite: SELECT * em produção ──────────────────────────────────────────────
-- Ruim: carrega colunas desnecessárias
SELECT * FROM livros WHERE genero = 'Ficcao' LIMIT 5;

-- Bom: apenas as colunas necessárias
SELECT id, titulo, ano
FROM   livros
WHERE  genero = 'Ficcao'
LIMIT  5;


-- ── Subconsulta correlacionada vs JOIN ────────────────────────────────────────
-- Lento: executa uma subconsulta por linha de livros
SELECT l.titulo
FROM   livros AS l
WHERE (
    SELECT COUNT(*)
    FROM   emprestimos
    WHERE  livro_id = l.id
) >= 3
LIMIT  10;

-- Rápido: JOIN com agregação
SELECT l.titulo
FROM   livros AS l
JOIN   emprestimos AS e ON l.id = e.livro_id
GROUP  BY l.id, l.titulo
HAVING COUNT(*) >= 3
LIMIT  10;

-- ============================================================================
