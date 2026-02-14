// =====================================================
// LIMPEZA TOTAL DA BASE DE DADOS
// Remove todos os nós e relacionamentos existentes
// =====================================================
MATCH (n)
DETACH DELETE n;



// =====================================================
// CRIAÇÃO DE CONSTRAINTS (INTEGRIDADE DOS DADOS)
// Garante unicidade e melhora performance das consultas
// =====================================================
CREATE CONSTRAINT user_id IF NOT EXISTS
FOR (u:User) REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT post_id IF NOT EXISTS
FOR (p:Post) REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT tag_name IF NOT EXISTS
FOR (t:Tag) REQUIRE t.name IS UNIQUE;

CREATE CONSTRAINT community_name IF NOT EXISTS
FOR (c:Community) REQUIRE c.name IS UNIQUE;



// =====================================================
// CRIAÇÃO DE USUÁRIOS
// Representa pessoas na plataforma
// =====================================================
CREATE
(u1:User {id: 1, name: "Ana"}),
(u2:User {id: 2, name: "Bruno"}),
(u3:User {id: 3, name: "Carlos"});



// =====================================================
// CONEXÕES ENTRE USUÁRIOS (FOLLOWERS)
// Modela a rede social
// =====================================================
MATCH (a:User {id:1}), (b:User {id:2}), (c:User {id:3})
CREATE
(a)-[:FOLLOWS]->(b),
(b)-[:FOLLOWS]->(c),
(a)-[:FOLLOWS]->(c);



// =====================================================
// CRIAÇÃO DE POSTS (CONTEÚDO)
// =====================================================
CREATE
(p1:Post {id: 101, content: "Graph databases são poderosas"}),
(p2:Post {id: 102, content: "Neo4j + Cypher é vida"});



// =====================================================
// ASSOCIAÇÃO DE POSTS A USUÁRIOS (AUTORIA)
// =====================================================
MATCH (u:User {id:1}), (p:Post {id:101})
CREATE (u)-[:POSTED]->(p);

MATCH (u:User {id:2}), (p:Post {id:102})
CREATE (u)-[:POSTED]->(p);



// =====================================================
// ENGAJAMENTO: LIKES E COMENTÁRIOS
// =====================================================
MATCH (u:User {id:2}), (p:Post {id:101})
CREATE (u)-[:LIKED]->(p);

MATCH (u:User {id:3}), (p:Post {id:101})
CREATE (u)-[:COMMENTED {text:"Excelente conteúdo!"}]->(p);



// =====================================================
// CRIAÇÃO DE TAGS E COMUNIDADES
// Representam interesses e grupos
// =====================================================
CREATE
(t1:Tag {name:"Neo4j"}),
(t2:Tag {name:"Grafos"}),
(c1:Community {name:"Data Science"});



// =====================================================
// ASSOCIAÇÃO DE POSTS A TAGS (TEMAS)
// =====================================================
MATCH (p:Post {id:101}), (t:Tag {name:"Grafos"})
CREATE (p)-[:TAGGED_WITH]->(t);

MATCH (p:Post {id:102}), (t:Tag {name:"Neo4j"})
CREATE (p)-[:TAGGED_WITH]->(t);



// =====================================================
// ASSOCIAÇÃO DE USUÁRIOS A COMUNIDADES
// =====================================================
MATCH (u:User {id:1}), (c:Community {name:"Data Science"})
CREATE (u)-[:MEMBER_OF]->(c);

MATCH (u:User {id:2}), (c:Community {name:"Data Science"})
CREATE (u)-[:MEMBER_OF]->(c);



// =====================================================
// CONSULTAS ANALÍTICAS (EXEMPLOS)
// =====================================================

// --- Post mais popular (likes + comentários)
MATCH (p:Post)
OPTIONAL MATCH (p)<-[l:LIKED]-()
OPTIONAL MATCH (p)<-[c:COMMENTED]-()
RETURN p.content,
count(DISTINCT l) + count(DISTINCT c) AS engajamento
ORDER BY engajamento DESC;



// --- Usuários mais influentes (nº de seguidores)
MATCH (u:User)<-[:FOLLOWS]-()
RETURN u.name, count(*) AS seguidores
ORDER BY seguidores DESC;



// --- Comunidades mais ativas
MATCH (c:Community)<-[:MEMBER_OF]-(u:User)
RETURN c.name, count(u) AS membros
ORDER BY membros DESC;



// --- Sugestão de novos seguidores (amigos de amigos)
MATCH (u:User {id:1})-[:FOLLOWS]->(:User)-[:FOLLOWS]->(sug:User)
WHERE NOT (u)-[:FOLLOWS]->(sug) AND u <> sug
RETURN DISTINCT sug.name;



// --- Conteúdos por interesse (tag)
MATCH (t:Tag {name:"Grafos"})<-[:TAGGED_WITH]-(p:Post)
RETURN p.content;
