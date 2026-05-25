# Banco de Dados Intermediário para e-Astronomia — LIneA

Bem-vindo ao curso! Este pacote contém os materiais necessários para acompanhar as aulas.

---

## O que está incluído

| Arquivo / Pasta | Conteúdo |
|---|---|
| `slides/slides.pdf` | Slides das aulas |
| `scripts/01-consultas-avancadas.sql` | Seção 1 — Queries de JOINs, CTEs e Window Functions |
| `scripts/02-otimizacao.sql` | Seção 2 — Queries de índices e EXPLAIN QUERY PLAN |
| `notebooks/03-integracao-python.ipynb` | Seção 3 — Python + SQL |
| `notebooks/04-estudo-caso.ipynb` | Seção 4 — Estudo de caso com DES DR2 |
| `notebooks/05-acesso-linea-pyvo.ipynb` | Seção 5 — Acesso ao catálogo DES DR2 via TAP |
| `requirements.txt` | Dependências Python |

---

## Pré-requisitos

- **Python 3.10 ou superior**

Verifique sua versão:
```bash
python --version
```

Download: https://www.python.org/downloads/

---

## Instalação

**1. Abra o terminal na pasta onde você extraiu os arquivos**

```bash
cd curso-bd-interm-linea
```

**2. Crie um ambiente virtual**

```bash
# Windows
python -m venv venv

# Linux / macOS
python3 -m venv venv
```

**3. Ative o ambiente virtual**

```bash
# Windows (Prompt de Comando)
venv\Scripts\activate.bat

# Windows (PowerShell)
venv\Scripts\Activate.ps1

# Linux / macOS
source venv/bin/activate
```

Após ativar, o terminal exibe `(venv)` no início da linha.

**4. Instale as dependências**

```bash
pip install -r requirements.txt
```

**5. Verifique a instalação**

```bash
python -c "import pandas, matplotlib, jupyter; print('OK')"
```

---

## Download dos dados

Os bancos de dados utilizados nas aulas estão disponíveis no Google Drive:

📁 **[https://drive.google.com/drive/folders/1u5bk6BV26oiefUTPSdfWwKHU4oqDd1vb?usp=sharing](https://drive.google.com/drive/folders/1u5bk6BV26oiefUTPSdfWwKHU4oqDd1vb?usp=sharing)**

Após o download, organize os arquivos assim (crie as pastas se necessário):

```
curso-bd-interm-linea/
├── dados/
│   ├── biblioteca.db
│   ├── biblioteca_indexada.db
│   └── processed/
│       └── course_database.db
```

---

## Usando os scripts SQL (Seções 1 e 2)

As seções 1 e 2 utilizam o **DB Browser for SQLite** para executar queries diretamente no banco da biblioteca.

**Passo a passo:**

1. Baixe e instale o DB Browser for SQLite: https://sqlitebrowser.org/
2. Abra o programa e vá em **File > Open Database**
3. Selecione o arquivo de banco de dados:
   - Seção 1 — `dados/biblioteca.db`
   - Seção 2 — comece com `dados/biblioteca.db`, depois compare com `dados/biblioteca_indexada.db`
4. Clique na aba **Execute SQL**
5. Abra o arquivo `.sql` correspondente em qualquer editor de texto
6. Copie e cole cada bloco de query no DB Browser e pressione **Ctrl+Enter** para executar

---

## Abrindo os notebooks

Com o ambiente virtual ativado:

```bash
jupyter lab
```

Ou, se preferir a interface clássica:

```bash
jupyter notebook
```

Navegue até a pasta `notebooks/` e abra o notebook desejado:

| Notebook | Conteúdo | Banco de dados |
|---|---|---|
| `03-integracao-python.ipynb` | Python + SQL, pandas, matplotlib | `dados/biblioteca.db` |
| `04-estudo-caso.ipynb` | Pipeline completo com DES DR2 | `dados/processed/course_database.db` |
| `05-acesso-linea-pyvo.ipynb` | Acesso ao catálogo DES DR2 via TAP | LIneA User Query (online) |

---

## Dependências Python

| Pacote | Uso |
|---|---|
| `pandas` | Leitura e análise de dados |
| `matplotlib` | Gráficos e visualizações |
| `numpy` | Cálculos numéricos |
| `jupyter` / `jupyterlab` | Interface dos notebooks |
| `pyvo` | Acesso a catálogos via protocolo TAP (notebook 05) |
| `astropy` | Coordenadas astronômicas (notebook 05) |
| `requests` | Requisições HTTP (notebook 05) |

O módulo `sqlite3` é nativo do Python — não precisa instalar.

> **Notebook 05 no LIneA JupyterHub:** `pyvo`, `astropy` e `requests`
> já estão disponíveis no ambiente — não é necessário instalá-los.

---

## Dúvidas

Canal do curso no Slack LIneA Users:
**https://lineausers.slack.com**
