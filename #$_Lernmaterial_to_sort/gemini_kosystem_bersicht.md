# Leitfaden: Gemini Ökosystem, AI Pro Abo, AI Studio & API

Dieser Leitfaden gibt eine strukturierte Übersicht über die Unterschiede zwischen dem Endanwender-Abonnement (AI Pro), den Modelltypen sowie der Entwickler-Plattform (Google AI Studio & Gemini API).

---

## 1. Grundlegendes Missverständnis: AI Pro Abo vs. API

Es handelt sich um zwei getrennte Produkt- und Abrechnungswelten:

```
┌─────────────────────────────────────────────────────────────┐
│                       GOOGLE GEMINI                         │
├──────────────────────────────┬──────────────────────────────┤
│    Endanwender-Welt          │       Entwickler-Welt        │
│   (gemini.google.com)        │    (aistudio.google.com)     │
├──────────────────────────────┼──────────────────────────────┤
│ • AI Pro / Google One Abo    │ • Google AI Studio & API     │
│ • Feste monatliche Gebühr    │ • Free Tier oder Pay-as-you-go│
│ • Grafisches Chatfenster     │ • Eigene Programme & Skripte │
│ • Workspace-Integration      │ • System-Prompts & JSON-Mode │
│ • Kein API-Guthaben          │ • API-Keys zur Integration   │
└──────────────────────────────┴──────────────────────────────┘
```

> **Wichtig:** Das AI Pro Abo schaltet **kein Guthaben** für die Gemini API oder Drittanbieter-Tools frei. Die API wird separat über Google AI Studio (kostenlos im Rahmen der Free-Tier-Limits) oder Google Cloud Billing (Pay-as-you-go) verwaltet.

---

## 2. Modelle und Kapazitäten im AI Pro Abo

Im Web-Interface (`gemini.google.com`) wird die Nutzung über dynamische Rechenkontingente (**Compute Caps**) gesteuert, nicht über starre Wort- oder Zeichenlimits.

| Modell / Werkzeug | Typischer Einsatzzweck | Nutzungsvolumen (AI Pro) |
| :--- | :--- | :--- |
| **Gemini Pro** | Komplexe Aufgaben, Coding, Textanalysen, multimodale Eingaben (große Kontexte bis 1M+ Token). | **Sehr hoch (Prioritärer Zugriff):** Rollierendes 5-Stunden-Fenster. Bei Erschöpfung greift automatisch der Fallback auf Flash. |
| **Gemini Flash** | Schnelle Routineaufgaben, Chat-Interaktionen, minimale Latenz. | **Praktisch unbegrenzt:** Dient als ungedrosselter Standard- oder Fallback-Kanal. |
| **Deep Think Engine** | Extrem anspruchsvolle Logik, mathematische Beweise, Systemarchitektur. | **Kontingentiert:** Tägliches Budget (typisch ca. 10 Prompts/Tag) aufgrund hoher Rechenzeit pro Durchlauf. |
| **Deep Research** | Autonome Web- und Dokumentenrecherche über hunderte Quellen. | **Geteiltes Kontingent:** Mehrere umfangreiche Research-Berichte pro Tag/Woche. |
| **Generative Medien** (Imagen, Veo, Lyria) | Bildgenerierung, KI-Videoclips und Audiokomposition. | **Kontingentpool:** Bilder sehr großzügig bemessen; Video und Audio teilen sich ein Rechenzeit-Budget. |

### Funktionsweise der Compute Caps:
* **Token-Abhängigkeit:** Ein Prompt mit einer hochgeladenen 300-Seiten-PDF oder einem Repository verbraucht spürbar mehr vom 5-Stunden-Budget als eine einfache Textfrage.
* **Kein harter Stopp:** Wenn das Pro-Limit erreicht wird, bricht die Arbeit nicht ab; das System wechselt nahtlos zu Flash, bis das Zeitfenster regeneriert ist.

---

## 3. Was ist Google AI Studio (der „Playground“)?

**Google AI Studio** (`aistudio.google.com`) ist eine webbasierte Entwicklungsumgebung für Entwickler und Techniker, um Prompts zu testen und Schnittstellen vorzubereiten.

### Kernfunktionen des Playgrounds:
1. **System Instructions:** Festlegen einer festen Identität, Verhaltensregeln oder Programmierstandards vor dem eigentlichen Benutzer-Prompt.
2. **Hyperparameter steuern:**
   * **Temperatur:** Wert von `0.0` (absolut deterministisch, ideal für Code/JSON) bis `1.0`+ (kreativ, abwechslungsreich).
   * **Top-P / Top-K:** Beeinflusst die Auswahlwahrscheinlichkeit der nächsten Tokens.
3. **Structured Outputs (JSON Mode):** Das Modell wird über ein Schema dazu gezwungen, ausschließlich valides JSON zurückzugeben (perfekt für Daten-Pipelines).
4. **Get Code:** Jeder funktionierende Test im Playground kann direkt als Quellcode (Python, JavaScript, cURL/REST) exportiert werden.
5. **Riesige Kontextfenster:** Testen mit Codebases, vollständigen Büchern oder langen Videos (bis zu 2 Millionen Tokens).

---

## 4. API-Abrechnung: Free Tier vs. Paid Tier

Wenn man die API über AI Studio anspricht, gelten folgende Abrechnungsmodelle:

| Merkmal | Free Tier | Paid Tier (Pay-as-you-go) |
| :--- | :--- | :--- |
| **Kosten** | 0 € (Kostenlos) | Cent-Beträge pro 1 Million Tokens |
| **Kreditkarte nötig?** | Nein | Ja (Google Cloud Billing verknüpft) |
| **Ratenlimits** | RPM (Requests/Min), TPM (Tokens/Min) & RPD (Requests/Tag) | Deutlich höhere Ratenlimits für Produktionsbetrieb |
| **Datenschutz** | Eingaben können zur Verbesserung der Modelle verwendet werden | Eingegebene Daten werden **nicht** für das Modelltraining verwendet |
| **Empfohlener Zweck**| Prototyping, private Skripte, lokale Experimente | Produktive Unternehmensanwendungen, sensible Daten |

---

## 5. Typische Workflows im Überblick

* **Für den Alltag (AI Pro):** Du chattest im Browser, lässt dir Konzepte erklären, nutzt Deep Research für Marktübersichten oder lässt Dokumente in Google Docs überarbeiten.
* **Für Entwickler (AI Studio & API):**
  1. Du öffnest AI Studio und definierst das Ausgabeformat (z. B. JSON).
  2. Du optimierst deinen Prompt im Playground mit Temperatur `0.0`.
  3. Du klickst auf **Get Code**, kopierst den Request in dein Programm (z. B. C#, Python) und bindest einen API-Key ein.
  4. Dein Programm analysiert automatisch Dateien, Logs oder Datenströme im Hintergrund.