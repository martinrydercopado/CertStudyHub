const fs = require("fs");
const { Document, Packer, Paragraph, TextRun, AlignmentType, HeadingLevel, LevelFormat,
        Header, Footer, PageNumber, ExternalHyperlink, PageBreak, Table, TableRow, TableCell,
        BorderStyle, WidthType, ShadingType, VerticalAlign } = require("docx");

// ─── Helpers ───
const h1 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(text)] });
const h2 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(text)] });
const h3 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun(text)] });
const p = (...runs) => new Paragraph({ spacing: { after: 120 }, children: runs });
const txt = (text) => new TextRun(text);
const bold = (text) => new TextRun({ text, bold: true });
const italic = (text) => new TextRun({ text, italics: true });
const blank = () => new Paragraph({ spacing: { after: 60 }, children: [] });
const pageBreak = () => new Paragraph({ children: [new PageBreak()] });

// ─── Build ───
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } },
    paragraphStyles: [
      { id: "Title", name: "Title", basedOn: "Normal",
        run: { size: 56, bold: true, color: "1B3A5C", font: "Arial" },
        paragraph: { spacing: { before: 240, after: 60 }, alignment: AlignmentType.CENTER } },
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, color: "1B3A5C", font: "Arial" },
        paragraph: { spacing: { before: 360, after: 200 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, color: "2D5F8A", font: "Arial" },
        paragraph: { spacing: { before: 240, after: 160 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 26, bold: true, color: "3A7AB5", font: "Arial" },
        paragraph: { spacing: { before: 180, after: 120 }, outlineLevel: 2 } },
    ]
  },
  numbering: {
    config: [
      { reference: "bullets",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "install-steps",
        levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets2",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets3",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets4",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets5",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets6",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets7",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets8",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets9",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets10",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets11",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "bullets12",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
    ]
  },
  sections: [{
    properties: {
      page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } }
    },
    headers: {
      default: new Header({ children: [new Paragraph({
        alignment: AlignmentType.RIGHT,
        children: [new TextRun({ text: "Cert Study Hub — Guide", italics: true, size: 18, color: "888888" })]
      })] })
    },
    footers: {
      default: new Footer({ children: [new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: "Page ", size: 18 }), new TextRun({ children: [PageNumber.CURRENT], size: 18 }),
                   new TextRun({ text: " of ", size: 18 }), new TextRun({ children: [PageNumber.TOTAL_PAGES], size: 18 })]
      })] })
    },
    children: [
      // ── Title Page ──
      new Paragraph({ heading: HeadingLevel.TITLE, children: [new TextRun("Cert Study Hub")] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 120 },
        children: [new TextRun({ text: "Installation, Features & Extension Guide", size: 28, color: "555555" })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 200 },
        children: [new TextRun({ text: "A native SwiftUI app for iPhone, iPad, and Mac", size: 22, italics: true, color: "777777" })] }),
      blank(),

      // Cert overview table
      certOverviewTable(),
      blank(),
      p(new TextRun({ text: "* AgentOps and Success Architect Scenarios are bonus study topics. They are not official Salesforce certifications.", italics: true, size: 20, color: "666666" })),
      blank(),

      // ── AI Content Note ──
      h1("A Note on AI-Generated Content"),
      p(txt("We want to be fully transparent about how the content in this app was created.")),
      p(bold("What was AI-generated:")),
      bullet("bullets", "Quiz questions and their answer options"),
      bullet("bullets", "Explanations for why each answer is correct or incorrect"),
      bullet("bullets", "Study topic descriptions and explanations"),
      bullet("bullets", "Some scenario details in quiz questions"),
      p(bold("What was verified:")),
      bullet("bullets2", "All AI-generated content was cross-checked with other AI models for accuracy"),
      bullet("bullets2", "Question structures align with the official Salesforce exam guide sections and weightings"),
      bullet("bullets2", "Passing scores match the official Salesforce certification requirements"),
      p(bold("What this means for you:")),
      p(txt("This app is a study tool designed to help you gauge your readiness and identify gaps in your knowledge. It is not a substitute for official Salesforce training. Some explanations may contain inaccuracies, and Salesforce frequently updates its platform and exam content.")),
      p(txt("Always use the following as your source of truth:")),
      bullet("bullets3", "Salesforce Trailhead \u2014 trailhead.salesforce.com"),
      bullet("bullets3", "Salesforce Help & Documentation \u2014 help.salesforce.com"),
      bullet("bullets3", "Salesforce Developer Documentation \u2014 developer.salesforce.com"),
      bullet("bullets3", "Official Exam Guides \u2014 available on the Salesforce certification website"),
      p(txt("If you find an answer or explanation that seems incorrect, check it against the official documentation. The purpose of this app is to help you discover what you know and what you need to study further \u2014 not to be the final word on any topic.")),

      // ── Quick Tour of Xcode ──
      h1("A Quick Tour of Xcode"),
      p(txt("Before diving into the steps, here is a cheat sheet for finding your way around Xcode\u2019s interface once a project is open:")),
      p(bold("Navigator (Left Sidebar): "), txt("This is where your project files live. Clicking a file here opens it in the center.")),
      p(bold("Editor (Center Area): "), txt("Where the actual code or visual layout is displayed.")),
      p(bold("Inspector (Right Sidebar): "), txt("Shows properties and settings for whatever file or UI element is currently selected.")),
      p(bold("Toolbar (Top Bar): "), txt("Holds the \u201CPlay\u201D (Run) and \u201CStop\u201D buttons, along with a dropdown menu to select which device you want to install the app on.")),

      // ── How to Install ──
      h1("How to Install and Run the App"),

      h2("1. Install Xcode"),
      p(txt("Requires a Mac and significant storage space. Open the Mac App Store, search for Xcode, and click Install. Note: Xcode is a massive application, so this step will take some time depending on internet speed.")),

      h2("2. Sign in with your Apple Account"),
      p(txt("Once Xcode is installed, open it.")),
      bullet("bullets4", "In the top menu bar, go to Xcode > Settings (or Preferences on older macOS versions)."),
      bullet("bullets4", "Click the Accounts tab at the top."),
      bullet("bullets4", "Click the + button in the bottom left, select Apple ID, and sign in with the same Apple account you use on your iPhone or iPad."),

      h2("3. Load the Project"),
      p(txt("Unzip the project files you received. Look for a file ending in .xcodeproj. Double-click this file to open the project in Xcode.")),

      h2("4. Configure App Signing"),
      p(txt("Apple requires all apps to be \u201Csigned\u201D by a developer before they can run on a device.")),
      bullet("bullets5", "In the Navigator (left sidebar), click the very top file (blue icon with the app\u2019s name)."),
      bullet("bullets5", "In the central Editor area, select your app\u2019s name under the Targets list."),
      bullet("bullets5", "Click the Signing & Capabilities tab."),
      bullet("bullets5", "Check Automatically manage signing."),
      bullet("bullets5", "In the Team dropdown, select your name (it will say Your Name (Personal Team))."),
      p(bold("Important: "), txt("The project has two targets (CertStudyHub for iOS and CertStudyHub-macOS for Mac). Repeat the signing steps for each target.")),

      h2("5. Enable Developer Mode (iOS/iPadOS 16+)"),
      bullet("bullets6", "Plug your iPhone or iPad into your Mac using a cable. If prompted, tap Trust This Computer."),
      bullet("bullets6", "On your device, go to Settings > Privacy & Security."),
      bullet("bullets6", "Scroll to the bottom and tap Developer Mode. Toggle it ON."),
      bullet("bullets6", "Your device will restart. After unlocking, confirm by tapping Turn On."),
      p(bold("Note for work-managed iPhones: "), txt("If your iPhone is managed by your company (MDM), the Developer Mode toggle will be locked. Use a personal iPhone or run the app on Mac instead.")),

      h2("6. Build and Run"),
      bullet("bullets7", "In the toolbar at the top, click the device name next to the Play button."),
      bullet("bullets7", "Select your plugged-in iPhone or iPad from the list."),
      bullet("bullets7", "Click the Play button (or press Cmd + R)."),

      h2("7. Trust Your Developer Profile"),
      bullet("bullets8", "On your iPhone/iPad, open Settings > General."),
      bullet("bullets8", "Tap VPN & Device Management."),
      bullet("bullets8", "Under \u201CDeveloper App,\u201D tap your Apple ID email."),
      bullet("bullets8", "Tap Trust. You can now open the app from your home screen."),

      h2("8. Running on Mac (Optional)"),
      p(txt("Select the CertStudyHub-macOS scheme from the toolbar dropdown and click Play. No Developer Mode or trust steps are needed on macOS.")),
      blank(),

      // ── 7-Day Expiration ──
      h1("Important: The 7-Day Expiration Rule"),
      p(txt("Because you are using a free \u201CPersonal Team\u201D account to sign the app, Apple places a restriction on the installation: the app will expire and refuse to open after 7 days.")),
      p(txt("When this happens, the app isn\u2019t deleted, and all study progress is preserved. iOS stores the app\u2019s code and data in separate containers. Reinstalling via Xcode replaces only the code and the expired certificate \u2014 your data is untouched.")),
      p(txt("To use the app again after it expires:")),
      bullet("bullets9", "Plug the device back into your Mac."),
      bullet("bullets9", "Open the project in Xcode."),
      bullet("bullets9", "Hit the Play button to reinstall."),
      p(txt("This resets the 7-day timer and the app picks up right where you left off. (Paid Apple Developer accounts, which cost $99/year, allow apps to stay active for a full year.)")),

      h2("Two Critical Rules to Protect Your Data"),
      p(bold("1. Do not delete the expired app from your device. "), txt("When the app expires, it will crash or refuse to open. This is normal. If you delete the app, iOS permanently erases all local study data with it. Leave the expired app and let Xcode overwrite it.")),
      p(bold("2. Keep the same Bundle Identifier. "), txt("Do not change the app\u2019s Bundle Identifier in Xcode. If it changes, Xcode treats it as a different app and installs a fresh copy without your data.")),

      h2("Built-In Expiration Warning"),
      bullet("bullets10", "A countdown banner appears on the home screen when 2 or fewer days remain."),
      bullet("bullets10", "Tapping the banner opens the Progress Backup screen."),
      bullet("bullets10", "The backup screen shows your estimated expiration date and a summary of tracked progress across all certifications."),

      h2("Backing Up Your Study Progress"),
      p(txt("Although reinstalling preserves your data automatically, the app includes an Export/Import feature as a safety net \u2014 useful if you need to delete the app, move to a new device, or want peace of mind.")),
      p(bold("To Export: "), txt("Tap the backup icon (\u21C5) in the top toolbar, then tap Export Progress. On iPhone, this opens the share sheet. On Mac, a Save dialog appears.")),
      p(bold("To Import: "), txt("After a fresh install, open the backup screen and tap Import Progress. Select the JSON file you previously exported.")),
      blank(),

      // ── App Features ──
      h1("App Features"),
      p(txt("Cert Study Hub consolidates five Salesforce certification study areas and two bonus topics into one unified experience.")),

      h2("Home Screen \u2014 Certification Picker"),
      p(txt("When you open the app, you see a card for each certification/topic. Each card shows the name, icon, number of quiz questions, number of study topics, and the passing score. Bonus topics are distinguished with an orange badge. Tap a card to enter that area\u2019s study experience.")),

      h2("Quiz Mode"),
      p(txt("Each certification has a multiple-choice quiz with configurable length. Options vary by certification:")),

      h3("Quiz Features"),
      bullet("bullets11", "Questions are randomly shuffled each time you start a quiz."),
      bullet("bullets11", "Supports single-choice, multi-select, and true/false question types. Multi-select questions tell you how many answers to choose."),
      bullet("bullets11", "After submitting each answer, you see instant feedback with color-coded results and detailed explanations."),
      bullet("bullets11", "A progress bar tracks your position and running score throughout the quiz."),
      bullet("bullets11", "Flag for Review: Flag any question during a quiz to revisit later. A badge shows the count, and a dedicated review screen lets you study flagged questions."),
      bullet("bullets11", "Results screen: Shows your final percentage with a circular score graphic, a grade, and whether you passed or failed."),
      bullet("bullets11", "Copy to clipboard: Copy any question, explanation, or full quiz results as formatted Markdown."),

      h2("Study Guide Mode"),
      p(txt("The Study Guide tab provides a deep-dive, topic-by-topic study experience organized in a three-level hierarchy: Sections \u2192 Objectives \u2192 Topics.")),
      bullet("bullets12", "Section Overview: Each certification is broken into exam guide sections, each with its own color, icon, and progress bar."),
      bullet("bullets12", "Objectives: Tapping a section reveals its learning objectives, each with its own progress indicator."),
      bullet("bullets12", "Topic Cards: Each objective contains study topics in a Q&A flashcard format. See the question first; tap to reveal the answer."),
      bullet("bullets12", "Self-Assessment: Mark each topic as Confident (\u2705), Needs Review (\u26A0\uFE0F), or Not Started. This drives the progress bars."),
      bullet("bullets12", "Needs Review List: A dedicated screen aggregates all topics flagged as \u201CNeeds Review\u201D across all sections."),
      bullet("bullets12", "Navigation: Swipe through topics, jump by index, or go back to the section/objective list."),

      h2("Quiz-Only Tracks"),
      p(txt("Some bonus topics (like Success Architect Scenarios) are quiz-only \u2014 they do not include a Study Guide tab. When you tap into a quiz-only track, you go straight to the quiz selection screen without a tab bar. This is ideal for scenario-based practice where the learning happens through the questions and explanations themselves.")),
      blank(),

      // ── Extending the App ──
      h1("Extending the App"),
      p(txt("The app is built with a modular architecture that makes it straightforward to add new certifications, questions, or study content.")),

      h2("Project Structure"),

      h2("Adding a New Certification"),
      bullet("bullets", "Create a question bank file (e.g., AdminQuestionBank.swift) containing an array of Question objects."),
      bullet("bullets", "Create a study bank file (e.g., AdminStudyBank.swift) containing an array of StudySection objects with objectives and topics. For quiz-only tracks, you can skip this step and pass an empty array for studySections."),
      bullet("bullets", "Add a new entry in CertCatalog.swift following the existing pattern \u2014 unique id, name, colors, quiz lengths, passing score, and references to your new banks."),
      bullet("bullets", "Add it to the CertCatalog.all array so it appears on the home screen."),
      bullet("bullets", "Add the new files to the Xcode project (drag them into the Data group in the Navigator, or update the project.pbxproj file)."),
      p(txt("That\u2019s it \u2014 the app automatically picks up new certifications from the catalog and creates all the UI for them.")),

      h2("Adding or Editing Questions"),
      p(txt("Quiz questions live in the question bank files as an array of Question objects. Each question has a unique id (string), question text, options as (letter, text) tuples, a questionType (.singleSelect, .multiSelect, or .trueFalse), correctIndices (0-based), and an explanation.")),
      p(txt("To add a question, append a new Question(...) entry to the array. To edit one, find it by its id and change the fields.")),
      blank(),

      // ── Using MeshMesh ──
      h1("Using MeshMesh to Extend the App"),
      p(txt("You don\u2019t need to know Swift to modify this app. MeshMesh can read the project files, understand the architecture, and make changes for you.")),

      h2("How to Give MeshMesh Context"),
      p(bold("Option 1: Upload the project as a reference. "), txt("Zip the project folder and upload it as a reference in your MeshMesh task. This gives full access to read, understand, and modify every file.")),
      p(bold("Option 2: Paste specific files. "), txt("For smaller changes, paste the contents of just the file you want changed into the chat.")),

      h2("Example Requests"),
      bullet("bullets2", "\u201CAdd 15 new questions about Flow Builder to the App Builder quiz\u201D"),
      bullet("bullets2", "\u201CCreate a new certification section for Salesforce Administrator\u201D"),
      bullet("bullets2", "\u201CUpdate question 42 \u2014 the correct answer should be B, not C\u201D"),
      bullet("bullets2", "\u201CAdd a dark mode toggle\u201D"),
      bullet("bullets2", "\u201CCreate a timed exam mode that limits the quiz to 60 minutes\u201D"),

      // ── Generating Questions ──
      h1("Generating Study Questions for New Certifications"),
      p(txt("If you want to add a new certification but can\u2019t find practice questions online, you can generate exam-realistic study questions using Slackbot. The following prompt template produces certification-style questions that are more rigorous than generic quiz trivia.")),
      p(txt("Copy everything in the box below into Slackbot, replacing [CERTIFICATION NAME] with your certification:")),

      // ── Prompt box ──
      promptBox(),

      h2("Tips for Using This Prompt"),
      bullet("bullets3", "Replace the placeholder with the exact certification title."),
      bullet("bullets3", "Paste the official exam guide\u2019s section weights into the same prompt for best results."),
      bullet("bullets3", "Generate in batches of 30\u201340 for large question banks to maintain quality."),
      bullet("bullets3", "Review and validate all generated questions against Salesforce documentation. AI-generated questions are a starting point \u2014 verify that the correct answers are truly correct."),
      bullet("bullets3", "Convert to app format: Ask Slackbot to convert reviewed questions into the app\u2019s Question(...) Swift format."),
    ]
  }]
});

function bullet(ref, text) {
  return new Paragraph({
    numbering: { reference: ref, level: 0 },
    spacing: { after: 60 },
    children: [new TextRun(text)]
  });
}

function promptBox() {
  const border = { style: BorderStyle.SINGLE, size: 1, color: "B0B0B0" };
  const borders = { top: border, bottom: border, left: border, right: border };
  const shading = { fill: "F5F5F5", type: ShadingType.CLEAR };
  const cellMargins = { top: 120, bottom: 120, left: 180, right: 180 };
  const bld = (text) => new TextRun({ text, bold: true, font: "Consolas", size: 20 });
  const mono = (text) => new TextRun({ text, font: "Consolas", size: 20 });
  const monoItalic = (text) => new TextRun({ text, font: "Consolas", size: 20, italics: true });
  const pp = (...runs) => new Paragraph({ spacing: { after: 100 }, children: runs });

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [new TableRow({
      children: [new TableCell({
        borders, shading, margins: cellMargins,
        children: [
          pp(bld("Salesforce Certification-Style Study Question Generator")),
          new Paragraph({ spacing: { after: 60 }, children: [] }),

          pp(bld("1. Context")),
          pp(mono("You are simulating an official Salesforce Certification exam item writer for the [CERTIFICATION NAME] exam. Generate [##] questions that match the real exam\u2019s tone, structure, and cognitive load \u2014 not generic quiz-style trivia. Base every question strictly on topics listed in the official exam guide\u2019s weighted sections for this certification; do not introduce content outside those objectives, and note which exam guide section each question maps to.")),
          new Paragraph({ spacing: { after: 60 }, children: [] }),

          pp(bld("2. Complexity")),
          pp(mono("Write scenario-based, architectural-reasoning questions \u2014 not definition recall. Each question should present a realistic customer/business scenario (a persona, a constraint, a business goal) and require the reader to reason about trade-offs, sequencing, or platform limits to pick the best answer, the way real exam items do. Avoid \u201Cwhat is X\u201D phrasing; prefer \u201CGiven this scenario, which approach/action/configuration should the [consultant/architect] recommend?\u201D")),
          pp(mono("Include a mix of question types:")),
          pp(mono("Most questions are single-select (four options, one correct).")),
          pp(mono("A subset (roughly 15\u201320%) should be multi-select, explicitly labeled \u201C(Choose 2)\u201D or \u201C(Choose 3)\u201D in the question stem, matching real exam conventions \u2014 these should have 5\u20136 options with the specified number of correct answers.")),
          new Paragraph({ spacing: { after: 60 }, children: [] }),

          pp(bld("3. Constraints")),
          pp(mono("Single-select questions have exactly one correct answer. Never use \u201CAll of the above\u201D or \u201CNone of the above.\u201D")),
          pp(mono("Multi-select questions have exactly the stated number of correct answers (2 or 3), clearly indicated in the stem.")),
          pp(mono("Single-select: four options total. Multi-select: five or six options total.")),
          pp(mono("Distractors must be cognitively taxing, not obviously wrong \u2014 they should be at least as long and detailed as the correct answer(s), to counteract the baseline guessing advantage (33% for Agentforce-related exams, 25% for others on single-select; lower still on multi-select).")),
          pp(mono("Distractors must use authentic Salesforce terminology applied to the wrong context (e.g., a real feature name misapplied to a scenario it doesn\u2019t solve) \u2014 never invent fake terms or violate Salesforce naming conventions.")),
          pp(mono("Vary the distractor typology across questions so the same \u201Ctrap pattern\u201D doesn\u2019t repeat back-to-back. Rotate through types such as:")),
          pp(mono("  \u2022 Right feature, wrong scope/limit")),
          pp(mono("  \u2022 Right outcome, wrong mechanism")),
          pp(mono("  \u2022 Deprecated or legacy feature no longer recommended")),
          pp(mono("  \u2022 Feature from an adjacent cloud/product that sounds plausible but doesn\u2019t apply")),
          pp(mono("  \u2022 Correct concept but violates a governance/licensing/data constraint")),
          new Paragraph({ spacing: { after: 60 }, children: [] }),

          pp(bld("4. Checks")),
          pp(mono("For the correct answer(s), include a one-to-two sentence explanation of why it\u2019s correct \u2014 the architectural principle or platform behavior that makes it the best choice given the scenario.")),
          pp(mono("For every wrong answer, include a one-sentence explanation stating exactly why it fails \u2014 cite the specific architectural reason or platform constraint violated (e.g., a limit, a sequencing dependency, a licensing restriction, or a scope mismatch). Do not just say \u201Cthis is incorrect\u201D \u2014 name the mechanism.")),
          new Paragraph({ spacing: { after: 60 }, children: [] }),

          pp(bld("Output format per question:")),
          pp(mono("Q#. [Exam guide section] \u2014 [Scenario-based question] (Choose 1 / Choose 2 / Choose 3)")),
          pp(mono("A) ...")),
          pp(mono("B) ...")),
          pp(mono("C) ...")),
          pp(mono("D) ...")),
          pp(mono("[E) ... F) ... \u2014 multi-select only]")),
          pp(mono("Correct Answer(s): [Letter(s)]")),
          pp(mono("Why correct: [1-2 sentence explanation of the architectural principle]")),
          pp(mono("Why each wrong answer fails:")),
          pp(mono("- [Letter]: [one-sentence architectural reason]")),
          pp(mono("- [Letter]: [one-sentence architectural reason]")),
          pp(mono("- [Letter]: [one-sentence architectural reason]")),
        ]
      })]
    })]
  });
}

function certOverviewTable() {
  const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
  const borders = { top: border, bottom: border, left: border, right: border };
  const headerShading = { fill: "1B3A5C", type: ShadingType.CLEAR };
  const bonusShading = { fill: "FFF8F0", type: ShadingType.CLEAR };

  const certs = [
    { name: "Agentforce Specialist", qs: "135", topics: "218 topics across 26 objectives", passing: "72%", bonus: false },
    { name: "Data 360 Consultant", qs: "212", topics: "167 topics across 18 objectives", passing: "62%", bonus: false },
    { name: "Platform Developer I", qs: "100", topics: "198 topics across 21 objectives", passing: "65%", bonus: false },
    { name: "Platform App Builder", qs: "100", topics: "361 topics across 24 objectives", passing: "63%", bonus: false },
    { name: "Development Lifecycle & Deployment Architect", qs: "100", topics: "133 topics across 25 objectives", passing: "65%", bonus: false },
    { name: "AgentOps: Agentforce Lifecycle *", qs: "50", topics: "191 topics across 20 objectives", passing: "70%", bonus: true },
    { name: "Success Architect Scenarios *", qs: "91", topics: "Quiz-only (no study guide)", passing: "70%", bonus: true },
  ];

  // Column widths: Name 3200, Questions 1400, Study Topics 3200, Passing 1560
  const colWidths = [3200, 1400, 3200, 1560];

  const headerRow = new TableRow({
    tableHeader: true,
    children: ["Certification / Topic", "Quiz Qs", "Study Topics", "Passing"].map((label, i) =>
      new TableCell({
        borders,
        width: { size: colWidths[i], type: WidthType.DXA },
        shading: headerShading,
        verticalAlign: VerticalAlign.CENTER,
        children: [new Paragraph({ alignment: AlignmentType.CENTER,
          children: [new TextRun({ text: label, bold: true, color: "FFFFFF", size: 20 })] })]
      })
    )
  });

  const dataRows = certs.map(c => {
    const shading = c.bonus ? bonusShading : undefined;
    return new TableRow({
      children: [c.name, c.qs, c.topics, c.passing].map((val, i) =>
        new TableCell({
          borders,
          width: { size: colWidths[i], type: WidthType.DXA },
          ...(shading ? { shading } : {}),
          verticalAlign: VerticalAlign.CENTER,
          children: [new Paragraph({
            alignment: i === 0 ? AlignmentType.LEFT : AlignmentType.CENTER,
            children: [new TextRun({ text: val, size: 20, ...(c.bonus && i === 0 ? { italics: true } : {}) })]
          })]
        })
      )
    });
  });

  return new Table({
    columnWidths: colWidths,
    rows: [headerRow, ...dataRows]
  });
}

// ── Generate ──
Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("/workspace/Nova/Cert_Study_Hub_Guide.docx", buffer);
  console.log("Done: Cert_Study_Hub_Guide.docx written");
});
