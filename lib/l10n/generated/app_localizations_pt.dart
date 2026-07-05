// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonClose => 'Fechar';

  @override
  String get verdictHuman => 'Escrito por humano';

  @override
  String get verdictLikelyHuman => 'Provavelmente humano';

  @override
  String get verdictMixed => 'Conteúdo misto';

  @override
  String get verdictLikelyAi => 'Provavelmente IA';

  @override
  String get verdictAi => 'Gerado por IA';

  @override
  String get inputSubtitle =>
      'Cole ou digite texto para detectar conteúdo gerado por IA';

  @override
  String get inputHint => 'Digite ou cole o texto para analisar…';

  @override
  String get inputHistoryTooltip => 'Histórico';

  @override
  String get inputHelpTooltip => 'Guia do usuário';

  @override
  String get inputPrivacyTooltip => 'Política de privacidade';

  @override
  String get inputSettingsTooltip => 'Configurações';

  @override
  String get inputPasteButton => 'Colar';

  @override
  String get inputOcrButton => 'OCR de imagem';

  @override
  String get inputImportButton => 'Importar arquivo';

  @override
  String get inputStartButton => 'Iniciar detecção';

  @override
  String get inputClearTooltip => 'Limpar conteúdo';

  @override
  String get inputTooShortSnackbar =>
      'Insira pelo menos 40 caracteres para uma análise confiável';

  @override
  String get inputOcrUnsupported =>
      'O reconhecimento de texto OCR não é compatível com esta plataforma';

  @override
  String get inputOcrRecognizing => 'Reconhecendo…';

  @override
  String get inputOcrNoText => 'Nenhum texto identificado na imagem';

  @override
  String inputOcrRecognized(int count) {
    return '$count caracteres reconhecidos com sucesso';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" não contém conteúdo de texto legível';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\" importado ($count caracteres)';
  }

  @override
  String inputActiveModel(String modelId) {
    return 'Modelo: $modelId';
  }

  @override
  String get inputNoModel =>
      'Nenhum modelo instalado (apenas análise estatística/estilométrica)';

  @override
  String inputCharCount(int count) {
    return '$count caracteres';
  }

  @override
  String get analysisAppBarTitle => 'Analisando';

  @override
  String get analysisEngineTransformer => 'Classificador Transformer';

  @override
  String get analysisEngineStatistical => 'Análise estatística';

  @override
  String get analysisEngineStylometry => 'Análise estilométrica';

  @override
  String get analysisEngineAdversarial => 'Defesa adversarial';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Análise em andamento, $done de $total mecanismos concluídos';
  }

  @override
  String get analysisDoneSemantics => 'Concluído';

  @override
  String get engineNameAdversarialFull =>
      'Defesa adversarial (detecção de paráfrase)';

  @override
  String get modelNecessityText =>
      'Sem baixar o modelo de detecção de rede neural, o TruthLens continua funcionando, mas usa apenas análise estatística e estilométrica, com precisão e suporte multilíngue limitados. Após o download do modelo, o classificador Transformer multilíngue passará a participar da votação em conjunto, melhorando significativamente a precisão e a confiabilidade. O modelo é executado no dispositivo; após o download, ele não envia nenhum conteúdo.';

  @override
  String get modelPromptTitle =>
      'Recomenda-se baixar o modelo de detecção para uma análise completa';

  @override
  String get modelPromptDontRemind => 'Não lembrar novamente';

  @override
  String get modelPromptSkip => 'Pular por enquanto';

  @override
  String get modelPromptDownload => 'Baixar agora';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao TruthLens';

  @override
  String get onboardingHeadline => 'Detecção de conteúdo de IA no dispositivo';

  @override
  String get onboardingDetectedDevice => 'Dispositivo detectado';

  @override
  String get onboardingChooseModel => 'Escolha um modelo para baixar';

  @override
  String get onboardingRecommendHint =>
      '\"Recomendado\" é marcado com base no seu hardware; você também pode escolher outra opção.';

  @override
  String get onboardingSkipButton =>
      'Decidir mais tarde (usar análise estatística/estilométrica sem modelo)';

  @override
  String get onboardingSkipHint =>
      'Você sempre pode baixar a qualquer momento em \"Configurações → Gerenciamento de modelos de IA\"; você será lembrado novamente ao usar análises que exijam um modelo.';

  @override
  String get modelListCustomImportedLabel => 'Modelo personalizado importado:';

  @override
  String get modelListActiveChip => 'Em uso';

  @override
  String get modelListRecommendedChip => 'Recomendado';

  @override
  String get modelListCustomChip => 'Personalizado';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · Requer ${ram}GB de RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Tamanho: $size · Tokenizador: $tokenizer · Índice de rótulo de IA: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Baixando… $percent% ($downloaded / $total)';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Baixar ($size)';
  }

  @override
  String get modelListComingSoonChip => 'Em breve';

  @override
  String get modelListSetActiveButton => 'Definir como ativo';

  @override
  String get modelListUpdateButton => 'Atualizar';

  @override
  String get modelListDeleteTooltip => 'Excluir';

  @override
  String get modelListPageButton => 'Página do modelo';

  @override
  String get modelListMayExceedMemory =>
      'Pode exceder a memória do dispositivo';

  @override
  String modelListFailedPrefix(String error) {
    return 'Falha: $error';
  }

  @override
  String get modelListDeleteConfirmTitle => 'Excluir o modelo?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'Isso excluirá \"$name\" ($size). Você precisará baixá-lo novamente para usá-lo de novo.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'Isso excluirá o modelo personalizado importado \"$name\" ($size). Você precisará importá-lo novamente para usá-lo de novo.';
  }

  @override
  String get modelImportAppBarTitle => 'Importar modelo ONNX personalizado';

  @override
  String get modelImportStep1Title => '1. Selecione o arquivo do modelo ONNX';

  @override
  String modelImportSelectedFile(String name) {
    return 'Selecionado: $name';
  }

  @override
  String get modelImportNoFileSelected =>
      'Nenhum arquivo de modelo selecionado (.onnx)';

  @override
  String get modelImportBrowseButton => 'Procurar';

  @override
  String get modelImportCheckingDuplicate =>
      'Verificando se um arquivo idêntico já foi importado…';

  @override
  String get modelImportDuplicateTitle =>
      'Modelo com conteúdo idêntico já foi importado';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'Este arquivo tem conteúdo totalmente idêntico a \"$name\" (função: $role). Se você só deseja trocar o modelo ativo, vá para \"Gerenciamento de modelos de IA\" e defina-o diretamente como ativo — não é necessário reimportar. Você ainda pode continuar com as etapas abaixo.';
  }

  @override
  String get modelImportStep2Title => '2. Configuração';

  @override
  String get modelImportNameLabel => 'Nome de exibição do modelo';

  @override
  String get modelImportNameRequired => 'O nome não pode estar vazio';

  @override
  String get modelImportRoleLabel => 'Função do mecanismo de destino';

  @override
  String get modelImportTokenizerTypeLabel => 'Tipo de tokenizador';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone =>
      'Nenhum (sem tokenizador/nível de caractere)';

  @override
  String get modelImportNoTokenizerSelected =>
      'Nenhum arquivo de tokenizador selecionado (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Selecionado: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'Índice de saída do rótulo de IA';

  @override
  String get modelImportIndex0 => 'Índice 0 (ex.: RoBERTa)';

  @override
  String get modelImportIndex1 => 'Índice 1 (ex.: DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Testar e verificar';

  @override
  String get modelImportTestInputLabel => 'Texto de entrada de teste';

  @override
  String get modelImportRunTestButton => 'Executar inferência de teste';

  @override
  String get modelImportResultLabel =>
      'Resultado da inferência (probabilidade de IA):';

  @override
  String modelImportTestFailed(String error) {
    return 'Falha no teste: $error';
  }

  @override
  String get modelImportConfirmButton => 'Confirmar importação e ativar modelo';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Selecione primeiro um arquivo de tokenizador';

  @override
  String get modelImportSelectTokenizer =>
      'Selecione um arquivo de tokenizador';

  @override
  String get modelImportSuccessSnackbar =>
      'Modelo importado com sucesso! Definido automaticamente como modelo ativo.';

  @override
  String get modelImportFailedSnackbar =>
      'Falha ao importar o modelo. Verifique as permissões ou os registros';

  @override
  String get settingsAppBarTitle => 'Configurações';

  @override
  String get settingsThresholdTitle =>
      'Limite de confiança para determinação de IA';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Atual: $percent% — aumentá-lo reduz falsos positivos (texto humano classificado incorretamente como IA)';
  }

  @override
  String get settingsEslTitle => 'Correção de viés ESL (não nativo)';

  @override
  String get settingsEslSubtitle =>
      'Reduz automaticamente o peso do modelo estatístico ao detectar estilo de escrita de não nativo';

  @override
  String get settingsEngineSectionTitle =>
      'Configurações de submecanismos de detecção (Ensemble)';

  @override
  String get settingsEngineTransformerTitle =>
      'Classificador de IA multilíngue (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Usa um modelo de rede neural Transformer para prever a probabilidade de IA no dispositivo';

  @override
  String get settingsEngineStatisticalTitle =>
      'Mecanismo de análise estatística (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Determina a regularidade da linguagem por meio da variação do comprimento das frases, Burstiness e PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'Análise estilométrica (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Analisa a fluência semântica, padrões de frases repetitivos e o uso de conectivos';

  @override
  String get settingsEngineAdversarialTitle =>
      'Detecção de paráfrase adversarial (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Detecta se o texto foi parafraseado por máquina ou processado para remover vestígios de IA';

  @override
  String get settingsLinkVerificationTitle =>
      'Verificação de hiperlinks e bibliografia';

  @override
  String get settingsLinkVerificationSubtitle =>
      'O relatório se conectará para verificar se as URLs e entradas bibliográficas detectadas no documento realmente existem (conteúdo gerado por IA geralmente inclui referências plausíveis, mas fictícias). Links acadêmicos no formato DOI, e referências no formato \"autor-ano\" sem link, são ambos verificados no registro público da Crossref. O modelo de detecção de IA principal continua funcionando totalmente no dispositivo e nunca envia o conteúdo do documento; a conexão é usada apenas para essa verificação e verificações de atualização do modelo, e pode ser desativada aqui.';

  @override
  String get settingsThemeTitle => 'Tema de exibição';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle =>
      'Escolha o idioma de exibição do aplicativo';

  @override
  String get settingsModelManagementTitle => 'Gerenciamento de modelos de IA';

  @override
  String get settingsModelManagementSubtitle =>
      'Baixe modelos de detecção e o LLM de redação de relatórios para habilitar a capacidade de inferência completa';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'Atualização de modelo detectada — recomenda-se verificar';

  @override
  String get settingsOpenButton => 'Abrir';

  @override
  String get settingsCustomImportTitle =>
      'Importar e testar modelo ONNX personalizado';

  @override
  String get settingsCustomImportSubtitle =>
      'Importe um modelo ONNX personalizado local, configure o tokenizador e execute um teste de inferência';

  @override
  String get settingsLanguagePackTitle => 'Pacote de idiomas';

  @override
  String get settingsLanguagePackSubtitle =>
      'Modelo de ajuste de idioma adicional (disponível na fase 4)';

  @override
  String get settingsModelManagerAppBarTitle =>
      'Gerenciamento de modelos de IA';

  @override
  String get settingsImportTooltip => 'Importar modelo ONNX local';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Dispositivo: $summary';
  }

  @override
  String get historyAppBarTitle => 'Histórico';

  @override
  String get historyClearAllTooltip => 'Limpar tudo';

  @override
  String get historySearchHint => 'Pesquisar no histórico…';

  @override
  String get historyDeletedSnackbar => 'Entrada excluída';

  @override
  String get historyClearAllTitle => 'Limpar todo o histórico?';

  @override
  String historyClearAllBody(int count) {
    return 'Isso excluirá todas as $count entradas. Esta ação não pode ser desfeita.';
  }

  @override
  String get historyClearButton => 'Limpar';

  @override
  String get historyDeleteEntryTitle => 'Excluir esta entrada?';

  @override
  String get historyReanalyzeTooltip => 'Reanalisar';

  @override
  String get historyEmptyDefault => 'Ainda não há histórico de detecção';

  @override
  String historyEmptySearch(String query) {
    return 'Nenhuma entrada corresponde a \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, probabilidade de IA $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Relatório de detecção';

  @override
  String get reportExportTooltip => 'Exportar relatório';

  @override
  String get reportHomeTooltip => 'Voltar ao início';

  @override
  String get reportGeneratingTitle => 'Gerando relatório…';

  @override
  String get reportSourceLlm => 'Relatório gerado por IA';

  @override
  String get reportSourceTemplate => 'Relatório gerado por modelo';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total frases · $ai provavelmente IA · $human provavelmente humano · $seconds s decorridos';
  }

  @override
  String get reportExportPdf => 'Exportar relatório em PDF';

  @override
  String get reportExportCsv => 'Exportar dados em CSV';

  @override
  String get reportExportJson => 'Exportar em JSON (integração de sistemas)';

  @override
  String get reportExportPng => 'Exportar cartão de resumo (PNG)';

  @override
  String reportExported(String path) {
    return 'Exportado: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String get reportEngineBreakdownTitle => 'Detalhamento por mecanismo';

  @override
  String get reportEngineNotInstalled => 'Não instalado';

  @override
  String get reportSentenceAnalysisTitle => 'Análise em nível de frase';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text. Probabilidade de IA $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Autenticidade de hiperlinks';

  @override
  String get reportLinkNoneDetected =>
      'Nenhum hiperlink detectado neste documento.';

  @override
  String get reportLinkCheckingProgress => 'Verificando links…';

  @override
  String reportLinkDetectedPending(int count) {
    return '$count hiperlinks detectados; ainda não verificados';
  }

  @override
  String get reportLinkDisabledHint =>
      'O conteúdo gerado por IA geralmente inclui links de referência plausíveis, mas fictícios. Você desativou a verificação de hiperlinks nas Configurações; você pode reativá-la para verificação automática, ou tocar abaixo para uma verificação única.';

  @override
  String get reportVerifyNowButton => 'Verificar agora (requer rede)';

  @override
  String get reportLinkReachable => 'Acessível — a URL existe';

  @override
  String get reportLinkNotFound =>
      'A URL não existe (404) — possível referência fictícia';

  @override
  String get reportLinkUnreachable =>
      'Não foi possível verificar (tempo esgotado ou sem resposta do servidor)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Verificado no registro de periódicos: registrado em $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'Nenhum registro de DOI correspondente encontrado — possível referência fictícia';

  @override
  String get reportLinkCitationUnreachable =>
      'Não foi possível verificar (tempo esgotado ou sem resposta da Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Apenas os primeiros $max links foram verificados (total de $count detectados)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Autenticidade das citações';

  @override
  String get reportBibNoneDetected =>
      'Nenhuma entrada bibliográfica detectada neste documento.';

  @override
  String get reportBibCheckingProgress => 'Verificando bibliografia…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Bibliografia detectada ($count entradas); ainda não verificada';
  }

  @override
  String get reportBibDisabledHint =>
      'O conteúdo gerado por IA geralmente inclui referências plausíveis, mas fictícias. Você desativou a verificação de hiperlinks nas Configurações; você pode reativá-la para verificação automática, ou tocar abaixo para uma verificação única.';

  @override
  String get reportVerifyNowBibButton => 'Verificar agora (requer rede)';

  @override
  String get reportBibResultHint =>
      'Comparado com o registro público da Crossref por similaridade de autor, ano e título. Não é uma garantia absoluta — quando \"incerto\", verifique manualmente.';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Alta confiança: provavelmente existe$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (registrado em $journal)';
  }

  @override
  String get reportBibNotFound =>
      'Nenhuma correspondência próxima encontrada — possível referência fictícia';

  @override
  String get reportBibUncertain =>
      'Similaridade moderada ou falha na conexão — incerto, verifique manualmente';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Apenas as primeiras $max entradas foram verificadas (total de $count detectadas)';
  }

  @override
  String get reportNetworkWarningTitle => 'Conexão de rede fraca';

  @override
  String get reportNetworkWarningBody =>
      'Este aplicativo assume por padrão que há conexão de rede disponível; a análise de autenticidade de hiperlinks e citações requer acesso à rede para produzir resultados. Não foi possível estabelecer conexão — verifique sua rede e tente novamente.';

  @override
  String get reportRetryConnectionButton => 'Tentar conexão novamente';

  @override
  String get reportAiProbabilityLabel => 'Probabilidade de IA';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total frases\n$ai provavelmente IA\n$human provavelmente humano';
  }

  @override
  String get summaryCardFooter =>
      'A inferência de IA principal é executada totalmente no dispositivo';

  @override
  String get exportReportTitle => 'Relatório de detecção TruthLens';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Página $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Analisado: $datetime · $seconds s decorridos';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Veredito geral: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (correção ESL aplicada)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total frases · $ai provavelmente IA · $human provavelmente humano';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'Para preservar a legibilidade do PDF, apenas as primeiras $max frases são exibidas (de um total de $count); para dados completos de cada frase, use \"$csvLabel\" ou \"$jsonLabel\" em vez disso.';
  }

  @override
  String get pdfSentenceColumnHeader => 'Frase (com padrões correspondentes)';

  @override
  String composerHeadlineAi(int percent) {
    return 'Este texto foi muito provavelmente gerado por IA (probabilidade de IA $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'Este texto tende a ser gerado por IA; recomenda-se uma análise adicional (probabilidade de IA $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'Este texto apresenta características mistas de humano e IA (probabilidade de IA $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'Este texto tende a ter sido escrito por um humano (probabilidade de IA $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'Este texto foi muito provavelmente escrito por um humano (probabilidade de IA $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'A probabilidade geral de IA excede o limite de $percent% que você definiu e foi sinalizada como IA.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'A probabilidade geral de IA está abaixo do limite de sinalização de $percent% que você definiu.';
  }

  @override
  String get composerNarrativeTitle => 'Interpretação da análise';

  @override
  String get composerParaphraseTitle => 'Vestígios de paráfrase detectados';

  @override
  String get composerParaphraseBody =>
      'Este texto pode ter sido processado por uma ferramenta de paráfrase (ex.: QuillBot, Undetectable.ai) para evitar a detecção. Embora pareça natural frase por frase, sua impressão estatística geral ainda é diferente da escrita humana genuína — preste atenção especial a isso.';

  @override
  String get composerPatternListTitle => 'Principais padrões de escrita de IA';

  @override
  String get composerEslTitle => 'Correção de viés ESL (não nativo)';

  @override
  String get composerEslBody =>
      'Este texto pode ser de um escritor não nativo. Baixa perplexidade e padrões de frases regulares comuns entre escritores não nativos não são, por si só, um sinal de IA, portanto o sistema reduziu o peso do modelo estatístico para evitar uma avaliação incorreta.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'Este texto tem $total frases no total, das quais $ai apresentam fortes características de IA e $human tendem a ter sido escritas por um humano.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'A maioria das frases é muito regular em ritmo, escolha de palavras e uso de conectivos — uma impressão comum de texto gerado por IA.';

  @override
  String get composerNarrativeMixedPattern =>
      'O texto contém partes tanto regulares quanto naturalmente variadas, sugerindo um rascunho humano polido por IA, ou uma colaboração humano-IA.';

  @override
  String get composerNarrativeHumanPattern =>
      'O comprimento das frases e a escolha das palavras mostram variação natural e estilo pessoal, sem sinais claros de regularidade de IA.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Baixa perplexidade do modelo de linguagem ($ppl) — o texto é muito previsível, um indicador de geração por IA';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'Alta perplexidade do modelo de linguagem ($ppl), consistente com a natureza imprevisível da escrita humana';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Perplexidade moderada do modelo de linguagem ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Comprimento de frase muito uniforme (burstiness $value) — um ritmo constante é uma impressão estatística comum de texto gerado por IA';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Variação notável no comprimento das frases (burstiness $value), consistente com o ritmo natural da escrita humana';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Baixa diversidade de vocabulário (TTR $value) — alta repetição de palavras';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'Alta diversidade de vocabulário (TTR $value)';
  }

  @override
  String get engineReasonNeutral =>
      'Os indicadores estatísticos não mostram uma tendência clara — veredito neutro mantido';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Uso frequente de conectivos genéricos ($words), média de $density por frase — uma densidade rara na escrita humana';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Várias frases consecutivas começam com a mesma palavra ($count vezes) — estrutura de frase repetitiva';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'Nenhum padrão de escrita de IA notável detectado';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'O modelo de detecção de paráfrase não está instalado; não participou desta votação';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Nenhum modelo instalado ou o modelo ativo não é compatível; não participou desta votação';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'Falha ao carregar o modelo, não participou desta votação ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model avaliou que $aiCount de $total frases apresentam características de IA';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'O modelo adversarial detectou possíveis vestígios de IA removidos por uma ferramenta de paráfrase (ex.: QuillBot / Undetectable.ai)';

  @override
  String get engineReasonAdversarialClean =>
      'Nenhum vestígio claro de evasão por paráfrase detectado';

  @override
  String get engineReasonDisabledByUser =>
      'O usuário desativou este mecanismo nas Configurações';

  @override
  String get engineReasonGenericNotInstalled =>
      'Modelo não instalado; não participou desta votação';

  @override
  String patternGenericTransition(String word) {
    return 'conectivo genérico \"$word\"';
  }

  @override
  String get helpAppBarTitle => 'Guia do usuário';

  @override
  String get helpAboutTitle => 'Sobre o TruthLens';

  @override
  String get helpAboutBody =>
      'O TruthLens é um aplicativo de detecção de conteúdo multiplataforma (iOS / Android / macOS / Windows) cuja inferência de IA principal é executada totalmente no dispositivo. Quatro submodelos independentes — o classificador neural Transformer, a análise estatística, a análise estilométrica e a detecção de paráfrase adversarial — votam juntos para determinar se o texto foi gerado por IA, com razões explicáveis frase por frase: não apenas uma porcentagem de \"parece IA\", mas uma explicação do \"porquê\".';

  @override
  String get helpComparisonTitle => 'Comparação com ferramentas líderes';

  @override
  String get helpComparisonDisclaimer =>
      'Esta comparação foi compilada a partir de informações públicas de cada ferramenta e percepções gerais de mercado, apenas para referência de posicionamento funcional — não são dados de referência verificados por terceiros.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'O processamento do GPTZero é executado principalmente na nuvem e requer o upload do seu documento; os quatro mecanismos de detecção do TruthLens são executados no dispositivo.';

  @override
  String get helpVsGptZero2 =>
      'O GPTZero foi pioneiro nas métricas de Perplexity/Burstiness e no destaque de frases — o TruthLens as combina e adiciona um classificador Transformer, análise estilométrica e defesa adversarial, formando uma votação em conjunto de quatro modelos em vez de uma única métrica.';

  @override
  String get helpVsGptZero3 =>
      'O GPTZero é baseado em assinatura; o TruthLens não requer assinatura e não tem limites de uso.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'O Turnitin é vendido apenas para instituições; indivíduos não podem comprá-lo diretamente. Qualquer pessoa pode instalar e usar o TruthLens.';

  @override
  String get helpVsTurnitin2 =>
      'O processo de decisão do Turnitin é quase uma caixa preta; o TruthLens fornece a probabilidade de IA de cada frase, padrões de escrita correspondentes, e o detalhamento de pontuação e razões de cada mecanismo.';

  @override
  String get helpVsTurnitin3 =>
      'O Turnitin fornece principalmente um resultado binário de \"é IA\"; o TruthLens suporta rotulagem de humano/IA/misto no nível de parágrafo/frase.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'O Originality.ai é uma assinatura por documento que requer o upload do seu documento para a nuvem; o processamento principal do TruthLens é executado no dispositivo sem exigir assinatura contínua para detecção.';

  @override
  String get helpVsOriginality2 =>
      'O Originality.ai oferece conceitos de verificação de fatos e análise de legibilidade; o TruthLens responde a isso com um módulo de características de estilo no dispositivo, e pode realizar análises básicas mesmo offline.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'O Copyleaks é principalmente uma API em nuvem conhecida por sua baixa taxa de falsos positivos e forte suporte multilíngue; o TruthLens compartilha essa filosofia com um modelo base multilíngue XLM-RoBERTa e votação em conjunto de múltiplos modelos, mas o conteúdo do seu documento nunca é enviado a nenhum servidor.';

  @override
  String get helpVsCopyleaks2 =>
      'O Copyleaks tem limites de uso de API dependendo do plano; o TruthLens não tem limites de uso.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'O reconhecimento de imagem OCR do Winston AI requer o upload de imagens para a nuvem; o TruthLens usa frameworks nativos de cada plataforma (Vision no iOS/macOS, ML Kit no Android, Windows.Media.Ocr no Windows) para reconhecer texto no dispositivo.';

  @override
  String get helpVsWinston2 =>
      'O Winston AI é conhecido por relatórios organizados e imprimíveis; o TruthLens gera dinamicamente o layout do relatório por IA (retornando a um modelo se nenhum LLM estiver instalado), exportável como PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'Vantagens exclusivas do TruthLens';

  @override
  String get helpAdvantage1 =>
      'Verificação de autenticidade de hiperlinks: verifica automaticamente se as URLs encontradas no documento são realmente acessíveis; links acadêmicos no formato DOI são adicionalmente verificados no registro público da Crossref para confirmar se o periódico realmente indexa a obra.';

  @override
  String get helpAdvantage2 =>
      'Verificação de autenticidade de citações: mesmo referências sem qualquer hiperlink (o estilo comum \"autor-ano\") podem ser verificadas em registros bibliográficos para detectar citações possivelmente fictícias — um sinal comum de alucinação de IA.';

  @override
  String get helpAdvantage3 =>
      'Correção de viés ESL (não nativo): detecta automaticamente características de escrita de não nativos e reduz o peso do modelo estatístico, evitando classificar incorretamente a escrita natural de não nativos como IA.';

  @override
  String get helpAdvantage4 =>
      'Importação de modelos personalizados: usuários avançados podem importar seus próprios modelos ONNX locais para substituir ou complementar os mecanismos de detecção integrados.';

  @override
  String get helpWorkflowTitle => 'Fluxo de trabalho operacional completo';

  @override
  String get helpWorkflowStep1Title => 'Baixar e atualizar modelos';

  @override
  String get helpWorkflowStep1Body =>
      'O primeiro lançamento o orienta a instalar o modelo de detecção principal; depois disso, você sempre pode verificar, baixar, atualizar ou remover modelos em \"Configurações → Gerenciamento de modelos de IA\". O aplicativo verifica proativamente as versões mais recentes no lançamento e mostra um selo no ícone de configurações e na entrada \"Gerenciamento de modelos de IA\" se houver uma atualização disponível.';

  @override
  String get helpWorkflowStep2Title =>
      'Escolhendo modelos (propósito e impacto)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Classificador de IA multilíngue (peso 40%): o principal impulsionador do veredito geral, com previsão de probabilidade de IA no nível da frase — melhora mais a precisão.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Mecanismo de análise estatística (peso 25%): análise de janela deslizante de perplexidade e burstiness, capturando o ritmo regular e a escolha de palavras previsível do texto de IA.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Análise estilométrica (peso 20%): fluência semântica, padrões de frases repetitivos, uso de conectivos — a mais explicável, mais fácil de entender o \"porquê\".';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Defesa adversarial (peso 15%): detecta texto que foi \"limpo\" por meio de ferramentas de paráfrase (ex.: QuillBot, Undetectable.ai).';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'LLM de redação de relatórios (opcional): uma vez instalado, o texto do relatório é redigido dinamicamente por um LLM no dispositivo; sem ele, o aplicativo recorre a um modelo fixo — a análise em si não é afetada.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'Você pode ativar/desativar mecanismos individualmente e ajustar o limite de confiança de detecção de IA nas Configurações (aumentá-lo reduz a probabilidade de classificar incorretamente a escrita humana como IA).';

  @override
  String get helpWorkflowStep3Title => 'Enviando um documento';

  @override
  String get helpWorkflowStep3Body =>
      'Três métodos de entrada: colar texto diretamente, OCR de imagem (reconhecido no dispositivo com frameworks nativos de cada plataforma), ou importar arquivo (txt / md / pdf / docx / doc). O texto deve ter pelo menos 40 caracteres para ser enviado para análise.';

  @override
  String get helpWorkflowStep4Title => 'Executando a análise';

  @override
  String get helpWorkflowStep4Body =>
      'Toque em \"Iniciar detecção\" e os quatro mecanismos são executados em paralelo, com o progresso exibido ao vivo na tela. Se características de escrita de não nativo forem detectadas, a correção de viés ESL é aplicada automaticamente (pode ser desativada nas Configurações).';

  @override
  String get helpWorkflowStep5Title => 'Visualizando e exportando resultados';

  @override
  String get helpWorkflowStep5Body =>
      'A página do relatório inclui: o indicador geral de probabilidade de IA, o mapa de calor no nível da frase, o detalhamento de pontuação e razões de cada mecanismo, autenticidade de hiperlinks, e autenticidade de citações. Você pode exportar o relatório completo em PDF, dados por frase em CSV, JSON (para integração de sistemas), ou um cartão de resumo em PNG (para compartilhamento). Cada análise é automaticamente salva no \"Histórico\" para revisão posterior.';

  @override
  String get helpTuningTitle =>
      'Guia para baixar e ajustar modelos (nenhuma experiência necessária)';

  @override
  String get helpTuningStep1Title => 'Abrir o gerenciamento de modelos';

  @override
  String get helpTuningStep1Body =>
      'Na tela principal, toque no ícone de engrenagem para abrir \"Configurações\", depois toque em \"Abrir\" ao lado de \"Gerenciamento de modelos de IA\".';

  @override
  String get helpTuningStep2Title => 'Escolha um modelo para o seu dispositivo';

  @override
  String get helpTuningStep2Body =>
      'A tela sugere automaticamente o nível de modelo apropriado com base nas capacidades do seu dispositivo (RAM, núcleos de CPU), e lista cada variante disponível para cada função (classificador multilíngue / análise estatística / defesa adversarial / LLM de relatório).';

  @override
  String get helpTuningStep3Title => 'Baixar e usar';

  @override
  String get helpTuningStep3Body =>
      'Toque em \"Baixar\" ao lado do modelo desejado e aguarde a conclusão — o primeiro modelo que você baixar será automaticamente definido como ativo. Se você tiver várias variantes instaladas, toque em \"Definir como ativo\" para alternar a qualquer momento; toque no ícone de lixeira para remover modelos desnecessários e liberar espaço.';

  @override
  String get helpTuningStep4Title => 'Atualizando modelos';

  @override
  String get helpTuningStep4Body =>
      'Quando uma nova versão estiver disponível, \"Gerenciamento de modelos de IA\" e o ícone de engrenagem das configurações mostrarão um selo — volte para esta tela para ver e baixar a atualização (versões instaladas anteriormente são mantidas, a menos que você as remova manualmente).';

  @override
  String get helpTuningStep5Title =>
      'Avançado: importando modelos personalizados';

  @override
  String get helpTuningStep5Body =>
      'Se você já tem, ou ajustou, um modelo .onnx compatível em outro lugar, você pode importá-lo por meio de \"Configurações → Importar e testar modelo ONNX personalizado\" — você precisará fornecer o arquivo do modelo, a configuração correspondente do tokenizador (ou escolher \"nenhum\"), e o índice de classe de IA. Antes de importar, o aplicativo verifica automaticamente se este mesmo arquivo já foi importado, para evitar duplicações acidentais.';

  @override
  String get helpOfficialLinksTitle => 'Links oficiais de download de modelos';

  @override
  String get helpOfficialLinksHint =>
      'Tocar em um item abrirá a página oficial daquele modelo no seu navegador do sistema.';

  @override
  String get helpLinkRoleTransformer =>
      'Classificador de IA multilíngue (Transformer, peso 40%)';

  @override
  String get helpLinkRoleStatistical =>
      'Modelo estatístico de perplexidade (Statistical, peso 25%)';

  @override
  String get helpLinkRoleAdversarial =>
      'Modelo de detecção de paráfrase adversarial (Adversarial, peso 15%)';

  @override
  String get helpLinkRoleLlm => 'LLM de redação de relatórios (opcional)';

  @override
  String get privacyAppBarTitle => 'Política de privacidade';

  @override
  String privacyPlatformTitle(String platform) {
    return 'Política de privacidade do $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Última atualização: $date';
  }

  @override
  String get privacyIosOverview1 =>
      'O TruthLens não coleta nenhum dado associado à sua identidade, e não usa nenhum dado para rastreamento, portanto não requer permissão de Transparência de Rastreamento de Aplicativos (ATT).';

  @override
  String get privacyIosOverview2 =>
      'Este aplicativo usa o seletor de arquivos do sistema para acessar arquivos ou imagens que você seleciona ativamente; ele não pode acessar arquivos que você não selecionou (aplicado pelo Sandbox de Aplicativos do iOS).';

  @override
  String get privacyAndroidOverview1 =>
      'O TruthLens não coleta dados pessoais, e não compartilha dados do usuário com terceiros.';

  @override
  String get privacyAndroidOverview2 =>
      'Este aplicativo só acessa o armazenamento quando você escolhe ativamente importar um arquivo ou imagem; ele não varre nem acessa outros arquivos em segundo plano.';

  @override
  String get privacyMacosOverview1 =>
      'O TruthLens é executado sob o Sandbox de Aplicativos do macOS e só pode acessar arquivos que você seleciona ativamente por meio da caixa de diálogo de arquivos do sistema (files.user-selected.read-write) — ele não pode varrer ou acessar nenhum outro arquivo ou pasta por conta própria.';

  @override
  String get privacyMacosOverview2 =>
      'O acesso à rede (network.client) é usado apenas para as funções listadas em \"Comportamento de conexão necessário\" abaixo.';

  @override
  String get privacyWindowsOverview1 =>
      'O TruthLens é um aplicativo de desktop autônomo; os dados são armazenados na sua pasta de usuário local (ex.: AppData/Documents) e nunca são sincronizados com a nuvem.';

  @override
  String get privacyWindowsOverview2 =>
      'Este aplicativo só acessa arquivos que você seleciona ativamente para importar; ele não varre outros arquivos em segundo plano.';

  @override
  String get privacyDataHandling1 =>
      'O TruthLens não tem contas de usuário, não requer login, e não contém nenhum SDK de publicidade ou rastreamento de terceiros de nenhuma forma.';

  @override
  String get privacyDataHandling2 =>
      'Qualquer conteúdo de documento que você digitar, colar ou importar é analisado inteiramente por modelos de IA no seu próprio dispositivo — nunca é enviado ao TruthLens ou a qualquer servidor de terceiros.';

  @override
  String get privacyDataHandling3 =>
      'Os resultados de análise e o histórico são armazenados apenas em um banco de dados local no seu dispositivo; desinstalar o aplicativo ou limpar o histórico os remove completamente — o TruthLens não retém nenhuma cópia em nenhum lugar.';

  @override
  String get privacyNetworkIntro =>
      'A detecção de IA principal deste aplicativo é executada totalmente no dispositivo, mas os três recursos a seguir requerem acesso à rede:';

  @override
  String get privacyNetwork1 =>
      '1. Catálogo e download de modelos: conecta-se ao GitHub Releases/Hugging Face para baixar o modelo de detecção que você escolher — isso apenas baixa o modelo e nunca envia nenhum dado do usuário.';

  @override
  String get privacyNetwork2 =>
      '2. Verificação de atualização do modelo: no lançamento, o aplicativo se conecta apenas para comparar números de versão, usados para mostrar se uma nova versão está disponível.';

  @override
  String get privacyNetwork3 =>
      '3. Verificação de autenticidade de hiperlinks e citações: ativada por padrão, pode ser desativada nas Configurações. Quando ativada, a URL ou o texto bibliográfico detectado no documento é enviado diretamente para essa URL, ou para a API pública da Crossref, enviando apenas o texto da URL/DOI/citação em si — nunca o restante do conteúdo do documento.';

  @override
  String get privacyRightsIntro =>
      'Você pode limpar seu histórico de análise local a qualquer momento em \"Histórico\", desativar a verificação de hiperlinks/citações em \"Configurações\", ou remover todos os dados locais';

  @override
  String get privacyRemoveIos => 'excluindo o aplicativo';

  @override
  String get privacyRemoveAndroid => 'desinstalando o aplicativo';

  @override
  String get privacyRemoveMacos => 'movendo o aplicativo para a Lixeira';

  @override
  String get privacyRemoveWindows => 'desinstalando o aplicativo';

  @override
  String get privacyDisclaimer =>
      'Esta página é uma explicação de privacidade escrita pelo TruthLens para refletir o comportamento funcional real, não um documento legal formal revisado por advogado; para uma revisão formal de conformidade sob as leis da sua região, consulte um advogado independente.';

  @override
  String get privacySectionOverviewIos =>
      'Visão geral (equivalente aos \"Rótulos de Privacidade\" da App Store)';

  @override
  String get privacySectionOverviewAndroid =>
      'Visão geral (equivalente à divulgação de \"Segurança de Dados\" do Google Play)';

  @override
  String get privacySectionOverviewMacos =>
      'Visão geral (permissões do Sandbox de Aplicativos)';

  @override
  String get privacySectionOverviewWindows => 'Visão geral';

  @override
  String get privacySectionDataHandling => 'Como tratamos seus dados';

  @override
  String get privacySectionNetwork => 'Conexões de rede necessárias';

  @override
  String get privacySectionRights => 'Seus direitos';

  @override
  String get privacyGenericPlatformName => 'Esta plataforma';
}
