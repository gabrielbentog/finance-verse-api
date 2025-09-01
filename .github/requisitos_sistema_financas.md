# 📋 Lista de Requisitos - Sistema de Finanças Pessoais

  -------------------------------------------------------------------------------
  ID     Descrição      História do Usuário    Comportamento/Resultado Esperado
  ------ -------------- ---------------------- ----------------------------------
  RF01   Cadastro de    Como usuário, quero me O sistema deve permitir que o
         Usuário        cadastrar no sistema   usuário crie uma conta com e-mail
                        para ter acesso às     e senha válidos, salvando os dados
                        minhas finanças        no banco.
                        pessoais.              

  RF02   Login de       Como usuário, quero    O sistema deve autenticar o
         Usuário        realizar login no      usuário com e-mail e senha,
                        sistema para acessar   retornando um token de sessão
                        minhas informações.    válido.

  RF03   Cadastro de    Como usuário, quero    O sistema deve permitir incluir
         Receitas       cadastrar minhas       receitas com valor, categoria,
                        receitas para          data e descrição.
                        controlar meus ganhos  
                        mensais.               

  RF04   Cadastro de    Como usuário, quero    O sistema deve permitir incluir
         Despesas       cadastrar minhas       despesas com valor, categoria,
                        despesas para          data e descrição.
                        acompanhar meus        
                        gastos.                

  RF05   Importação de  Como usuário, quero    O sistema deve permitir upload de
         Faturas        importar minha fatura  arquivos CSV/XLSX de fatura e
                        do cartão de crédito   categorizar despesas.
                        para organizar         
                        automaticamente meus   
                        gastos.                

  RF06   Visualização   Como usuário, quero    O sistema deve gerar relatórios
         de Gastos por  visualizar relatórios  gráficos (pizza, barras) com
         Categoria      de gastos por          filtros por período.
                        categoria para         
                        identificar onde gasto 
                        mais.                  

  RF07   Exportação de  Como usuário, quero    O sistema deve permitir exportar
         Relatórios     exportar relatórios    relatórios em formato CSV/XLSX.
                        financeiros para       
                        analisar em planilhas. 

  RF08   Dashboard      Como usuário, quero    O sistema deve exibir KPIs (saldo,
         Resumo         visualizar um resumo   total de despesas, receitas,
         Financeiro     financeiro com         categorias mais gastas).
                        receitas, despesas e   
                        saldo mensal.          

  RF09   Dark/Light     Como usuário, quero    O sistema deve permitir alternar o
         Mode           alternar entre modo    tema globalmente e manter a
                        claro e escuro para    preferência salva.
                        melhor usabilidade.    

  RF10   Segurança e    Como usuário, quero    O sistema deve armazenar senhas
         Autenticação   que meus dados estejam criptografadas e utilizar tokens
                        protegidos com         de acesso seguros (JWT).
                        autenticação segura.   
  -------------------------------------------------------------------------------

------------------------------------------------------------------------

📌 **Observações:** - Todos os requisitos devem ser priorizados para a
versão inicial do sistema (MVP). - A API será desenvolvida em **Ruby on
Rails 8** e o frontend em **Next.js com TypeScript e MUI**.
