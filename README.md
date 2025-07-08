# SafeEntry - Aplicativo de Gerenciamento de Entradas Seguras

Este é o aplicativo cliente para o sistema SafeEntry, uma solução completa para gerenciamento seguro de entradas e agendamentos em condomínios, empresas ou outros locais que exigem controle de acesso. O sistema é composto por um aplicativo Flutter (este repositório) e três microsserviços Spring Boot (Auth, Visits, Gate).

## Visão Geral

O SafeEntry é projetado para otimizar o processo de entrada e saída, oferecendo funcionalidades para moradores e porteiros. Ele utiliza QR Codes para agendamentos de visitantes, permitindo um controle de acesso eficiente e seguro.

## Funcionalidades

### Para Moradores
* **Cadastro de Visitantes**: Agende visitas de forma rápida e segura, gerando QR Codes exclusivos para cada agendamento.
* **Gerenciamento de Agendamentos**: Visualize, edite e cancele agendamentos futuros.
* **QR Code Pessoal**: Cada morador possui um QR Code único para facilitar sua própria entrada.
* **Notificações**: Receba alertas sobre entradas e outras informações relevantes (integração Firebase Messaging e Firestore).
* **Histórico de Acessos**: Consulte o registro de entradas de seus visitantes.
* **Comunicação com a Portaria**: Envie mensagens e solicite apoio da portaria diretamente pelo aplicativo.

### Para Porteiros
* **Leitura de QR Code**: Utilize a câmera do dispositivo para escanear QR Codes de visitantes e registrar entradas.
* **Registro Manual de Entradas**: Opção para registrar entradas manualmente, caso a leitura do QR Code não seja possível.
* **Histórico de Entradas**: Visualize todas as entradas registradas pela portaria.
* **Painel de Controle**: Visão geral das atividades e acesso rápido às funcionalidades essenciais.

## Arquitetura

O projeto SafeEntry é uma aplicação distribuída, composta por:

* **SafeEntryApp (Este Repositório)**: Aplicativo móvel (Android, iOS) e web desenvolvido com Flutter.
* **Microsserviços Spring Boot**:
    * **Auth Service**: Gerencia a autenticação e autorização de usuários (moradores, porteiros, administradores) utilizando JWTs.
    * **Visits Service**: Responsável pelo agendamento de visitas, geração de QR Codes e gestão do status dos agendamentos. Comunica-se via Kafka para notificar o Gate Service sobre novos agendamentos.
    * **Gate Service**: Registra as entradas e saídas no local, validando QR Codes com o Visits Service. Consome eventos Kafka de agendamentos criados.

### Tecnologias Utilizadas
* **Frontend**: Flutter (Dart)
    * `dio` para requisições HTTP.
    * `shared_preferences` para armazenamento local de dados de autenticação.
    * `jwt_decoder` para decodificação de JWTs.
    * `qr_code_scanner` e `qr_flutter` para funcionalidade de QR Code.
    * `permission_handler` para gerenciamento de permissões.
    * `firebase_core`, `firebase_auth`, `firebase_messaging`, `cloud_firestore` para serviços Firebase (autenticação, mensagens e banco de dados NoSQL para notificações).
    * `json_annotation` e `build_runner`/`json_serializable` para serialização/desserialização JSON.
    * `flutter_bloc` para gerenciamento de estado.
    * `intl` para internacionalização (formatação de datas).
    * `flutter_svg` para renderização de SVGs (ex: logo).
    * `google_fonts` para fontes personalizadas.
    * `shimmer` para efeitos de carregamento.
* **Backend (Microsserviços)**: Spring Boot (Java)
    * Spring Data JPA para persistência de dados.
    * Spring Web para APIs RESTful.
    * Spring Security para segurança das APIs.
    * Apache Kafka para comunicação assíncrona entre microsserviços.
    * PostgreSQL como banco de dados.
    * JSON Web Tokens (JWT) para autenticação.
    * `WebClient` (WebFlux) para comunicação reativa entre microsserviços.

## Como Executar o Aplicativo

Para rodar o SafeEntry App, certifique-se de que os microsserviços de backend estejam em execução e configurados corretamente.

### Pré-requisitos
* Flutter SDK (versão compatível com a definida em `pubspec.yaml` - `>=3.7.0 <4.0.0`)
* Ambiente de desenvolvimento configurado para Flutter (Android Studio/Xcode para mobile, ou VS Code/IntelliJ IDEA)
* Emuladores ou dispositivos físicos configurados.
* Firebase Project configurado com Google Services (para Android) e `FirebaseOptions` atualizadas (para Web/iOS se aplicável).

### Passos de Configuração

1.  **Clone o Repositório**:
    ```bash
    git clone <URL_DO_SEU_REPOSITORIO>
    cd SafeEntry/App
    ```

2.  **Instale as Dependências**:
    ```bash
    flutter pub get
    ```

3.  **Configuração do Firebase**:
    * Certifique-se de que o arquivo `google-services.json` esteja na pasta `android/app/` para Android.
    * O arquivo `firebase_options.dart` possui placeholders (`SUA_CHAVE_WEB`, `SEU_APP_ID_WEB`, etc.). Você precisará substituí-los com as credenciais do seu projeto Firebase. Para iOS, a mensagem `iOS não está configurado. Configure no Firebase Console se necessário.` indica que você precisará configurar o iOS separadamente no console do Firebase e atualizar este arquivo.

4.  **Inicie os Microsserviços de Backend**:
    Certifique-se de que os microsserviços `Auth`, `Visits` e `Gate` estejam em execução e acessíveis nas URLs configuradas no aplicativo (e.g., `http://localhost:1012/api/auth` para Auth Service, `http://localhost:0707/api/agendamentos` para Visits Service, `http://localhost:1404/api/entradas` para Gate Service). O arquivo `docker-compose.yml` na raiz do projeto pode ser usado para subir o Zookeeper e o Kafka, que são dependências dos microsserviços.

5.  **Gere Arquivos de Serialização JSON (se houver alterações nos DTOs)**:
    Se você fizer alterações nos DTOs ou modelos anotados com `json_annotation`, execute:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

6.  **Execute o Aplicativo**:
    * **Para Web**:
        ```bash
        flutter run -d chrome
        ```
    * **Para Android**:
        ```bash
        flutter run
        ```
    * **Para iOS**:
        ```bash
        flutter run
        ```
        (Pode ser necessário abrir `ios/Runner.xcworkspace` no Xcode para configurações adicionais, como as permissões de câmera).

## Estrutura do Projeto

O projeto Flutter segue uma estrutura modular, com separação clara de responsabilidades:

```

SafeEntry/App/
├── android/              # Configurações e código nativo Android
├── ios/                  # Configurações e código nativo iOS
├── lib/
│   ├── components/       # Widgets reutilizáveis (ex: botões)
│   ├── constants/        # Constantes da aplicação (cores, etc.)
│   ├── dto/              # Data Transfer Objects para comunicação com o backend
│   ├── models/           # Modelos de dados locais do aplicativo
│   ├── screens/          # Telas da aplicação, organizadas por fluxo (auth, concierge, resident)
│   ├── services/         # Camada de serviços para interação com as APIs de backend
│   ├── widgets/          # Widgets customizados
│   └── main.dart         # Ponto de entrada da aplicação
├── linux/                # Configurações e código nativo Linux
├── macos/                # Configurações e código nativo macOS
├── web/                  # Configurações para build web
├── windows/              # Configurações e código nativo Windows
├── assets/               # Imagens e ícones
├── pubspec.yaml          # Configurações e dependências do projeto Flutter
├── README.md             # Este arquivo
└── ...


```
