![imgPokemon](https://github.com/user-attachments/assets/0eb8faad-b7ed-402e-a491-5f0d06ffae03)

## 1. Equipe:
- Amanda Queiroz Sobral
- Carlos Eduardo Domingues Hobmeier
- João Vitor de Freitas
- Théo Nicoleli

## 2. Demonstração em vídeo: 
Funcionamento completo do aplicativo no YouTube:  
[PokéExplorer](https://youtu.be/[https://www.youtube.com/watch?v=YTS854zc8ug)

## 3. Descrição do aplicativo:
O **PokéExplorer** é um aplicativo iOS (Swift + SwiftUI) que:

* Exibe uma lista paginada de Pokémon (20 por página) com scroll infinito.  
* Apresenta detalhes completos: sprite, tipos, habilidades, movimentos, altura e peso.  
* Permite ao usuário, após login, marcar Pokémon como favoritos e acessá‑los offline.  
* Oferece UI adaptativa (iPhone/iPad, retrato/paisagem) com animações suaves.



## 4. Escolha da API:

**API:** [PokéAPI](https://pokeapi.co/)

Utilizamos a PokéAPI porque é pública e gratuita, fornece dados abrangentes da franquia Pokémon e tem respostas JSON simples, facilitando o uso de `Codable`.

#### 4.1 Como usamos a API

* `PokeAPIService` é um `Singleton` com **async/await** que expõe dois métodos principais:  

```swift
func fetchPage(offset: Int, limit: Int = 20) async throws -> [ListedPokemon]
func fetchDetail(id: Int) async throws -> PokemonDetail
```

* A lista principal chama `fetchPage` sempre que precisa de uma nova página.  
* A tela de detalhes chama `fetchDetail` apenas para o Pokémon selecionado, evitando tráfego desnecessário.

#### 4.2 Endpoints e campos utilizados

| Endpoint | Uso | Campos |
|----------|-----|--------|
| /pokemon?limit=20&offset=n | Lista principal | `name`, `url` |
| /pokemon/{id} | Tela de detalhes | `sprites`, `types`, `abilities`, `moves`, `height`, `weight` |



## 5. Arquitetura do aplicativo (diagrama MVVM):

![image](https://github.com/user-attachments/assets/f366baaa-2850-4f61-b25c-479440422647)

1. **View** liga‑se ao **ViewModel** via `@ObservedObject` e reflete qualquer mudança de estado.  
2. O **ViewModel** chama o **Repository** para obter ou gravar dados, mas nunca sabe de onde eles vêm.  
3. O **Repository** decide qual fonte usar:  
   * se o dado está no **CoreDataStore**, devolve imediatamente;  
   * se precisa de dados novos, faz uma chamada ao **PokeAPIService**.  
4. O **CoreDataStore** persiste tudo com NSPersistentContainer e SQLite; as consultas são feitas com `NSFetchRequest`.



## 6. Implementação do Core Data:

#### 6.1 Modelo de Dados:

O modelo de dados foi definido através do arquivo `.xcdatamodeld`, onde foram criadas duas entidades principais:

| Entidade  | Atributos                                          | Finalidade                              |
|-----------|----------------------------------------------------|-----------------------------------------|
| `Usuario` | `id: UUID`, `username: String`, `email: String`, `senhaHash: String` | Representa o usuário autenticado |
| `Favorito` | `id: Int`, `name: String`, `url: String`, `ownerID: UUID`         | Representa um Pokémon favoritado pelo usuário |

Essas entidades são convertidas automaticamente em subclasses de `NSManagedObject` e utilizadas nas operações de persistência e consulta.


#### 6.2 Como os dados são salvos:

O projeto utiliza um singleton chamado `PersistenceController`, que instancia um `NSPersistentContainer`:

```swift
let container = NSPersistentContainer(name: "PokeAppModel")
container.loadPersistentStores { description, error in
    if let error = error {
        fatalError("Erro ao carregar Core Data: \(error)")
    }
}
```

Essa estrutura carrega e gerencia o contexto de persistência (`viewContext`) usado para inserir e salvar dados.  
Exemplo de como um usuário é salvo:

```swift
let usuario = Usuario(context: viewContext)
usuario.username = nome
usuario.email = email
usuario.senhaHash = gerarHash(senha)
try? viewContext.save()
```


#### 6.3 Como os dados são buscados:

As consultas são realizadas com `NSFetchRequest`. Por exemplo, para buscar um usuário por e-mail e senha:

```swift
let request = Usuario.fetchRequest()
request.predicate = NSPredicate(format: "email == %@ AND senhaHash == %@", email, hash)
let resultados = try viewContext.fetch(request)
```

Esse padrão também é usado para carregar os Pokémon favoritos de um usuário específico:

```swift
let request = Favorito.fetchRequest()
request.predicate = NSPredicate(format: "ownerID == %@", userID as CVarArg)
let favoritos = try viewContext.fetch(request)
```



#### 6.4 Como a autenticação foi implementada:

O processo de autenticação funciona da seguinte forma:

1. **Cadastro:**  
   - A senha digitada é convertida em hash com uma função de segurança.
   - Um objeto `Usuario` é criado e salvo no banco de dados.

2. **Login:**  
   - Durante o login, o app busca por um usuário com o e-mail informado e o hash da senha.
   - Se encontrado, o `UUID` do usuário é armazenado localmente (em `UserDefaults`), permitindo manter a sessão ativa.

3. **Sessão ativa:**  
   - O `UUID` armazenado é reutilizado para filtrar favoritos e exibir apenas os do usuário logado.



## 7. Implementação dos Design Tokens:

```swift
enum ColorToken: String {
  case brandYellow = "#FFCB05"
  case brandBlue   = "#3B4CCA"
  case background  = "#FFFFFF"
  case textPrimary = "#1C1C1E"

  var color: Color { Color(hex: rawValue) }
}

enum FontToken {
  static let title = Font.system(size: 24, weight: .bold)
  static let body  = Font.system(size: 16)
}

enum SpacingToken: CGFloat {
  case xs = 4, sm = 8, md = 16, lg = 24
}
```

Os tokens foram declarados como `enum` para garantir *type‑safety* e autocomplete. Qualquer componente visual utiliza essas constantes — por exemplo, títulos usam `FontToken.title` e botões principais usam `ColorToken.brandBlue`. Dessa forma, mudar a identidade visual exige alterações em um único arquivo, propagando-se automaticamente pela base de código.


## 8. Implementação do item de criatividade:

#### 8.1 Paginação infinita

```swift
@MainActor
final class PokemonListViewModel: ObservableObject {
    @Published var pokemons: [ListedPokemon] = []
    private var offset = 0
    private let limit  = 20
    private var loading = false

    func loadMoreIfNeeded(current item: ListedPokemon) async {
        guard item.id == pokemons.last?.id, !loading else { return }
        loading = true
        defer { loading = false }

        offset += limit
        let new = try await api.fetchPage(offset: offset, limit: limit)
        pokemons.append(contentsOf: new)
    }
}
```

#### 8.2 Cache de sprites

```swift
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    private let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                      .appendingPathComponent("PokemonImageCache")

    func image(for id: Int) async -> UIImage? {
        if let img = cache.object(forKey: "\(id)" as NSString) { return img }

        let fileURL = folder.appendingPathComponent("\(id).png")
        if let data = try? Data(contentsOf: fileURL), let img = UIImage(data: data) {
            cache.setObject(img, forKey: "\(id)" as NSString)
            return img
        }

        let url = URL(string:"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")!
        let (data, _) = try! await URLSession.shared.data(from: url)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? data.write(to: fileURL)
        let img = UIImage(data: data)
        if let img { cache.setObject(img, forKey: "\(id)" as NSString) }
        return img
    }
}
```


## 9. Bibliotecas de terceiros utilizadas:

| Biblioteca | Uso | Licença |
|------------|-----|---------|
| Kingfisher | Cache / download de sprites | MIT |
| SwiftGen   | Geração de enums para cores e assets | MIT |
| Quick / Nimble | DSL de testes unitários | Apache-2.0 |
| SwiftLint  | Lint de código | MIT |








