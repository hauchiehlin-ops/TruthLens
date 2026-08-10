# TruthLens — Guia de Início Rápido（Português）

**Objetivo**：Completar sua primeira análise de documento em 5 minutos

---

## 1️⃣ Abra o aplicativo

### Opção A：Versão web（recomendado）
```
Navegador：https://truthlens.vercel.app
Dispositivo：Desktop, tablet ou celular
```
✅ Não requer instalação  
✅ Disponível offline após baixar modelos  
✅ 100% de privacidade garantida

### Opção B：Desenvolvimento local
```bash
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens
flutter pub get
flutter run -d web-server
# Abre em http://localhost:8765
```

---

## 2️⃣ Baixe os modelos de detecção de IA（apenas uma vez）

Ao abrir o aplicativo, um painel de configuração será exibido：

```
┌─ Instalação de modelos ─────────┐
│ Detector RoBERTa (125,8 MB)    │
│ └─ [Baixar] ✓ Instalado        │
│                                  │
│ Detector multilíngue (135 MB)  │
│ └─ [Baixar] ✓ Instalado        │
│                                  │
│ Mecanismo estatístico (82 MB)  │
│ └─ [Baixar] Opcional           │
│                                  │
│ Defesa adversarial (135 MB)    │
│ └─ [Baixar] Opcional           │
│                                  │
│ Geração de relatórios LLM (1.7 GB)│
│ └─ [Baixar] Opcional           │
└──────────────────────────────────┘
```

**⏱️ Configuração inicial**：Aproximadamente 3 minutos（depende da velocidade da internet）

**O que é baixado？**
- Modelos de detecção principais：~350 MB（obrigatório）
- LLM para melhor geração de relatórios：~1,7 GB（opcional）

**Após o download**：Todas as análises são executadas completamente offline！✅

---

## 3️⃣ Envie um arquivo ou cole texto

### Método 1：Colar texto
```
1. Clique em 「Colar texto」
2. Pressione Ctrl+V（ou Cmd+V）para colar
3. Recomendado：Mínimo 100 caracteres
```

### Método 2：Enviar arquivo
```
Formatos suportados：
• .txt（arquivo de texto）
• .docx（arquivo Word）
• .pdf（arquivo PDF com OCR）
```

### Método 3：Usar câmera（móvel）
```
1. Toque no ícone da câmera
2. Tire uma foto de seu trabalho escrito à mão
3. OCR converte automaticamente imagem → texto
```

---

## 4️⃣ Inicie a análise

Clique no botão azul **「Analisar」**

```
Status：[████░░░░░░░░░░░░] 25% analisando...
（tipicamente 2～10 segundos, dependendo do comprimento do texto）
```

---

## 5️⃣ Revise o relatório

### Seção superior：**Cartão de resumo do veredicto**
```
╔════════════════════════════════════╗
║  Veredicto：Provavelmente gerado por IA ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ║
║  Probabilidade de IA：72%           ║
║  Confiança：Alta ✓                 ║
╚════════════════════════════════════╝
```

**📌 Significado**：
- **Veredicto**：Julgamento geral（humano / provavelmente humano / misto / provavelmente IA / IA）
- **Probabilidade**：Grau de confiança na geração por IA（0～100%）
- **Confiança**：Se todos os mecanismos de detecção concordam

---

### Seção do meio：**Cartões de métricas de 3 colunas**
```
┌──────────────┬──────────────┬──────────────┐
│  Taxa IA     │ Tempo análise │  Confiança   │
│  ────────    │ ────────      │  ────────   │
│  8/45 (18%)  │  2,3 seg      │  92%        │
└──────────────┴──────────────┴──────────────┘
```

**📌 Significado**：
- **Taxa IA**：Quantas frases foram marcadas como IA（8 de 45）
- **Tempo análise**：Tempo de varredura
- **Confiança**：Confiabilidade do resultado geral

---

### Seção inferior：**Lista de frases suspeitas**
```
【Frase #1】（página 3）Risco：Alto 🔴 | Confiança 85%
  "A mudança de paradigma sinérgica permite..."
  Motivo：Similaridade alta, complexidade vocabular incomum, padrão rítmico

【Frase #2】（página 5）Risco：Médio 🟡 | Confiança 72%
  "Algoritmos de aprendizado de máquina iniciaram a revolução..."
  Motivo：Desvio estatístico, baixa diversidade vocabular
```

**📌 Como ler**：
- **Número da página**：Posição no documento
- **Cor de risco**：Vermelho（risco alto）, amarelo（risco médio）, azul（risco baixo）
- **Percentual IA**：Probabilidade de ser IA（0～100%）
- **Motivo**：Por que o modelo marcou essa frase

---

## 6️⃣ Interprete os resultados（Para professores）

### Cenário A：Probabilidade geral de IA > 80%
```
⚠️ Evidência forte de uso de IA
→ Ação：Examine de perto as frases suspeitas
→ Próximo：Converse com o aluno sobre se a política permite IA
```

### Cenário B：Probabilidade de IA 50～80%
```
🤔 Sinais mistos; alguns parágrafos são suspeitos
→ Ação：Concentre-se nas frases marcadas em vermelho
→ Próximo：Verifique se correspondem ao estilo típico do aluno
```

### Cenário C：Probabilidade de IA < 30%
```
✅ Parece ser trabalho autêntico do aluno
→ Ação：Considere aprovar ou revise algumas frases
→ Nota：Textos humanos também podem ter falsos positivos
```

---

## 7️⃣ Baixe e compartilhe resultados

### Opções de exportação
```
1. [📄 Baixar PDF]       → Relatório completo com todos os detalhes
2. [📊 Exportar CSV]     → Para planilha de avaliação
3. [📋 Copiar resultados]→ Para colar em email/LMS
```

**O PDF inclui**：
- Resumo do veredicto
- Métricas detalhadas
- Todas as frases suspeitas e motivos
- Números de página para fácil referência

---

## ⚙️ Personalize as configurações（opcional）

Painel direito：Clique em **⚙️ ícone de engrenagem**

| Configuração | Padrão | Função |
|-----------|--------|--------|
| Baixar modelos | Automático | Rebaixa modelos de detecção |
| Verificar links | Ativado | Verifica se URLs realmente existem |
| Validar DOI | Ativado | Verifica se as citações existem（Crossref） |
| Idioma | Automático | Alterna idioma da interface（14 suportados） |
| Política de privacidade | — | Leia a garantia 「zero envio」 |

---

## 🆘 Problemas comuns e soluções

### Problema：「Falha no download do modelo」
```
❌ Erro：Não é possível baixar modelo RoBERTa
✅ Solução：
  1. Verifique conexão com internet
  2. Desative VPN/proxy
  3. Aguarde 5 minutos e tente novamente
  4. Limpe cache do navegador（Ctrl+Shift+Del）
```

### Problema：「A análise é muito lenta」
```
❌ Você aguarda mais de 30 segundos
✅ Solução：
  1. Primeira execução é lenta（carregando modelos em RAM）
  2. Execuções subsequentes levam 2～5 segundos
  3. Feche outras abas do navegador
  4. Reinicie o navegador se continuar lento
```

### Problema：「Navegador diz 'memória insuficiente'」
```
❌ Erro：Não é possível alocar memória
✅ Solução：
  1. Mínimo 2 GB de RAM livre necessário
  2. Feche outros aplicativos
  3. Recarregue página（Cmd/Ctrl + R）
  4. Tente em computador desktop
```

---

## ✅ Próximos passos

### Para professores
1. ✅ Baixe os modelos
2. ✅ Teste com 1～2 documentos de exemplo
3. ✅ Familiarize-se com formato do relatório
4. ✅ Crie rubrica de avaliação baseada em pontuações de detecção IA
5. ✅ Distribua diretrizes de classe

### Para administradores escolares
1. ✅ Implante em servidor escolar（opcional, para uso offline）
2. ✅ Crie manual para professores
3. ✅ Treine pessoal no uso da ferramenta
4. ✅ Estabeleça política de integridade acadêmica com detecção IA

### Para desenvolvedores
1. ✅ Ver [CLAUDE.md](../CLAUDE.md) para configuração
2. ✅ Ver [docs/implementation_plan.md](./implementation_plan.md) para arquitetura
3. ✅ Ver [docs/model_integration_testing.md](./model_integration_testing.md) para detalhes do modelo

---

## 📚 Recursos adicionais

| Recurso | Propósito |
|---------|----------|
| [Documentação completa](./implementation_plan.md) | Aprofunde em todos os recursos |
| [Política de privacidade](https://truthlens.vercel.app/#/privacy) | Verifique como protegemos dados |
| [Lista de modelos](./model_integration_testing.md) | Detalhes técnicos de cada modelo IA |
| [Perguntas frequentes](./faq-pt.md) | Respostas a perguntas comuns |
| [Solução de problemas](./troubleshooting-pt.md) | Métodos de solução mais detalhados |

---

## 💬 Tem dúvidas ou comentários？

- **Encontrou um bug？** → [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Solicitação de recurso？** → [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **Outras dúvidas？** → hauchieh.lin@gmail.com

---

**Pronto para analisar？** → [Abra TruthLens agora！](https://truthlens.vercel.app)
