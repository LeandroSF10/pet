# pet

Rotas e suas funcionalidades:

  /login -> Autenticação. É necessário o nome do pet cadastrado no site juntamente com a senha, para que seja possível navegar no site.
   
  / -> Tela com menu de navegação de fácil acesso.
  
  /pet -> Tela de cadastro de pets. Aqui o dono do pet cadastra seu animal de estimação, onde ele informa o nome do pet e uma senha, que serão exigidos para ele navegar no site.
  
  /serv -> Autorização. Somente o administrador tem acesso a esse serviço do site. Aqui o administrador cadastra um serviço disponível no pet-shop e define o valor deste serviço.
   
  /petServ -> É aqui onde exite a relação N pra N das 3 tabelas existentes dentro deste site. Aqui o usuário comum relaciona seu pet com o serviço que ele deseja realizar. Por exemplo, eu escolho meu pet, toby, e o serviço de banho. Agendando assim, um banho para meu pet, no pet-shop.
   
  /listar -> Essa página permite ver todos os pets cadastrados em nosso site!
   
  /listS -> Nessa página é exibido todos os serviços disponíveis no pet-shop e seus respectivos preços, dentro de uma tabela.
  
  /admin -> Autorização. Parte restrita do site. Somente o administrador tem acesso a essa parte do site, onde simplesmente é dado boas vindas e é exibido seu nome de usuário.
  
  /bye -> Acessando essa página, é feito o logoff do usuário no site.
  
Usuários cadastrados:

Nome do pet: toby
Senha: 123

Nome do pet: admin
Senha: admin
