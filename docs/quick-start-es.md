# TruthLens — Guía de Inicio Rápido（Español）

**Objetivo**：Completar tu primer análisis de documento en 5 minutos

---

## 1️⃣ Abre la aplicación

### Opción A：Versión web（recomendado）
```
Navegador：https://truthlens.vercel.app
Dispositivo：Escritorio, tablet o móvil
```
✅ No requiere instalación  
✅ Disponible sin conexión tras descargar modelos  
✅ 100% privacidad garantizada

### Opción B：Desarrollo local
```bash
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens
flutter pub get
flutter run -d web-server
# Se abre en http://localhost:8765
```

---

## 2️⃣ Descarga los modelos de detección AI（solo la primera vez）

Cuando abres la app, aparece un panel de configuración：

```
┌─ Instalación de modelos ─────────┐
│ Detector RoBERTa (125,8 MB)      │
│ └─ [Descargar] ✓ Instalado      │
│                                   │
│ Detector multilingüe (135 MB)    │
│ └─ [Descargar] ✓ Instalado      │
│                                   │
│ Motor estadístico (82 MB)        │
│ └─ [Descargar] Opcional         │
│                                   │
│ Defensa adversarial (135 MB)     │
│ └─ [Descargar] Opcional         │
│                                   │
│ Generación de reportes LLM (1.7 GB)│
│ └─ [Descargar] Opcional         │
└────────────────────────────────────┘
```

**⏱️ Configuración inicial**：Aprox. 3 minutos（depende de la velocidad de internet）

**¿Qué se descarga？**
- Modelos de detección principales：~350 MB（requerido）
- LLM para mejor generación de reportes：~1,7 GB（opcional）

**Después de descargar**：¡Todos los análisis se ejecutan completamente sin conexión！✅

---

## 3️⃣ Sube un archivo o pega texto

### Método 1：Pegar texto
```
1. Haz clic en 「Pegar texto」
2. Presiona Ctrl+V（o Cmd+V）para pegar
3. Recomendado：Mínimo 100 caracteres
```

### Método 2：Subir archivo
```
Formatos soportados：
• .txt（archivo de texto）
• .docx（archivo Word）
• .pdf（archivo PDF con OCR）
```

### Método 3：Usar cámara（móvil）
```
1. Toca el icono de cámara
2. Toma una foto de tu trabajo escrito a mano
3. OCR convierte automáticamente imagen → texto
```

---

## 4️⃣ Inicia el análisis

Haz clic en el botón azul **「Analizar」**

```
Estado：[████░░░░░░░░░░░░] 25% analizando...
（típicamente 2～10 segundos, según la longitud del texto）
```

---

## 5️⃣ Revisa el reporte

### Sección superior：**Tarjeta de resumen de veredicto**
```
╔════════════════════════════════════╗
║  Veredicto：Probablemente AI-generado ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ║
║  Probabilidad AI：72%               ║
║  Confianza：Alta ✓                 ║
╚════════════════════════════════════╝
```

**📌 Significado**：
- **Veredicto**：Juicio general（humano / probablemente humano / mixto / probablemente AI / AI）
- **Probabilidad**：Confianza en generación por AI（0～100%）
- **Confianza**：Si todos los motores de detección están de acuerdo

---

### Sección media：**Tarjetas de métricas de 3 columnas**
```
┌──────────────┬──────────────┬──────────────┐
│  Ratio AI    │ Tiempo análisis│  Confianza  │
│  ────────    │ ────────      │  ────────   │
│  8/45 (18%)  │  2,3 seg      │  92%        │
└──────────────┴──────────────┴──────────────┘
```

**📌 Significado**：
- **Ratio AI**：Cuántas oraciones se marcaron como AI（8 de 45）
- **Tiempo análisis**：Tiempo de escaneo
- **Confianza**：Fiabilidad del resultado general

---

### Sección inferior：**Lista de oraciones sospechosas**
```
【Oración #1】（página 3）Riesgo：Alto 🔴 | Confianza 85%
  "El cambio de paradigma sinérgico permite..."
  Razón：Similitud alta, complejidad de vocabulario inusual, patrón rítmico

【Oración #2】（página 5）Riesgo：Medio 🟡 | Confianza 72%
  "Los algoritmos de aprendizaje automático iniciaron la revolución..."
  Razón：Desviación estadística, baja diversidad de vocabulario
```

**📌 Cómo leer**：
- **Número de página**：Posición en el documento
- **Color de riesgo**：Rojo（riesgo alto）, amarillo（riesgo medio）, azul（riesgo bajo）
- **Porcentaje AI**：Probabilidad de que sea AI（0～100%）
- **Razón**：Por qué el modelo marcó esa oración

---

## 6️⃣ Interpreta los resultados（Para maestros）

### Escenario A：Probabilidad total de AI > 80%
```
⚠️ Evidencia sólida de uso de AI
→ Acción：Examina de cerca las oraciones sospechosas
→ Siguiente：Conversa con el estudiante sobre si la política permite AI
```

### Escenario B：Probabilidad de AI 50～80%
```
🤔 Señales mixtas; algunos párrafos son sospechosos
→ Acción：Enfócate en las oraciones marcadas en rojo
→ Siguiente：Verifica si coinciden con el estilo típico del estudiante
```

### Escenario C：Probabilidad de AI < 30%
```
✅ Parece trabajo auténtico del estudiante
→ Acción：Considera aprobarlo o revisa algunas oraciones
→ Nota：Los textos humanos también pueden tener falsos positivos
```

---

## 7️⃣ Descarga y comparte resultados

### Opciones de exportación
```
1. [📄 Descargar PDF]      → Reporte completo con todos los detalles
2. [📊 Exportar CSV]       → Para hoja de cálculo de calificación
3. [📋 Copiar resultados]  → Para pegar en email/LMS
```

**El PDF incluye**：
- Resumen del veredicto
- Métricas detalladas
- Todas las oraciones sospechosas y razones
- Números de página para fácil referencia

---

## ⚙️ Personaliza la configuración（opcional）

Panel derecho：Haz clic en **⚙️ icono de engranaje**

| Configuración | Por defecto | Función |
|-----------|----------|----------|
| Descargar modelos | Automático | Redescarga modelos de detección |
| Verificar enlaces | Activado | Verifica si las URLs existen realmente |
| Validar DOI | Activado | Verifica si existen las citas（Crossref） |
| Idioma | Automático | Cambia idioma UI（14 soportados） |
| Política de privacidad | — | Lee la garantía 「cero envío」 |

---

## 🆘 Problemas comunes y soluciones

### Problema：「Descarga de modelo falló」
```
❌ Error：No se puede descargar el modelo RoBERTa
✅ Solución：
  1. Verifica conexión a internet
  2. Desactiva VPN/proxy
  3. Espera 5 minutos e intenta de nuevo
  4. Limpia caché del navegador（Ctrl+Shift+Del）
```

### Problema：「El análisis es muy lento」
```
❌ Esperas más de 30 segundos
✅ Solución：
  1. La primera ejecución es lenta（cargando modelos en RAM）
  2. Ejecuciones posteriores tardan 2～5 segundos
  3. Cierra otras pestañas del navegador
  4. Reinicia navegador si sigue lento
```

### Problema：「Navegador dice 'memoria insuficiente'」
```
❌ Error：No se puede asignar memoria
✅ Solución：
  1. Se requieren al menos 2 GB de RAM libre
  2. Cierra otras aplicaciones
  3. Recarga la página（Cmd/Ctrl + R）
  4. Intenta en una computadora de escritorio
```

---

## ✅ Próximos pasos

### Para maestros
1. ✅ Descarga los modelos
2. ✅ Prueba con 1～2 documentos de ejemplo
3. ✅ Familiarízate con el formato del reporte
4. ✅ Crea una rúbrica de calificación basada en scores de detección AI
5. ✅ Distribuye pautas de clase

### Para administradores escolares
1. ✅ Despliega en servidor escolar（opcional, para uso sin conexión）
2. ✅ Crea manual para maestros
3. ✅ Entrena personal en uso de herramienta
4. ✅ Establece política de integridad académica con detección AI

### Para desarrolladores
1. ✅ Ver [CLAUDE.md](../CLAUDE.md) para configuración
2. ✅ Ver [docs/implementation_plan.md](./implementation_plan.md) para arquitectura
3. ✅ Ver [docs/model_integration_testing.md](./model_integration_testing.md) para detalles de modelos

---

## 📚 Recursos adicionales

| Recurso | Propósito |
|---------|----------|
| [Documentación completa](./implementation_plan.md) | Profundiza en todas las características |
| [Política de privacidad](https://truthlens.vercel.app/#/privacy) | Verifica cómo protegemos datos |
| [Lista de modelos](./model_integration_testing.md) | Detalles técnicos de cada modelo AI |
| [Preguntas frecuentes](./faq-es.md) | Respuestas a preguntas comunes |
| [Solución de problemas](./troubleshooting-es.md) | Métodos de solución más detallados |

---

## 💬 ¿Tienes preguntas o comentarios？

- **¿Encontraste un error？** → [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **¿Solicitud de características？** → [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **¿Otras preguntas？** → hauchieh.lin@gmail.com

---

**¿Listo para analizar？** → [¡Abre TruthLens ahora！](https://truthlens.vercel.app)
