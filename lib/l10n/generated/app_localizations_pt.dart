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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
  String inputPdfOcrProgress(int page, int total) {
    return 'A camada de texto do PDF não está disponível; reconhecendo a página $page de $total com OCR…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return '\"$fileName\" importado com OCR de PDF ($count caracteres)';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '\"$fileName\" não tem uma camada de texto confiável. Configure o OCR Web ou use um aplicativo instalado com OCR nativo e importe novamente.';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '\"$fileName\" precisa de OCR, mas excede o limite de segurança de $max páginas. Divida o PDF e importe cada parte.';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '\"$fileName\" não pôde ser lido de forma confiável. Pode estar danificado, protegido por senha ou não ser compatível com o serviço de OCR configurado.';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '\"$fileName\" é um arquivo .doc antigo e seu texto não pôde ser extraído de forma confiável. Salve-o como .docx no Word ou exporte-o para PDF e importe novamente.';
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
  String analysisPreliminaryResult(int percent) {
    return 'Resultado preliminar: probabilidade de IA $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'Resultado preliminar: probabilidade de IA $percent% (refinando…)';
  }

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
  String get modelCatalogLoadFailed =>
      'Não foi possível carregar o catálogo de modelos';

  @override
  String get modelCatalogEmpty => 'Nenhum modelo disponível';

  @override
  String modelDownloadPathChip(String label) {
    return 'Caminho de download de $label';
  }

  @override
  String get modelDownloadPathModelFile => 'Arquivo do modelo';

  @override
  String get modelDownloadPathCopied => 'Caminho de download copiado';

  @override
  String settingsSaveFailed(String error) {
    return 'Falha ao salvar as configurações: $error';
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
  String get settingsEngineWeightsTitle => 'Pesos dos modelos de IA';

  @override
  String get settingsEngineWeightsSubtitle =>
      'Defina a influência de cada motor no resultado combinado. O total deve ser exatamente 100% antes de guardar.';

  @override
  String get settingsEngineInfoTooltip => 'Função deste motor';

  @override
  String get settingsEngineTransformerHelp =>
      'Avalia blocos de parágrafos que preservam o contexto com um Transformer multilíngue e mapeia as pontuações de volta às frases para o relatório detalhado. O peso define a influência e o sinal de IA determina a contribuição real.';

  @override
  String get settingsEngineStatisticalHelp =>
      'Mede perplexidade, previsibilidade, burstiness e variação do comprimento das frases. A correção ESL pode reduzir o peso efetivo.';

  @override
  String get settingsEngineStylometryHelp =>
      'Verifica marcadores explicáveis como inícios repetidos, transições formulaicas e listas excessivas. Sem marcadores, o sinal é 0%.';

  @override
  String get settingsEngineAdversarialHelp =>
      'Procura texto de IA parafraseado ou processado para ocultar vestígios. Uma pontuação baixa é apenas evidência residual fraca, não uma deteção positiva.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'Total: $total% — pronto para guardar';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'Total: $total% — ajuste exatamente para 100%';
  }

  @override
  String get settingsEngineWeightsSave => 'Guardar pesos';

  @override
  String get settingsEngineWeightsSaved =>
      'Pesos dos modelos guardados neste dispositivo';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'Repor predefinições';

  @override
  String get engineReasonDisabledByUser =>
      'O usuário desativou este mecanismo nas Configurações';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: nenhuma das $total frases ultrapassou o limiar forte de IA; o sinal fraco calibrado é $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'Sinal de IA $percent%';
  }

  @override
  String get reportEngineSignalExplanation =>
      'O sinal de IA é a probabilidade atribuída pelo motor a este documento. O peso configurado controla sua influência, e os pontos de contribuição são distribuídos para que a soma exibida corresponda exatamente à probabilidade geral de IA. “Não detectado” significa abaixo do limite de sinal forte de 60%, não necessariamente valor zero.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'Nenhuma das $total frases ultrapassou o limite forte de paráfrase; o sinal fraco calibrado é de $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count de $total frases ultrapassaram o limite forte de paráfrase; o sinal calibrado do documento é de $percent%';
  }

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
  String get modelImportWebUnsupported =>
      'A importação de modelos personalizados ainda não é compatível com a versão web. Use a versão do aplicativo.';

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
  String get reportEngineWeightLabel => 'Ponderação';

  @override
  String get privacySealNoticeText =>
      'Selo de privacidade 100% offline TruthLens: Processado no dispositivo sem armazenamento em nuvem.';

  @override
  String get reportModelCalibrationTitle =>
      'Autocalibração de referência do modelo';

  @override
  String get reportCommunityDiscoveredTag => 'Comunidade (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'Detalhamento por mecanismo';

  @override
  String get reportEngineNotInstalled => 'Não instalado';

  @override
  String get reportEngineLoadFailedBadge => 'Falha no carregamento';

  @override
  String get reportEngineAnalysisLevelTitle =>
      'Camadas de análise do mecanismo';

  @override
  String get reportVerdictAiLikelihood => 'Tendência de IA';

  @override
  String get reportVerdictHumanLikelihood => 'Escrita Humana';

  @override
  String get reportRadarRoleTransformer => 'Classificador Transformer';

  @override
  String get reportRadarRoleStatistical => 'Análise estatística';

  @override
  String get reportRadarRoleStylometry => 'Análise de estilometria';

  @override
  String get reportRadarRoleAdversarial => 'Defesa adversarial';

  @override
  String get reportRadarAxisTransformer => 'Classificador de frases';

  @override
  String get reportRadarAxisStatistical => 'Regularidade linguística';

  @override
  String get reportRadarAxisStylometry => 'Estilo de escrita';

  @override
  String get reportRadarAxisAdversarial => 'Defesa contra reescrita';

  @override
  String get reportVerdictBadgeTitle => 'Veredito geral';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return 'Probabilidade de IA geral $percent%';
  }

  @override
  String get reportVerdictHintHuman =>
      'A maioria dos sinais dos mecanismos indica uma escrita humana natural.';

  @override
  String get reportVerdictHintLikelyHuman =>
      'No geral, tende a ser humano, com uma pequena incerteza do modelo remanescente.';

  @override
  String get reportVerdictHintMixed =>
      'Os sinais dos mecanismos são mistos; leia a análise detalhada junto com este resultado.';

  @override
  String get reportVerdictHintLikelyAi =>
      'Vários indicadores apontam para IA; revise os trechos com pontuação alta.';

  @override
  String get reportVerdictHintAi =>
      'Os sinais gerais indicam fortemente conteúdo gerado ou reescrito por IA.';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return 'Veredito geral: $verdict; probabilidade de IA geral $percent%.';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return 'Sinal individual mais forte: $label ($percent%), mas o resultado final combina os pesos dos mecanismos e não é a conclusão de um único mecanismo.';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return 'A maior contribuição ponderada atualmente vem de $label (cerca de $points pontos percentuais).';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '\"Nenhum estilo de escrita de IA óbvio detectado\" significa apenas que o mecanismo de estilo não encontrou padrões fixos de frases ou palavras de transição; outros modelos ainda podem aumentar a pontuação geral por meio da regularidade linguística, classificação de frases ou sinais de reescrita.';

  @override
  String get reportSynthesisModelGap =>
      'Quando alguns mecanismos não participam, use primeiro \"Completar modelos de análise recomendados\" no Gerenciamento de Modelos; se ainda falhar, a análise detalhada indicará se a causa é um modelo ausente, tokenizador não suportado, arquivo ausente ou limite de compatibilidade Web/ONNX Runtime.';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label não participou desta votação ponderada, portanto esta dimensão é exibida como 0%. $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return 'Peso da função $weight%, contribuindo com cerca de $points pontos percentuais para a pontuação geral$variantText.';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return ' (mesclado $count variantes de modelo)';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label não participou desta votação.';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label não retornou nenhuma explicação de texto adicional.';
  }

  @override
  String get reportEngineResolutionTransformer =>
      'Solução: baixe e ative o Transformer multilíngue no Gerenciamento de Modelos; se já estiver baixado, baixe novamente o modelo e o tokenizador.';

  @override
  String get reportEngineResolutionAdversarial =>
      'Solução: baixe novamente o modelo de detecção de reescrita e o tokenizador no Gerenciamento de Modelos; na web, atualize para uma versão com a correção de compatibilidade BigInt e analise novamente.';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason. Causa: o ONNX Runtime da web retornou um tensor BigInt que a ponte anterior não conseguiu converter; atualize para a versão corrigida e analise novamente.';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason. Solução: mude para um modelo do catálogo ou baixe novamente o modelo e o tokenizador.';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason. Solução: abra o Gerenciamento de Modelos, toque em \"Completar modelos de análise recomendados\" e confirme se o Transformer multilíngue está marcado como ativo.';
  }

  @override
  String get reportDetailAnalysisTitle => 'Análise detalhada';

  @override
  String get reportNoEngineData => 'Ainda não há dados de análise do mecanismo';

  @override
  String get reportEngineNotParticipated => 'Não participou';

  @override
  String get reportAiContentReportTitle =>
      'Relatório de Detecção de Conteúdo de IA';

  @override
  String reportAnalysisTimeLabel(String time) {
    return 'Tempo de análise: $time';
  }

  @override
  String get reportDownloadPdfButton => 'Baixar PDF';

  @override
  String get reportSuspiciousLocationsTitle => 'Locais de conteúdo suspeito';

  @override
  String reportSentenceCount(int count) {
    return '$count frases';
  }

  @override
  String get reportAiProbabilityPrefix => 'Probabilidade de IA: ';

  @override
  String get helpAdvantage5 =>
      'Perícia de origem do documento: lê o registro de edição dentro de arquivos .docx / .odt / .doc — tempo gasto, número de salvamentos, dispersão dos lotes de edição. Essa evidência é independente do veredicto sobre o texto e aparece separada da probabilidade de IA. PDFs e imagens não têm histórico de edição próprio, então não podem fornecê-la.';

  @override
  String get helpAdvantage6 =>
      'Ele se abstém com honestidade quando a evidência é rala: menos de 5 frases analisáveis, menos de 100 palavras, menos de 2 motores participando, ou motores separados por mais de 60 pontos percentuais resultam em “evidência insuficiente para julgar”. A maioria das acusações falsas começa com um número confiante devolvido sobre uma entrada fraca demais.';

  @override
  String get settingsAiSampleTitle => 'Adicionar uma amostra de IA';

  @override
  String get settingsAiSampleSubtitle =>
      'A calibração em segundo plano só recolhe amostras humanas por conta própria. Para ativar os pesos aprendidos também são precisos textos que você saiba terem sido gerados por IA — cole ou importe um e ele será analisado e rotulado como amostra de IA na hora.';

  @override
  String get settingsAiSampleFromClipboard => 'Colar da área de transferência';

  @override
  String get settingsAiSampleFromFile => 'Importar um documento';

  @override
  String get settingsAiSampleAnalyzing => 'Analisando…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'Amostra de IA adicionada — $count no total';
  }

  @override
  String get settingsAiSampleTooShort =>
      'Curto demais para servir de amostra (são necessárias pelo menos 100 palavras)';

  @override
  String get settingsAiSampleFailed => 'Nenhum conteúdo utilizável encontrado';

  @override
  String get helpFormatCoverageTitle =>
      '2a. Limites de formato das evidências de origem';

  @override
  String get helpFormatCoverage =>
      '**Um limite importante: apenas .docx e .odt carregam registro de edição.**\n\n| Origem | Registro de edição |\n|---|---|\n| .docx / .odt | ✅ sim |\n| .pdf | ❌ o formato não guarda histórico algum |\n| .doc (antigo) | ✅ sim (OLE2 SummaryInformation) |\n| .txt / .md | ❌ sem contêiner |\n| OCR de imagem | ❌ só restam pixels |\n| Texto colado | ❌ não há arquivo |\n\nIsso afeta diretamente o pilar 3: **apenas documentos com registro de edição entram automaticamente na base com garantia estatística.** Se tudo o que você recebe é PDF, essa base nunca crescerá — você só acumulará amostras de referência sem garantia.\n\nPara que as evidências de origem e a calibração automática funcionem de fato, recolha originais .docx, .odt ou .doc em vez de PDFs impressos ou exportados. É uma exigência do fluxo de trabalho, não um limite que o software possa contornar: PDF é um formato de saída e simplesmente não registra como o texto foi escrito.';

  @override
  String provenanceUnsupportedFormat(String format) {
    return 'O formato $format não carrega histórico de edição algum, portanto não é que o registro tenha sido apagado: nunca existiu. Apenas .docx e .odt registram tempo de edição, número de salvamentos e lotes de edição.';
  }

  @override
  String get provenanceStripped =>
      'O formato é compatível, mas não se encontrou registro de edição no arquivo. Isso costuma indicar que ele foi salvo como arquivo novo, convertido online ou exportado do Google Docs — qualquer dessas ações zera o registro.';

  @override
  String get provenanceHowToGetRecord =>
      'Para que as evidências de origem sirvam, obtenha o **arquivo original .docx, .odt ou .doc**, e não um PDF impresso ou exportado. Só o original mantém o histórico de edição, e só ele pode entrar automaticamente na base com garantia estatística.';

  @override
  String get calibrationAutoTitle => 'Coletando em segundo plano';

  @override
  String get calibrationAutoSubtitle =>
      'Os documentos que você analisa entram sozinhos na base — não é preciso rotular à mão.';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return 'Confirmados como humanos pelo registro de edição: $auto; amostras apenas de referência: $observed';
  }

  @override
  String get calibrationAutoWhy =>
      'Só entram na base com garantia estatística os documentos com registro de edição (tempo gasto, número de salvamentos, dispersão dos lotes), porque essa evidência é **independente do veredicto sobre o texto**. Rotular pelo próprio veredicto da ferramenta seria corrigir a própria prova: o que ela marcasse por engano nunca entraria na base, o limite se apertaria a cada passagem e mais trabalhos autênticos acabariam marcados. Texto colado não tem registro de edição, então conta apenas para o percentil de referência abaixo.';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return 'Para referência: esta pontuação fica no percentil $percentile dos $count documentos que você analisou (sem garantia estatística)';
  }

  @override
  String get settingsAutoCollectTitle =>
      'Coletar amostras de calibração em segundo plano';

  @override
  String get settingsAutoCollectSubtitle =>
      'Adiciona automaticamente os documentos analisados à base. Os rótulos vêm do registro de edição, nunca do veredicto desta ferramenta.';

  @override
  String get settingsStoreTextTitle => 'Guardar o texto para validação offline';

  @override
  String get settingsStoreTextSubtitle =>
      'Quando ativo, os textos adicionados à base ficam guardados localmente com o conteúdo completo, permitindo exportá-los depois como corpus para avaliação offline.';

  @override
  String get settingsStoreTextWarning =>
      'Esse texto costuma ser trabalho alheio e portanto é sensível. Ative apenas enquanto estiver de fato reunindo um corpus de validação e use “Limpar o texto guardado” assim que exportar. Limpar não afeta a predição conforme: ela só precisa das pontuações.';

  @override
  String get settingsExportCorpusTitle => 'Exportar o corpus de calibração';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return 'Prontos para exportar: $human humanos, $ai de IA (são necessários $required de cada)';
  }

  @override
  String get settingsExportCorpusButton => 'Exportar como JSONL';

  @override
  String get settingsExportCorpusEmpty =>
      'Nada a exportar — ative primeiro “guardar o texto” e vá acumulando a base';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '$count amostra(s) exportada(s); $skipped ignorada(s) por não ter texto guardado';
  }

  @override
  String get settingsClearStoredText => 'Limpar o texto guardado';

  @override
  String get settingsClearStoredTextDone =>
      'Todo o texto guardado foi limpo. Pontuações e calibração permanecem intactas.';

  @override
  String get helpDesignTitle => 'Filosofia de projeto e limites conhecidos';

  @override
  String get helpShiftTitle =>
      '1. A virada: não competimos por exatidão de pontuação';

  @override
  String get helpShiftBody =>
      'Quase todo detector do mercado responde à mesma pergunta: este texto parece escrito por uma IA?\n\nEssa é uma corrida armamentista perdida. Quanto mais forte o modelo, mais sua saída se aproxima estatisticamente da escrita humana — e as ferramentas de reescrita melhoram muito mais rápido que os detectores. Nesse caminho, um grande modelo em servidor apenas perde mais devagar.\n\nO TruthLens faz outra pergunta: que evidências realmente temos sobre como este documento passou a existir, e qual o peso de cada uma?\n\nÉ passar do palpite sobre estilo para a pesagem de evidências de origem, junto a conclusões estatisticamente honestas. Por isso esta ferramenta deliberadamente não busca posição em rankings de exatidão de pontuação única, mas expõe cada evidência separadamente e diz claramente quando não sabe. A verdadeira vantagem de rodar no seu navegador não é velocidade — é enxergar o que um servidor nunca vê: o arquivo completo e a base que você mesmo reuniu.';

  @override
  String get helpPillarsTitle => '2. Os cinco pilares';

  @override
  String get helpPillarsBody =>
      '1. Perícia de origem do documento (ativo)\nLê o registro de edição dentro dos contêineres DOCX e ODT: tempo total de edição, número de salvamentos, datas de criação e modificação, e os marcadores de lote de edição (RSID) no corpo. Um ou dois RSID em um trabalho inteiro costuma significar que o texto entrou de uma vez; 3.000 palavras com quatro minutos de edição é evidência mais dura que qualquer pontuação de perplexidade. Isso conta como evidência de origem e aparece separado da probabilidade de IA — deliberadamente nunca somado à pontuação.\n\n2. Calibração com base local e predição conforme (ativo)\nAdicione textos que você sabe terem sido escritos pelos próprios autores e o sistema julgará pela distribuição deste grupo em vez de um limite global. A predição conforme dá uma garantia livre de distribuição: se a base e a amostra testada forem intercambiáveis, a taxa de falsos positivos fica abaixo do alfa que você definir. É a chave para reduzir erros com escrita não nativa, e algo que produtos comerciais não conseguem fazer: eles não têm trabalhos de referência das pessoas que você avalia.\n\n3. Pesos de motor aprendidos (ativo)\nQuando a base contém amostras humanas e de IA, o sistema mede o quanto cada motor separa os dois grupos (tamanho de efeito, d de Cohen) e sugere pesos correspondentes, substituindo as proporções fixas definidas à mão. Nada muda até você tocar em Aplicar — as configurações nunca são alteradas em silêncio.\n\n4. Perplexidade cruzada Binoculars (núcleo de cálculo pronto, ainda não ativo)\nA perplexidade crua trata o quanto um texto é previsível como se isso medisse o quanto ele parece de IA — daí exatamente seus falsos positivos sistemáticos com escrita não nativa de estilo simples. O Binoculars mede essa previsibilidade em relação ao quanto dois modelos discordam entre si. A matemática está implementada e testada, mas ligá-la ainda exige um par de modelos de linguagem pequenos que rodem no navegador, além de validação com dados rotulados.\n\n5. Detecção de marca d\'água (verificado, inviável, não construído)\nA detecção do SynthID-Text é atrelada a chaves: o detector precisa calcular com as mesmas chaves usadas na geração, e as chaves de produção do Google não são públicas. Fazer isso no navegador nunca dispararia com saídas reais de ChatGPT, Claude ou Gemini — seria apenas um recurso que jamais aciona, enquanto deixa você acreditando que marcas d\'água estão sendo verificadas. Por isso foi deliberadamente deixado de fora.';

  @override
  String get helpCascadeTitle => '3. A cascata em camadas e a abstenção';

  @override
  String get helpCascadeBody =>
      'Para manter a velocidade dentro do orçamento de processamento de um navegador, a análise roda em camadas: sinais baratos primeiro, caros só quando necessário.\n\nCamada 0  Evidências de origem do documento (custo quase nulo)\nCamada 1  Traços estatísticos e estilométricos (motores existentes, baratos)\nCamada 2  Classificador Transformer por frase\nCamada 3  Perplexidade cruzada (o mais caro, só se o quadro continuar incerto)\n\nO resultado então passa para a calibração local, que produz uma conclusão com garantia de falsos positivos — ou uma abstenção explícita.\n\n[Por que a abstenção importa]\nA maioria das acusações falsas nasce de devolver um número confiante sobre uma entrada curta ou fraca demais para sustentá-lo. Esta ferramenta mostra abertamente \"Evidência insuficiente para julgar\", em vez de forçar uma pontuação, quando:\n\n- menos de 5 frases analisáveis\n- menos de 100 palavras\n- menos de 2 motores participaram\n- os motores divergem em mais de 60 pontos percentuais (a média deixou de significar algo)\n\nAo se abster, a pontuação completa e as evidências por frase continuam abaixo para sua referência — mas não as trate como conclusão. Um sistema disposto a dizer \"não sei\" merece mais confiança do que um que sempre lhe entrega um número.';

  @override
  String get helpRisksTitle => '4. Riscos que vale encarar com honestidade';

  @override
  String get helpRisksBody =>
      'Cada item abaixo é uma limitação real desta ferramenta. Pondere-os antes de agir com base no que ela relatar.\n\n1. Evidências de origem podem ser apagadas ou forjadas\nSalvar como arquivo novo, converter online, exportar do Google Docs ou copiar para um documento novo zeram o registro de edição. Um sinal aqui é apenas evidência de apoio, e a ausência dele certamente não prova que uma pessoa escreveu.\n\n2. A garantia conforme se apoia na intercambiabilidade\nSó vale se as amostras base e o texto analisado vierem do mesmo grupo de pessoas fazendo o mesmo tipo de tarefa. Se a escrita de alguém melhorou claramente, ou o tipo de tarefa mudou por completo, a premissa cai e a base precisa ser refeita.\n\n3. A própria base pode estar contaminada\nSe os trabalhos usados como base foram na verdade escritos por IA, toda a calibração distorce. As amostras base precisam ser coletadas em condições controladas — trabalhos feitos sob supervisão, por exemplo.\n\n4. Modelos pequenos no navegador são menos exatos que grandes em servidor\nEsse é o preço inevitável que a decisão Web-only paga pela privacidade. O valor desta ferramenta não é uma pontuação única mais exata, mas ser explicável, calibrável e honesta o bastante para se abster.\n\n5. Nenhuma pontuação deve sustentar sozinha uma acusação\nLeia-a sempre junto às evidências por frase, à origem do documento e ao que você já sabe sobre essa pessoa específica. Esta ferramenta foi projetada para apoiar uma conversa que você conduz, não para dar um veredicto no seu lugar.';

  @override
  String get calibrationAddHuman => 'Adicionar como base escrita por humano';

  @override
  String get calibrationAddAi => 'Adicionar como amostra de IA conhecida';

  @override
  String calibrationCounts(int human, int ai) {
    return 'Base: $human humanas, $ai de IA';
  }

  @override
  String get learnedWeightsTitle => 'Pesos de motor aprendidos';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return 'Você tem $human amostras humanas e $ai de IA. Cada classe precisa de pelo menos $required para que os pesos sejam aprendidos de forma confiável; até lá valem os seus pesos manuais.';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return 'Já é possível aprender pesos a partir das suas $human amostras humanas e $ai de IA.';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine: peso sugerido $weight% (separação $effect)';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return 'Atenção: $engine inverteu os dois grupos — as amostras de IA pontuaram mais baixo, não mais alto — então seu peso cai a zero. Isso costuma indicar que o motor não serve para esse tipo de texto.';
  }

  @override
  String get learnedWeightsApply => 'Aplicar os pesos aprendidos';

  @override
  String get learnedWeightsApplied => 'Pesos aprendidos aplicados';

  @override
  String get learnedWeightsExplain =>
      'Os pesos vêm de quão bem cada motor separa suas amostras humanas das de IA (tamanho de efeito, d de Cohen): quanto mais distantes os dois grupos e mais estável cada um, mais peso o motor ganha. Isso substitui os pesos fixos definidos à mão para que o conjunto se ajuste ao tipo de texto com que você realmente trabalha.';

  @override
  String get calibrationTitle => 'Calibração com base local';

  @override
  String get calibrationEmpty =>
      'Ainda não há conjunto base. Acrescente alguns textos que você sabe terem sido escritos pelos próprios autores — trabalhos feitos sob supervisão, por exemplo — e o sistema poderá julgar pela distribuição deste grupo em vez de um limite global igual para todos. É justamente isso que reduz os falsos positivos na escrita não nativa.';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return 'O conjunto base tem $count amostra(s); para que um teto de falsos positivos de $alpha% valha de fato, são necessárias pelo menos $required. Até lá os números são apenas de referência e nada é sinalizado com base neles.';
  }

  @override
  String calibrationFlagged(int alpha) {
    return 'Com um teto de falsos positivos de $alpha%, este texto **é sinalizado**.';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return 'Com um teto de falsos positivos de $alpha%, este texto **não é sinalizado**.';
  }

  @override
  String calibrationPValue(String value, int count) {
    return 'Valor p conservador $value (contra $count amostras base)';
  }

  @override
  String calibrationPercentile(int percentile) {
    return 'A pontuação fica no percentil $percentile do conjunto base';
  }

  @override
  String get calibrationCaveat =>
      'Essa garantia se apoia em as amostras base e o texto analisado serem intercambiáveis: mesmo grupo de pessoas, mesmo tipo de tarefa. Se a escrita de alguém melhorou claramente, ou o tipo de tarefa mudou por completo, isso deixa de valer e o conjunto base precisa ser refeito. Note ainda: se os textos base foram escritos por uma IA, toda a calibração distorce — colete-os em condições controladas.';

  @override
  String get calibrationAddButton => 'Adicionar este texto à base';

  @override
  String calibrationAdded(int count) {
    return 'Adicionado ao conjunto base — agora $count amostra(s)';
  }

  @override
  String get settingsCalibrationTitle => 'Conjunto base local';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '$count amostra(s) guardadas ($required necessárias com este α)';
  }

  @override
  String get settingsCalibrationClear => 'Esvaziar o conjunto base';

  @override
  String get settingsCalibrationCleared => 'Conjunto base esvaziado';

  @override
  String get settingsAlphaTitle => 'Teto de falsos positivos (α)';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return 'Atualmente $alpha% — mais baixo é mais rígido, mas exige mais amostras base (pelo menos $required)';
  }

  @override
  String get abstentionHeadline => 'Evidência insuficiente para julgar';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return 'Apenas $count frase(s) analisável(is), quando são necessárias pelo menos $required. Nesse tamanho os sinais estatísticos e por frase não pesam nada, e forçar uma pontuação só enganaria.';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return 'O texto tem $count palavras e precisa de pelo menos $required. Abaixo disso, qualquer traço de escrita pode ser acaso.';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return 'Apenas $available de $total motores participaram, então não há como conferir por outro ângulo. Complete os modelos que faltam no gerenciamento de modelos e rode de novo.';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return 'Os motores estão a $spread pontos percentuais de distância — o bastante para que a média deixe de significar algo. Use as evidências por frase e a origem do documento e julgue você mesmo.';
  }

  @override
  String get abstentionNoEvidenceFound =>
      'All engines ran, but none found usable evidence. The low fallback score is diagnostic output, not evidence that a person wrote the text.';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return 'Only $count engine found usable evidence, and the overall score is still below the AI threshold. Treat this as weak coverage, not as evidence that a person wrote it.';
  }

  @override
  String get abstentionScoreStillShown =>
      'A pontuação completa e as evidências por frase continuam abaixo para sua referência. Não as trate como conclusão.';

  @override
  String get provenanceTitle => 'Evidências de origem do documento';

  @override
  String get provenanceRiskHigh => 'O histórico de edição é claramente incomum';

  @override
  String get provenanceRiskMedium => 'Há algo estranho no histórico de edição';

  @override
  String get provenanceRiskLow => 'O histórico de edição parece normal';

  @override
  String get provenanceRiskUnknown => 'Nenhum histórico de edição disponível';

  @override
  String get provenanceNoMetadata =>
      'Esta entrada não traz histórico de edição — texto colado, um PDF, ou um arquivo cujo registro foi apagado. Não há o que julgar pela origem aqui, apenas a análise do texto.';

  @override
  String provenanceEditingDuration(int minutes) {
    return 'Tempo de edição registrado no arquivo: $minutes minutos';
  }

  @override
  String provenanceRevisionCount(int count) {
    return 'Vezes salvo: $count';
  }

  @override
  String provenanceApplication(String name) {
    return 'Produzido com: $name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return 'O corpo carrega apenas $count marcador(es) de lote de edição para $words palavras. Escrever pensando costuma deixar dezenas; tanta concentração normalmente significa que o texto entrou de uma vez — colado, por exemplo.';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words palavras contra $minutes minutos de edição registrada dão $wpm palavras por minuto, muito acima do que alguém sustenta escrevendo de fato.';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return 'O arquivo praticamente não registra tempo de edição, mas o corpo chega a $words palavras.';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words palavras de conteúdo, salvas apenas $count vez(es).';
  }

  @override
  String get provenanceCaveat =>
      'Vale saber: esses registros podem ser apagados ou zerados — salvar como novo arquivo, converter online, exportar do Google Docs ou copiar para um documento novo zeram todos eles. Um sinal aqui é evidência de apoio, nunca uma conclusão sozinha; e a ausência dele não prova que uma pessoa escreveu.';

  @override
  String get telemetrySummaryTitle => 'Resumindo';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$engines de $total motores terminaram. A probabilidade de IA geral é de $percent%, o que dá “$verdict”.';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return 'Os motores concordam bastante (o mais alto marca $high% e o mais baixo $low%), então a conclusão se sustenta bem.';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'Os motores discordam: $highLabel marcou $high% e $lowLabel apenas $low%. Nesses casos, não confie só na pontuação geral — as evidências frase a frase abaixo dizem muito mais.';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'O que mais puxa a pontuação é $label, com cerca de $points pontos percentuais.';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return 'Das $total frases analisadas, nenhuma cruzou a linha de sinal forte de IA.';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return 'De $total frases, $count cruzaram a linha de sinal forte de IA — vale a pena ler uma a uma.';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      'Lê-se como algo escrito por uma pessoa, sem nada que precise ser investigado.';

  @override
  String get telemetrySummaryAdviceMixed =>
      'Este ficou na zona cinzenta. Concluir só pela pontuação é arriscado: olhe junto com as evidências por frase e o que você sabe sobre a origem do documento.';

  @override
  String get telemetrySummaryAdviceAi =>
      'Os sinais apontam claramente para geração ou reescrita por IA. Confira as frases marcadas uma a uma antes de decidir.';

  @override
  String telemetrySummaryModelGap(int count) {
    return 'Além disso, $count motor(es) não participaram desta vez, então pese a confiança com cuidado; complete-os no gerenciamento de modelos e rode de novo para afinar.';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'Probabilidade de IA < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'Probabilidade de IA $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'Probabilidade de IA ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return 'Confiança baixa: o peso do modelo disponível está abaixo de 60% (limite $threshold%). $available/$total mecanismos participaram. Revise a análise detalhada dos mecanismos.';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return 'Confiança alta: $available/$total modelos de detecção alcançaram consenso ($threshold% ou mais do peso concorda com este veredito).';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return 'Confiança baixa ($available/$total)';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return 'Confiança alta ($available/$total)';
  }

  @override
  String get reportMetricAiSentenceRatio =>
      'Proporção de frases com sinal forte de IA';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count de $total ultrapassaram o limite de sinal forte de 60%';
  }

  @override
  String get reportMetricElapsed => 'Tempo de análise';

  @override
  String get reportMetricElapsedNormal => '0,5-5s normal';

  @override
  String get reportMetricReliability => 'Confiabilidade';

  @override
  String get reportReliabilityLow => 'Baixa';

  @override
  String get reportReliabilityHigh => 'Alta';

  @override
  String get reportReliabilityNeedsReview => 'Requer revisão';

  @override
  String get reportReliabilityHighTrust => 'Altamente confiável';

  @override
  String get reportSentenceAnalysisTitle => 'Análise em nível de frase';

  @override
  String get suspiciousFilterAll => 'Suspeito';

  @override
  String get suspiciousFilterHigh => 'Alto';

  @override
  String get suspiciousFilterMedium => 'Médio';

  @override
  String get suspiciousExcludedTooltip =>
      'Letras únicas, números de página, números de seção e fragmentos de OCR/PDF muito curtos foram excluídos.';

  @override
  String suspiciousCount(int count) {
    return '$count itens';
  }

  @override
  String get suspiciousEmpty => 'Nenhum conteúdo suspeito';

  @override
  String get suspiciousRiskHigh => 'Alto';

  @override
  String get suspiciousRiskMedium => 'Médio';

  @override
  String get suspiciousReasonHighModelSignals =>
      'Vários sinais de modelo tendem fortemente para IA';

  @override
  String get suspiciousReasonSentenceSignal =>
      'O sinal do modelo em nível de frase está elevado';

  @override
  String suspiciousOriginalLocation(String location) {
    return 'Local original $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return 'Local original $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return 'Frase nº $number';
  }

  @override
  String get suspiciousEvidenceLabel => 'Evidência:';

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
  String get reportBibRecheckAllUnreliableButton =>
      'Reverificar todas as citações não verificadas';

  @override
  String get reportBibRecheckOneTooltip => 'Reverificar esta citação';

  @override
  String get reportBibResultHint =>
      'Comparado com o registro público da Crossref por similaridade de autor, ano e título. Não é uma garantia absoluta — quando \"incerto\", verifique manualmente.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Fonte de verificação: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Verificar manualmente no Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Alta confiança: provavelmente existe$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (registrado em $journal)';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Nome da revista não corresponde: o documento indica \"$reported\", enquanto o registro verificado indica \"$registered\". Revise esta citação.';
  }

  @override
  String get reportBibNotFound =>
      'Nenhuma correspondência próxima encontrada — possível referência fictícia';

  @override
  String get reportBibUncertain =>
      'Suspeito: não verificado por correspondência de registro';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Apenas as primeiras $max entradas foram verificadas (total de $count detectadas)';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '$count concluídos; os resultados continuarão sendo atualizados.';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return 'Progresso $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return 'Atual: $text';
  }

  @override
  String get reportBibProgressFinalizing => 'Finalizando resultados';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base: candidato semelhante encontrado \"$candidate\", mas autor, ano ou título não atingiram o limite de correspondência confiável.';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base: as fontes de verificação não retornaram uma resposta confiável ou a entrada carece de informações suficientes; o TruthLens não considera esta citação verificada.';
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
    return 'A probabilidade geral de IA excede o limite fixo de $percent% e foi sinalizada como IA.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'A probabilidade geral de IA está abaixo do limite fixo de sinalização de $percent%.';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return 'A probabilidade geral de IA é $aiPercent%, o que atinge o limite fixo de sinalização de IA de $thresholdPercent%, então o relatório marca este texto como IA. Revise as evidências em nível de frase e as razões dos mecanismos antes de tomar uma decisão final.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'A probabilidade geral de IA é $aiPercent%, abaixo do limite fixo de sinalização de IA de $thresholdPercent%, então o relatório não marca formalmente este texto como IA. A probabilidade e as evidências ainda são exibidas para revisão.';
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
  String engineReasonStatisticalSummaryAi(String percent) {
    return 'Resumo estatístico geral: tende a características geradas por IA (probabilidade de IA $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return 'Resumo estatístico geral: tende a uma escrita humana natural (probabilidade de IA $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return 'Resumo estatístico geral: os indicadores se equilibram, mostrando características neutras (probabilidade de IA $percent%)';
  }

  @override
  String get reportFormulaTitle =>
      'Transparência do Cálculo Ponderado e Detalhamento de Parâmetros';

  @override
  String get reportFormulaExplanation =>
      'A probabilidade geral de IA é calculada como uma média ponderada das probabilidades de todos os mecanismos ativos:';

  @override
  String get reportFormulaActiveEngines =>
      'Mecanismos ativos e pesos atribuídos';

  @override
  String get reportFormulaCalculation => 'Cálculo da fórmula ponderada';

  @override
  String get reportFormulaFinalResult => 'Probabilidade de IA Ponderada Final';

  @override
  String get reportFormulaEslApplied =>
      'Ajuste de escrita não nativa ESL aplicado (peso do modelo estatístico reduzido pela metade)';

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
  String engineReasonAssistantResponseArtifact(int count) {
    return 'Detected $count conversational assistant-response artifact(s), such as addressing the requester or offering to revise the requested text';
  }

  @override
  String get engineReasonAdversarialNotInstalled =>
      'O modelo de detecção de paráfrase não está instalado; não participou desta votação';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Nenhum modelo instalado ou o modelo ativo não é compatível; não participou desta votação';

  @override
  String get modelRepairNoActiveVariant =>
      'Nenhum modelo ativo encontrado; baixe um modelo recomendado no Gerenciamento de Modelos.';

  @override
  String get modelRepairCustomRemoved =>
      'O modelo personalizado que falhou ao carregar foi removido. Modelos personalizados não podem ser baixados novamente automaticamente; reimporte o modelo e o tokenizador.';

  @override
  String get modelRepairNoSource =>
      'O arquivo do modelo que falhou ao carregar foi removido, mas atualmente não há fonte de catálogo disponível para baixá-lo novamente; baixe novamente um modelo recomendado no Gerenciamento de Modelos.';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'Detectado que o arquivo do modelo pode estar corrompido ou incompatível; $name foi baixado novamente automaticamente. Execute a análise novamente.';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return 'O arquivo do modelo que falhou ao carregar foi removido, mas o novo download automático não foi concluído; verifique sua conexão de rede e baixe $name novamente no Gerenciamento de Modelos.';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'Nenhum modelo Transformer ativo encontrado; baixe ou ative um no Gerenciamento de Modelos';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return 'O tipo de tokenizador do modelo ativo não é suportado ($tokenizer); mude para um modelo compatível com bert-wordpiece ou roberta-bpe';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Caminho do modelo Transformer ou do tokenizador ausente; baixe novamente no Gerenciamento de Modelos';

  @override
  String get engineTransformerMissingFiles =>
      'O arquivo do modelo Transformer ou do tokenizador não existe; baixe novamente no Gerenciamento de Modelos';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'Versão do opset ONNX não suportada (esta versão do modelo é muito recente; atualize o aplicativo): $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Formato do tokenizador corrompido: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'Falha ao carregar ou executar o modelo, e o reparo automático não foi concluído; baixe novamente o modelo Transformer ativo e o tokenizador no Gerenciamento de Modelos.';

  @override
  String get engineAdversarialNoActiveVariant =>
      'Nenhum modelo de detecção de reescrita ativo encontrado';

  @override
  String get engineAdversarialMissingFiles =>
      'O arquivo do modelo ou do tokenizador não existe; baixe novamente no Gerenciamento de Modelos';

  @override
  String get engineAdversarialRepairFailed =>
      'Falha ao carregar ou executar o modelo, e o reparo automático não foi concluído; baixe novamente o modelo de detecção de reescrita e o tokenizador no Gerenciamento de Modelos.';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'O modelo não participou desta votação. $error';
  }

  @override
  String get patternNotAnalyzable =>
      'Segmento muito curto ou possível ruído de PDF/OCR; nenhuma avaliação de IA em nível de frase foi realizada';

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
      'O TruthLens é um detector de conteúdo de IA que roda **inteiramente dentro do seu navegador**. Quatro motores independentes — um classificador neural Transformer, análise estatística, estilometria e detecção de reescrita adversária — votam com pesos se o texto foi gerado por IA, e o seu documento nunca sai da máquina.\n\nO relatório expressa o veredicto como probabilidade de IA classificada em cinco faixas fixas (abaixo de 20%, 20–40%, 40–60%, 60–80%, 80% ou mais), junto às evidências por frase, à contribuição de cada motor, às evidências de origem do documento e ao nome do arquivo ao importar. Os pontos de corte não são ajustáveis, então o mesmo documento cai sempre na mesma faixa. Quando a evidência é rala — poucas frases ou palavras, ou motores discordando demais — ele diz isso claramente em vez de forçar uma pontuação.';

  @override
  String get helpComparisonTitle => 'Comparação com ferramentas líderes';

  @override
  String get helpComparisonDisclaimer =>
      'Esta comparação foi compilada a partir de informações públicas de cada ferramenta e percepções gerais de mercado, apenas para referência de posicionamento funcional — não são dados de referência verificados por terceiros.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'O GPTZero faz quase tudo na nuvem e exige enviar o documento; os quatro motores do TruthLens rodam no seu próprio navegador e o conteúdo não é enviado a lugar nenhum.';

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
      'O Originality.ai cobra por peça em assinatura e exige envio para a nuvem; o TruthLens faz o trabalho essencial no navegador, sem assinatura e sem limite de uso.';

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
      'O OCR de imagens do Winston AI envia a foto para a nuvem; o OCR do TruthLens prefere um servidor local que você configura e só recorre à nuvem se você mesmo fornecer uma chave de API do Gemini — se a nuvem entra ou não continua sendo decisão sua.';

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
  String helpWorkflowStepLabel(int step) {
    return 'Etapa $step';
  }

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
      'Classificador de IA multilíngue (peso 40%): analisa blocos de parágrafos limitados para preservar o contexto e mapeia as probabilidades de volta às frases.';

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
      'Você pode ativar/desativar mecanismos individualmente e ajustar seus pesos nas Configurações. As cinco faixas do veredicto usam pontos de corte fixos (20% / 40% / 60% / 80%) e não podem ser alteradas, então o mesmo documento dá o mesmo veredicto para todos.';

  @override
  String get helpWorkflowStep3Title => 'Enviando um documento';

  @override
  String get helpWorkflowStep3Body =>
      'Três formas de entrada: colar texto, reconhecer uma imagem por OCR, ou importar um documento (txt / md / pdf / docx / doc / odt). A importação de PDF compara dois analisadores de camada de texto e descarta saída ilegível; PDFs digitalizados são reconhecidos página a página quando há OCR disponível. Ao importar, o nome do arquivo aparece sob o título de entrada e em linha própria no título do relatório; ao colar ou digitar, fica em branco.\n\nO OCR prefere o servidor local que você configurar e só usa a nuvem se você mesmo fornecer uma chave de API do Gemini.';

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
  String get helpWorkflowStep1ChipOnboarding => 'Primeira abertura';

  @override
  String get helpWorkflowStep1ChipModelManager => 'Gestão de modelos';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'Verificação automática';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'Análise estatística (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'Estilometria (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'Defesa adversarial (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'LLM de relatório (opcional)';

  @override
  String get helpWorkflowStep3ChipPaste => 'Colar texto';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'OCR de imagem';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation =>
      'Isolar código/fórmulas';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'Conjunto de 4 motores';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Progresso ao vivo';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'Correção ESL';

  @override
  String get helpWorkflowStep4ChipStoppable =>
      'Pode ser interrompido a qualquer momento';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'Medidor geral de IA';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => 'Mapa de calor por frase';

  @override
  String get helpWorkflowStep5ChipCitationVerification =>
      'Verificação de citações';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'Exportar PDF / CSV / JSON / PNG';

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
  String get privacyWebOverview1 =>
      'O TruthLens funciona inteiramente como um aplicativo web na aba do seu navegador. Não há nada para instalar; o texto do documento e os resultados da análise nunca saem do seu dispositivo, e os modelos de detecção baixados são armazenados em cache apenas no armazenamento isolado do próprio navegador (OPFS), não em nenhum servidor.';

  @override
  String get privacyWebOverview2 =>
      'A página só lê um arquivo, imagem ou conteúdo da área de transferência quando você escolhe ativamente importar, digitalizar ou colar; ela nunca lê outras abas, dados de outros sites ou arquivos que você não selecionou.';

  @override
  String get privacySectionOverviewWeb => 'Visão geral';

  @override
  String get privacyRemoveWeb =>
      'limpando os dados deste site nas configurações do seu navegador (ou simplesmente fechando a aba, já que nada é armazenado em nenhum servidor)';

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
  String get privacyNetwork4 =>
      '4. Alternativa de OCR web: apenas na versão web, o OCR usa primeiro um servidor OCR local, se configurado. Se você optar por inserir uma chave de API do Gemini, as imagens selecionadas e as páginas de PDF renderizadas que precisam de OCR são enviadas diretamente do seu navegador para a API Gemini do Google; a chave é armazenada apenas no armazenamento local desse navegador.';

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

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'Versão $version (Build $build) · Motor privado com prioridade local';
  }

  @override
  String get webOcrSettingsTitle => 'Configurações de OCR Web';

  @override
  String get webOcrPurpose =>
      'Reconhece texto impresso ou manuscrito em uma imagem antes da análise.';

  @override
  String get webOcrGeminiKeyTitle => 'Chave da API Gemini (opcional)';

  @override
  String get webOcrGetKeyButton => 'Obter chave';

  @override
  String get webOcrGeminiDescription =>
      'Usada apenas quando o servidor OCR local não está disponível. A chave fica neste navegador.';

  @override
  String get webOcrLocalServerTitle => 'Servidor OCR local (recomendado)';

  @override
  String get webOcrLocalServerDescription =>
      'Executa OCR no computador com Apple Vision no macOS ou Windows OCR no Windows. Digite o endpoint local abaixo.';

  @override
  String get webOcrSetupGuideButton => 'Guia de configuração';

  @override
  String get webOcrPriorityTitle => 'Ordem de reconhecimento';

  @override
  String get webOcrPriorityDescription =>
      '1. Servidor OCR local quando há URL\n2. Gemini quando há chave API\n3. Diagnóstico específico se ambos falharem';

  @override
  String get webOcrSetupGuideTitle => 'Configurar o servidor OCR local';

  @override
  String get webOcrSetupGuideBody =>
      '1. Selecione Abrir projeto OCR abaixo.\n2. macOS: baixe setup_and_run_ocr.sh, abra o Terminal e execute: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: baixe setup_and_run_ocr.bat, clique duas vezes e permita a instalação.\n4. Aguarde o instalador informar que o OCR está pronto; a inicialização automática também será configurada.\n5. Digite http://127.0.0.1:5001/ocr e selecione Testar conexão.\n6. Abra OCR de imagem e escolha uma imagem nítida.\n\nPara usar 127.0.0.1, navegador e servidor devem estar no mesmo computador. Em caso de falha, verifique a instalação, a porta 5001 e o final /ocr.';

  @override
  String get webOcrOpenProjectButton => 'Abrir projeto OCR';

  @override
  String get webOcrTestServerButton => 'Testar conexão';

  @override
  String get webOcrTestServerMissingUrl =>
      'Digite primeiro a URL do servidor OCR local.';

  @override
  String get webOcrTestServerSuccess =>
      'O servidor OCR local está ativo e pronto.';

  @override
  String get webOcrTestServerFailure =>
      'Não foi possível acessar o servidor OCR local. Verifique o guia, firewall e URL.';

  @override
  String get workspaceModeSectionTitle => 'Modo do espaço de trabalho';

  @override
  String get workspaceModeSectionSubtitle =>
      'Escolha como fonte, análise ao vivo e evidências finais compartilham o mesmo espaço.';

  @override
  String get workspaceModeOriginal => 'Layout original';

  @override
  String get workspaceModeAuto => 'Automático';

  @override
  String get workspaceModeCommandGrid => 'Grade de comando';

  @override
  String get workspaceModeTimeline => 'Linha do tempo da missão';

  @override
  String get workspaceModeEvidence => 'Tela de evidências';

  @override
  String get workspaceModeCosmicFuture => 'Futuro Cósmico';

  @override
  String get workspaceModeSoftEducation => 'Educação Suave';

  @override
  String get workspaceModeTooltip => 'Alternar modo do espaço de trabalho';

  @override
  String get workspaceMoreMenuTooltip => 'Mais opções';

  @override
  String get workspaceLanguageMenuTitle => 'Idioma';

  @override
  String get workspaceStageImport => 'Importar';

  @override
  String get workspaceStageParse => 'Processar';

  @override
  String get workspaceStageAnalyze => 'Análise de quatro mecanismos';

  @override
  String get workspaceStageVerify => 'Verificação';

  @override
  String get workspaceStageReport => 'Relatório';

  @override
  String get workspaceLiveFindings => 'Descobertas ao vivo';

  @override
  String get workspaceTelemetry => 'Telemetria da análise';

  @override
  String get workspaceDocument => 'Espaço do documento';

  @override
  String get workspaceOverallProgress => 'Progresso geral';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'Etapa $current/$total · $stage';
  }

  @override
  String get workspaceWaiting => 'Aguardando um documento';

  @override
  String get workspaceAnalyzing => 'Análise em andamento';

  @override
  String get workspaceAnalysisComplete => 'Análise concluída';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total módulos concluídos · ${seconds}s decorridos · Em execução: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'A análise continua e a interface está responsiva. Nenhum módulo terminou nos últimos ${seconds}s; documentos grandes ou modelos locais podem demorar mais.';
  }

  @override
  String get workspaceAnalysisFailed =>
      'A análise parou inesperadamente. Tente novamente ou verifique as configurações do modelo.';

  @override
  String get workspaceNewAnalysis => 'Nova análise';

  @override
  String get workspaceStopAnalysis => 'Parar análise';

  @override
  String get workspaceStopAnalysisTitle => 'Parar a análise atual?';

  @override
  String get workspaceStopAnalysisBody =>
      'A análise ainda está em execução. O texto do documento será mantido, mas os resultados incompletos não serão salvos.';

  @override
  String get workspaceAnalysisStopped =>
      'Análise interrompida. O texto do documento permanece no espaço de trabalho.';

  @override
  String get workspaceSelectedEvidence => 'Evidência selecionada';

  @override
  String get workspaceNoEvidence =>
      'As evidências por frase aparecem quando cada mecanismo termina.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Probabilidade preliminar de IA: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'Esta porcentagem é o sinal de IA da própria frase, não o veredito geral do documento. Quanto maior, mais o padrão de redação parece gerado por IA; quanto menor, mais se assemelha à escrita humana típica. O relatório final combina todas as frases com a ponderação dos mecanismos.';

  @override
  String get workspaceSentenceSignalHeader => 'Sinal de IA por frase';

  @override
  String get workspaceSentenceColumnHeader => 'Frase';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine não encontrou evidências desta vez, portanto não participou da votação (peso do papel $weight%). Isso significa nenhum rastro de IA no seu próprio eixo — não que ele considere o texto escrito por uma pessoa.';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return 'Apenas $engine encontrou algo; os demais motores não acharam nada desta vez. A conclusão se apoia em uma única linha de evidência, então ajuste a confiança de acordo.';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return 'Outros $count motor(es) rodaram mas não encontraram evidências, e foram excluídos da votação para que \'nada a relatar\' não seja contado como \'parece escrito por uma pessoa\'.';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      'A perplexidade não foi considerada neste documento: o modelo de perplexidade (DistilGPT2) foi treinado apenas em inglês e, em texto chinês, japonês ou coreano, mede a previsibilidade dos bytes, não a do idioma. Medido em dados rotulados, separa a escrita humana da de IA em 0% dos casos, portanto contabilizá-lo apenas geraria falsos positivos.';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return 'Base por idioma: $breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return 'Há $count amostra(s) anteriores sem marcação de idioma que não podem entrar na base de nenhum idioma — o texto original não é guardado, portanto o idioma não pode ser recuperado depois. Serão substituídas conforme novas análises.';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return 'Este documento passou a usar «$variant»: a variante que você escolheu não é validada para $language, e esta é.';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '«$variant» é multilíngue mas não foi validado em $language; trate a pontuação como evidência mais fraca do que num idioma validado.';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '«$variant» não cobre $language. A pontuação é apenas informativa e não deve ser lida como evidência em nenhum sentido.';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      'A perplexidade não foi considerada: não foi possível determinar o idioma deste documento, portanto não há limite calibrado para comparação. Adivinhar um idioma aplicaria a escala errada — exatamente o erro que esta verificação evita.';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return 'A perplexidade não foi considerada: o modelo em uso («$model») ainda não tem limite medido para $language. Sem escala calibrada o valor bruto não significa nada, então é omitido em vez de adivinhado.';
  }

  @override
  String get inputNoEditingRecordHint =>
      'Este formato não traz registo de edição. PDFs, imagens e texto colado não guardam como foram escritos, portanto a análise assenta apenas em estatística de texto. Se conseguir obter o .docx, .odt ou .doc original, o seu histórico de edição é uma prova bem mais forte — e, ao contrário da estatística, não enfraquece à medida que os modelos melhoram.';

  @override
  String get reportLowScoreNotProofOfHuman =>
      'Uma pontuação baixa não confirma que uma pessoa escreveu isto. Sem provas de origem, este veredicto assenta apenas em estatística de texto, que sinaliza com fiabilidade a escrita formulaica mas não os textos bem escritos dos modelos atuais.';

  @override
  String get reportProvenanceContradictsLowScore =>
      'O próprio registo de edição do ficheiro contradiz esta pontuação baixa. As provas de origem não enfraquecem à medida que os modelos melhoram, ao passo que a estatística de texto não identifica textos bem escritos dos modelos atuais. Leia primeiro as provas de origem abaixo antes de concluir algo a partir da pontuação.';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$paragraphs de $total parágrafos pertencem a um único lote de edição e contêm $percent% das palavras — compatível com esse bloco ter sido escrito ou colado de uma só vez, ainda que o ficheiro tenha outros lotes de edição.';
  }

  @override
  String findingEvasionDetected(int count) {
    return 'Foram encontradas $count marcas de evasão ao nível do carácter (caracteres de largura zero, letras de aparência idêntica ou controlos de direção). As ferramentas de escrita normais não produzem isto — alguém processou o texto para iludir a deteção.';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return 'Das $total obras citadas, $notFound não foram encontradas em nenhuma das bases de dados consultadas. Citações inventadas são um comportamento dos modelos de linguagem e, ao contrário do estilo, a existência de um artigo é um facto verificável.';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return 'As $total obras citadas foram todas localizadas em bases de dados públicas.';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return 'O ficheiro regista $minutes minutos de edição ao longo de $revisions gravações, compatível com o texto ter sido escrito neste documento.';
  }

  @override
  String get reportVerifiableFindingsTitle => 'O que pode ser verificado';

  @override
  String get reportVerifiableFindingsSubtitle =>
      'Cada item abaixo pode ser verificado de forma independente. Ao contrário de uma probabilidade, não enfraquecem à medida que os modelos melhoram.';

  @override
  String findingBulkPaste(int characters) {
    return 'Durante a escrita foi registada uma única colagem de $characters caracteres. Um modelo de linguagem não pode falsificar como o texto surge num editor — este bloco não foi escrito aqui.';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return 'O texto foi escrito nesta aplicação ao longo de $minutes minutos, com $deleted caracteres revistos. A escrita que acontece aqui deixa um registo que nenhum modelo consegue reproduzir.';
  }

  @override
  String get evidenceMatrixTitle => 'Multi-evidence assessment';

  @override
  String get evidenceMatrixSubtitle =>
      'Six axes are shown separately. Only authorship-specific evidence affects the author verdict; coverage shows what could be examined.';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return 'Evidence coverage: $available of $total axes';
  }

  @override
  String get evidenceAxisText => 'Text-generation traces';

  @override
  String get evidenceAxisTextNote =>
      'Probabilistic patterns from the four local detectors';

  @override
  String get evidenceAxisProcess => 'Writing process';

  @override
  String get evidenceAxisProcessNote =>
      'Typing, revision and paste events recorded without storing their content';

  @override
  String get evidenceAxisOrigin => 'Document origin';

  @override
  String get evidenceAxisOriginNote =>
      'Editing time, saves and DOCX/ODT/RSID metadata';

  @override
  String get evidenceAxisSources => 'Claim and source integrity';

  @override
  String get evidenceAxisSourcesNote =>
      'Checkable claims, citation anchors and bibliographic verification';

  @override
  String get evidenceStateUnavailable => 'Unavailable';

  @override
  String get evidenceStateInconclusive => 'Inconclusive';

  @override
  String get evidenceStateReassuring => 'Consistent';

  @override
  String get evidenceStateConcern => 'Review';

  @override
  String get evidenceStrengthNone => 'No evidence';

  @override
  String get evidenceStrengthLimited => 'Limited';

  @override
  String get evidenceStrengthModerate => 'Moderate';

  @override
  String get evidenceStrengthStrong => 'Strong';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      'Only the text-pattern axis was available. Current-generation AI can imitate human prose, so this report cannot establish authorship from the score alone.';

  @override
  String get evidenceMatrixStrongConcern =>
      'At least one independent axis contains a strong review signal. Inspect that evidence before relying on the text score.';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return '$unsupported of $total checkable claims contain numbers, comparisons or research attributions without a source anchor in the same sentence. This does not prove they are false, but identifies the claims that need verification first.';
  }

  @override
  String get challengeTitle => 'Supervised follow-up';

  @override
  String get challengeSubtitle =>
      'Ask the writer to explain specific claims from this document';

  @override
  String get challengeCaveat =>
      'Use this while the writer is present. The check only measures whether an answer engages with the document and whether it was pasted; passing is not proof of identity or authorship.';

  @override
  String challengeExplainQuestion(String excerpt) {
    return 'Explain this passage in your own words and state why it matters: “$excerpt”';
  }

  @override
  String challengeJustifyQuestion(String excerpt) {
    return 'What evidence or reasoning supports this claim, and what would weaken it? “$excerpt”';
  }

  @override
  String get challengeAnswerHint => 'Answer here without pasting prepared text';

  @override
  String get challengeEvaluate => 'Check response';

  @override
  String get challengeStateUnanswered => 'Not checked';

  @override
  String get challengeStateInsufficient => 'Needs a more specific answer';

  @override
  String get challengeStateGrounded => 'Directly engages with the passage';

  @override
  String get challengeStatePasted =>
      'Large paste detected; repeat under supervision';

  @override
  String get integratedAssessmentTitle => 'Integrated authorship assessment';

  @override
  String get integratedLikelyAi => 'More likely AI-generated';

  @override
  String get integratedLikelyMixed => 'More likely human-AI mixed';

  @override
  String get integratedLikelyHuman => 'More likely not AI-generated';

  @override
  String get integratedBalanced => 'AI and human signals are balanced';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'Integrated AI likelihood: $percent%';
  }

  @override
  String integratedTextScoreLabel(int percent) {
    return 'Text-model score: $percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return 'Confidence: $confidence';
  }

  @override
  String get integratedConfidenceLow => 'Low';

  @override
  String get integratedConfidenceModerate => 'Moderate';

  @override
  String get integratedConfidenceHigh => 'High';

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return 'Independent evidence families: $families/4 · applicability coverage $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'AI evidence gate: passed';

  @override
  String get integratedEvidenceGateNotPassed =>
      'AI evidence gate: not passed · directional screening only';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason The system still gives the most likely direction, but confidence is reduced; treat it as a screening result, not proof.';
  }

  @override
  String get integratedIndexCaveat =>
      'The separate AI evidence gate indicates whether independent support is strong enough for escalation. Citation quality, paste behavior, and suspicious metadata cannot independently produce an AI verdict. This is an evidence score, not a calibrated statistical probability.';

  @override
  String get reportTextEngineSignalExplanation =>
      'These bars show diagnostic signals from the four text engines. The final text score first merges correlated engines into independent evidence families and applies language/domain applicability and calibration reliability. The separate AI evidence gate indicates whether support is strong enough for escalation; ‘not detected’ is not proof of human authorship.';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return 'Four-engine text-model raw score: $percent%. This is one input to the integrated assessment, not a second verdict.';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return 'Strongest text-engine signal: $label ($percent%). It can influence the text-model score but cannot override the integrated assessment by itself.';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'The text-model raw score is $aiPercent%, reaching the $thresholdPercent% diagnostic marker. This is a text-signal observation only; the integrated assessment above remains the report\'s authorship direction.';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'The text-model raw score is $aiPercent%, below the $thresholdPercent% diagnostic marker. Missing that marker is not evidence of human authorship; the integrated assessment above remains the report\'s authorship direction.';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return 'After weighting the available evidence, the document is “$direction” (AI likelihood index $percent%, $confidence confidence).';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return 'Segment stability $percent% · interval $lower–$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return 'Input extraction quality: $percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return 'Matched local baseline: p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return 'Expected confidence ceiling: $level';
  }

  @override
  String get analysisReadinessShortText => 'more text needed';

  @override
  String get analysisReadinessFewSentences => 'too few segments';

  @override
  String get analysisReadinessCoreModel => 'core classifier unavailable';

  @override
  String get analysisReadinessFewEngines => 'fewer than two engines enabled';

  @override
  String get analysisReadinessExtraction => 'extraction quality is limited';

  @override
  String get analysisReadinessBaseline => 'no matched local baseline';
}
