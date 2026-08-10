# TruthLens — Guide de démarrage rapide（Français）

**Objectif**：Terminer votre première analyse de document en 5 minutes

---

## 1️⃣ Ouvrez l'application

### Option A：Version web（recommandée）
```
Navigateur：https://truthlens.vercel.app
Appareils：Ordinateur, tablette ou téléphone
```
✅ Aucune installation requise  
✅ Disponible hors ligne après téléchargement des modèles  
✅ 100% de confidentialité garantie

### Option B：Développement local
```bash
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens
flutter pub get
flutter run -d web-server
# Ouvre sur http://localhost:8765
```

---

## 2️⃣ Téléchargez les modèles de détection IA（une seule fois）

Lorsque vous ouvrez l'application, un panneau de configuration s'affiche：

```
┌─ Installation des modèles ─────────┐
│ Détecteur RoBERTa (125,8 MB)      │
│ └─ [Télécharger] ✓ Installé       │
│                                    │
│ Détecteur multilingue (135 MB)    │
│ └─ [Télécharger] ✓ Installé       │
│                                    │
│ Moteur statistique (82 MB)        │
│ └─ [Télécharger] Optionnel        │
│                                    │
│ Défense adversariale (135 MB)     │
│ └─ [Télécharger] Optionnel        │
│                                    │
│ Génération de rapports LLM (1,7 GB)│
│ └─ [Télécharger] Optionnel        │
└────────────────────────────────────┘
```

**⏱️ Configuration initiale**：Environ 3 minutes（selon la vitesse internet）

**Qu'est-ce qui est téléchargé？**
- Modèles de détection principaux：~350 MB（obligatoire）
- LLM pour meilleure génération de rapports：~1,7 GB（optionnel）

**Après téléchargement**：Toutes les analyses s'exécutent entièrement hors ligne！✅

---

## 3️⃣ Téléchargez un fichier ou collez du texte

### Méthode 1：Coller du texte
```
1. Cliquez sur 「Coller du texte」
2. Appuyez sur Ctrl+V（ou Cmd+V）pour coller
3. Recommandé：Au minimum 100 caractères
```

### Méthode 2：Télécharger un fichier
```
Formats supportés：
• .txt（fichier texte）
• .docx（fichier Word）
• .pdf（fichier PDF avec OCR）
```

### Méthode 3：Utiliser l'appareil photo（mobile）
```
1. Appuyez sur l'icône de l'appareil photo
2. Prenez une photo de votre travail manuscrit
3. L'OCR convertit automatiquement image → texte
```

---

## 4️⃣ Commencez l'analyse

Cliquez sur le bouton bleu **「Analyser」**

```
Statut：[████░░░░░░░░░░░░] 25% en cours d'analyse...
（généralement 2～10 secondes, selon la longueur du texte）
```

---

## 5️⃣ Consultez le rapport

### Section supérieure：**Carte de synthèse du verdict**
```
╔════════════════════════════════════╗
║  Verdict：Probablement généré par IA ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ║
║  Probabilité IA：72%                ║
║  Confiance：Élevée ✓               ║
╚════════════════════════════════════╝
```

**📌 Signification**：
- **Verdict**：Jugement global（humain / probablement humain / mixte / probablement IA / IA）
- **Probabilité**：Degré de confiance en la génération par IA（0～100%）
- **Confiance**：Si tous les moteurs de détection sont d'accord

---

### Section du milieu：**Cartes de métriques 3 colonnes**
```
┌──────────────┬──────────────┬──────────────┐
│  Ratio IA    │ Temps analyse│  Confiance   │
│  ────────    │ ────────     │  ────────   │
│  8/45 (18%)  │  2,3 sec     │  92%        │
└──────────────┴──────────────┴──────────────┘
```

**📌 Signification**：
- **Ratio IA**：Combien de phrases ont été marquées comme IA（8 sur 45）
- **Temps analyse**：Temps d'analyse
- **Confiance**：Fiabilité du résultat global

---

### Section inférieure：**Liste des phrases suspectes**
```
【Phrase #1】（page 3）Risque：Élevé 🔴 | Confiance 85%
  "Le changement de paradigme synergique permet..."
  Raison：Similitude élevée, complexité inhabituelle du vocabulaire, motif rythmique

【Phrase #2】（page 5）Risque：Moyen 🟡 | Confiance 72%
  "Les algorithmes d'apprentissage automatique ont lancé la révolution..."
  Raison：Écart statistique, faible diversité du vocabulaire
```

**📌 Comment lire**：
- **Numéro de page**：Position dans le document
- **Couleur de risque**：Rouge（risque élevé）, jaune（risque moyen）, bleu（risque faible）
- **Pourcentage IA**：Probabilité que ce soit une IA（0～100%）
- **Raison**：Pourquoi le modèle a marqué cette phrase

---

## 6️⃣ Interprétez les résultats（Pour les enseignants）

### Scénario A：Probabilité IA globale > 80%
```
⚠️ Preuves solides d'utilisation de l'IA
→ Action：Examinez de près les phrases suspectes
→ Suivant：Discutez avec l'étudiant pour voir si la politique permet l'IA
```

### Scénario B：Probabilité IA 50～80%
```
🤔 Signaux mixtes; certains paragraphes sont suspects
→ Action：Concentrez-vous sur les phrases marquées en rouge
→ Suivant：Vérifiez si elles correspondent au style typique de l'étudiant
```

### Scénario C：Probabilité IA < 30%
```
✅ Semble être du travail authentique de l'étudiant
→ Action：Envisagez de l'accepter ou vérifiez quelques phrases
→ Note：Les textes humains peuvent aussi avoir des faux positifs
```

---

## 7️⃣ Téléchargez et partagez les résultats

### Options d'exportation
```
1. [📄 Télécharger PDF]    → Rapport complet avec tous les détails
2. [📊 Exporter CSV]       → Pour feuille de calcul de notation
3. [📋 Copier résultats]   → Pour coller dans email/LMS
```

**Le PDF inclut**：
- Synthèse du verdict
- Métriques détaillées
- Toutes les phrases suspectes et raisons
- Numéros de page pour référence facile

---

## ⚙️ Personnalisez les paramètres（optionnel）

Panneau droit：Cliquez sur **⚙️ icône d'engrenage**

| Paramètre | Par défaut | Fonction |
|----------|----------|----------|
| Télécharger modèles | Automatique | Retélécharge les modèles de détection |
| Vérifier liens | Activé | Vérifie si les URLs existent vraiment |
| Valider DOI | Activé | Vérifie si les citations existent（Crossref） |
| Langue | Automatique | Change la langue de l'interface（14 supportées） |
| Politique de confidentialité | — | Lisez la garantie 「zéro téléchargement」 |

---

## 🆘 Problèmes courants et solutions

### Problème：「Échec du téléchargement du modèle」
```
❌ Erreur：Impossible de télécharger le modèle RoBERTa
✅ Solution：
  1. Vérifiez votre connexion Internet
  2. Désactivez VPN/proxy
  3. Attendez 5 minutes et réessayez
  4. Videz le cache du navigateur（Ctrl+Shift+Del）
```

### Problème：「L'analyse est très lente」
```
❌ Vous attendez plus de 30 secondes
✅ Solution：
  1. La première exécution est lente（chargement des modèles en RAM）
  2. Les exécutions suivantes prennent 2～5 secondes
  3. Fermez les autres onglets du navigateur
  4. Redémarrez le navigateur s'il reste lent
```

### Problème：「Le navigateur dit 'mémoire insuffisante'」
```
❌ Erreur：Impossible d'allouer la mémoire
✅ Solution：
  1. Au moins 2 GB de RAM libre requis
  2. Fermez les autres applications
  3. Actualisez la page（Cmd/Ctrl + R）
  4. Essayez sur un ordinateur de bureau
```

---

## ✅ Prochaines étapes

### Pour les enseignants
1. ✅ Téléchargez les modèles
2. ✅ Testez avec 1～2 documents d'exemple
3. ✅ Familiarisez-vous avec le format du rapport
4. ✅ Créez une grille de notation basée sur les scores de détection IA
5. ✅ Distribuez les directives de classe

### Pour les administrateurs scolaires
1. ✅ Déployez sur le serveur scolaire（optionnel, pour utilisation hors ligne）
2. ✅ Créez un manuel pour les enseignants
3. ✅ Formez le personnel à l'utilisation de l'outil
4. ✅ Établissez une politique d'intégrité académique avec détection IA

### Pour les développeurs
1. ✅ Voir [CLAUDE.md](../CLAUDE.md) pour configuration
2. ✅ Voir [docs/implementation_plan.md](./implementation_plan.md) pour architecture
3. ✅ Voir [docs/model_integration_testing.md](./model_integration_testing.md) pour détails des modèles

---

## 📚 Ressources supplémentaires

| Ressource | Objectif |
|-----------|----------|
| [Documentation complète](./implementation_plan.md) | Approfondissez toutes les fonctionnalités |
| [Politique de confidentialité](https://truthlens.vercel.app/#/privacy) | Vérifiez comment nous protégeons vos données |
| [Liste des modèles](./model_integration_testing.md) | Détails techniques de chaque modèle IA |
| [Questions fréquentes](./faq-fr.md) | Réponses aux questions courantes |
| [Dépannage](./troubleshooting-fr.md) | Méthodes de dépannage plus détaillées |

---

## 💬 Vous avez des questions ou des commentaires？

- **Vous avez trouvé un bug？** → [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Demande de fonctionnalité？** → [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **Autres questions？** → hauchieh.lin@gmail.com

---

**Prêt à analyser？** → [Ouvrez TruthLens maintenant！](https://truthlens.vercel.app)
