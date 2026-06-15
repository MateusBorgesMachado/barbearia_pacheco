# Barbearia Sr. Pacheco 💈📲

Aplicativo móvel multiplataforma (Android/iOS) desenvolvido em **Flutter** para automação de agendamentos e gerenciamento interno da Barbearia Sr. Pacheco. O sistema conta com fluxos inteligentes para clientes e painéis administrativos para barbeiros, integrado a um banco de dados em tempo real.

## 🚀 Funcionalidades Principais

### Fluxo do Cliente
* **Cadastro Direto**: Criação de contas instantânea sem burocracia por e-mail.
* **Agendamento Inteligente**: Grade de horários dinâmica dividida de 15 em 15 minutos baseada na duração de cada serviço.
* **Bloqueio de Retroativos**: O calendário impede marcações em dias passados ou horários que já passaram no relógio atual.
* **Meus Agendamentos**: Listagem focada apenas em cortes futuros com ordenação cronológica.
* **Política de Cancelamento**: Botão interativo que permite desistências apenas com no mínimo 5 horas de antecedência.
* **Lembretes Nativos**: Disparo automático de notificações locais offline 24 horas antes do compromisso.

### Painel do Barbeiro
* **Agenda Profissional**: Visualização diária centralizada de todos os compromissos em tempo real.
* **Controle Operacional**: Cancelamento imediato de vagas de forma administrativa.
* **Faturamento & Relatórios**: Painel com faturamento bruto calculado direto no servidor e contadores de agendamentos concluídos.
* **Gerenciamento de Serviços**: Cadastro e edição de cortes com máscaras de moeda integradas.

---

## 🛠️ Tecnologias Utilizadas

* **Framework**: Flutter (Dart) com suporte avançado a layout responsivo e textScale.
* **Backend as a Service**: Supabase (Autenticação, Banco de Dados Relacional e Triggers automatizados via SQL).
* **Gerenciamento de Estado**: Bloc / Cubit para controle reativo da interface.
* **Persistência & Segurança**: Políticas RLS (Row Level Security) aplicadas para blindagem e privacidade de perfis.
* **Notificações**: Flutter Local Notifications com suporte a Java 8 coreLibraryDesugaring.

---

## 📦 Como Executar o Projeto

1. **Clonar o Repositório**:
   ```bash
   git clone https://github.com
   cd barbearia_pacheco
   ```

2. **Instalar as Dependências**:
   ```bash
   flutter pub get
   ```

3. **Executar em Modo de Desenvolvimento**:
   ```bash
   flutter run
   ```

---

Desenvolvido por **Mateus Borges** 💻🏆
