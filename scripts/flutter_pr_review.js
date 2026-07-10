const fs = require('fs');
const { execSync } = require('child_process');

const OPENAI_KEY = process.env.OPENAI_KEY;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const REPO = process.env.GITHUB_REPOSITORY;
const PR_NUMBER = process.env.PR_NUMBER;
const BASE_REF = process.env.BASE_REF || 'dev';
const PR_TITLE = process.env.PR_TITLE || '';
const PR_BODY = process.env.PR_BODY || '';

const MODEL = process.env.OPENAI_MODEL || 'gpt-4.1-mini';
const MARKER = '<!-- flutter-pr-compliance-review -->';


const BEST_PRACTICE_SECTIONS = [
  {
    id: 'bp_modern_app_architecture',
    title: 'Modern App Architecture',
    description: 'Feature-first or clean architecture, layer separation, repositories, DI, and modular boundaries.',
    source: 'best_practices.md — Section A',
  },
  {
    id: 'bp_app_security',
    title: 'App Security',
    description: 'Secrets, secure storage, logging safety, input validation, HTTPS, and sensitive data handling.',
    source: 'best_practices.md — Section B',
  },
  {
    id: 'bp_scalability_maintainability',
    title: 'Scalability and Maintainability',
    description: 'Modular features, avoiding large classes, centralized routing/errors/formatting.',
    source: 'best_practices.md — Section C',
  },
  {
    id: 'bp_performance',
    title: 'High-Level Performance Practices',
    description: 'Build efficiency, list rendering, disposal, memory leaks, images, isolates, debounce.',
    source: 'best_practices.md — Section D',
  },
  {
    id: 'bp_optimized_code_structure',
    title: 'Optimized Code Structure',
    description: 'Small widgets, composition, shallow trees, separated concerns, clean imports.',
    source: 'best_practices.md — Section E',
  },
];

const ALWAYS_APPLICABLE_CHECKLIST_IDS = new Set(['title_description', 'single_responsibility']);

const STATIC_RULES = [
  {
    id: 'state_management',
    pattern: /\bsetState\s*\(/,
    issue: 'Uses setState() in changed code — verify project-approved state management is used instead.',
    standard: 'State Management — avoid unnecessary setState',
  },
  {
    id: 'production_safe_crash_free',
    pattern: /\bas\s+[A-Z]\w*/,
    issue: 'Unsafe cast using `as` without visible type/null guard in changed code.',
    standard: 'Production-Safe — avoid unsafe casts',
  },
  {
    id: 'production_safe_crash_free',
    pattern: /(?<![=!<>])\!(?:\.|;|\)|\]|\s*,|\s*\})/,
    issue: 'Force unwrap `!` used in changed code without visible safety guarantee.',
    standard: 'Production-Safe — avoid unsafe force unwrap',
  },
  {
    id: 'theme_values_design_system',
    pattern: /Colors\.(black|white|red|blue|green|grey|gray|orange|yellow|purple|pink|brown|teal|cyan|amber|indigo|lime)\b/,
    issue: 'Hardcoded Material color used instead of Theme/colorScheme/design tokens.',
    standard: 'Theme Values and Design System Usage',
  },
  {
    id: 'unused_code_debug_logs',
    pattern: /(?<![a-zA-Z])print\s*\(/,
    issue: '`print()` statement found in changed code.',
    standard: 'Unused Code, Debug Logs, and Imports — print statements are not allowed',
    fix: 'Replace `print(...)` with `debugPrint(...)` if logging is necessary; otherwise remove the statement to keep the code clean.',
  },
  {
    id: 'enums_sealed_classes',
    pattern: /==\s*['"][a-zA-Z_]+['"]/,
    issue: 'Hardcoded string comparison — prefer typed enums or sealed classes.',
    standard: 'Enums / Sealed Classes',
  },
  {
    id: 'model_mapping_defaults',
    pattern: /Map\s*<\s*String\s*,\s*dynamic\s*>/,
    issue: 'Raw Map<String, dynamic> usage — prefer strongly typed models with safe defaults.',
    standard: 'Model Mapping with Default Values',
  },
  {
    id: 'graceful_error_handling',
    pattern: /catch\s*\([^)]*\)\s*\{\s*\}/,
    issue: 'Empty catch block — errors may be swallowed silently.',
    standard: 'Graceful Error Handling',
  },
  {
    id: 'bp_app_security',
    pattern: /(?:api[_-]?key|secret|password|token)\s*[:=]\s*['"][^'"]+['"]/i,
    issue: 'Possible hardcoded secret or credential in source code.',
    standard: 'App Security — never hardcode secrets',
  },
  {
    id: 'bp_performance',
    pattern: /ListView\s*\(/,
    issue: 'ListView without builder may be inefficient for large/dynamic lists — prefer ListView.builder.',
    standard: 'Performance — efficient list rendering',
  },
];

function readFile(path) {
  return fs.existsSync(path) ? fs.readFileSync(path, 'utf8') : '';
}

function sh(cmd) {
  return execSync(cmd, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
}

function safeJsonParse(text) {
  try { return JSON.parse(text); } catch (_) {}
  const match = text.match(/\{[\s\S]*\}/);
  if (match) return JSON.parse(match[0]);
  throw new Error('Unable to parse model JSON output');
}

function truncate(text, max) {
  if (text.length <= max) return text;
  return text.slice(0, max) + `\n\n...[truncated ${text.length - max} characters]`;
}

function parseChecklistSections(yamlText) {
  const sections = [];
  const parts = yamlText.split(/\n\s*- id:\s*/).slice(1);
  for (const part of parts) {
    const id = part.split(/\n/)[0].trim();
    const title = (part.match(/\n\s*title:\s*(.+)/) || [])[1]?.trim() || id;
    const description = (part.match(/\n\s*description:\s*(.+)/) || [])[1]?.trim() || '';
    const checksBlock = (part.match(/\n\s*checks:\s*\n([\s\S]*?)(?=\n\s*- id:|$)/) || [])[1] || '';
    const checks = [...checksBlock.matchAll(/\n\s*-\s*(.+)/g)].map(m => m[1].trim());
    sections.push({ id, title, description, checks, group: 'checklist' });
  }
  return sections;
}

function parseDiffAddedLines(diff) {
  const findings = [];
  const fileBlocks = diff.split(/^diff --git /m).slice(1);

  for (const block of fileBlocks) {
    const header = block.split('\n')[0] || '';
    const file = (header.match(/b\/(.+)$/) || [])[1];
    if (!file || !file.endsWith('.dart')) continue;

    let lineNo = 0;
    for (const line of block.split('\n')) {
      if (line.startsWith('@@')) {
        const match = line.match(/\+(\d+)/);
        lineNo = match ? Number(match[1]) : 0;
        continue;
      }
      if (line.startsWith('+') && !line.startsWith('+++')) {
        const content = line.slice(1);
        for (const rule of STATIC_RULES) {
          if (rule.pattern.test(content)) {
            findings.push({
              section_id: rule.id,
              file,
              line: lineNo,
              issue: rule.issue,
              standard: rule.standard,
              why_violation: rule.fix
                ? `${rule.fix} (Detected in PR diff by static compliance scan.)`
                : 'Detected in PR diff added/changed line by static compliance scan.',
              source: 'static_scan',
            });
          }
        }
        lineNo += 1;
      } else if (line.startsWith(' ') || line.startsWith('+')) {
        if (!line.startsWith('+++')) lineNo += 1;
      }
    }
  }

  return findings;
}

function inferApplicability(sectionId, changedFiles, isChecklist) {
  if (ALWAYS_APPLICABLE_CHECKLIST_IDS.has(sectionId)) return true;

  const dartFiles = changedFiles.filter(f => f.endsWith('.dart'));
  const hasDart = dartFiles.length > 0;
  const hasUi = dartFiles.some(f => /\/(ui|view|screen|page|widget)/i.test(f) || /_screen\.dart$|_page\.dart$|_widget\.dart$/i.test(f));

  const codeSections = new Set([
    'clean_scalable_architecture', 'production_safe_crash_free', 'managers_services',
    'graceful_error_handling', 'model_mapping_defaults', 'const_constructors_widgets',
    'enums_sealed_classes', 'utils_helper_classes', 'theme_values_design_system',
    'state_management', 'naming_conventions', 'unused_code_debug_logs', 'reusable_code',
    'folder_structure', 'ui_responsiveness_overflow',
    'bp_modern_app_architecture', 'bp_scalability_maintainability', 'bp_performance', 'bp_optimized_code_structure',
  ]);

  const metaSections = new Set(['single_responsibility', 'title_description']);

  if (metaSections.has(sectionId)) return true;
  if (sectionId === 'managers_services' || sectionId === 'model_mapping_defaults') return hasDart;
  if (sectionId === 'ui_responsiveness_overflow' || sectionId === 'theme_values_design_system') return hasUi || hasDart;
  if (sectionId === 'bp_app_security') return changedFiles.length > 0;
  if (codeSections.has(sectionId)) return hasDart || changedFiles.length > 0;

  return isChecklist ? changedFiles.length > 0 : hasDart;
}

function mergeViolations(existing, incoming) {
  const key = v => `${v.file}|${v.line}|${v.issue}`;
  const seen = new Set(existing.map(key));
  const merged = [...existing];
  for (const v of incoming) {
    const k = key(v);
    if (!seen.has(k)) {
      seen.add(k);
      merged.push(v);
    }
  }
  return merged;
}

function normalizeSections(modelSections, expectedSections, changedFiles, staticFindings, group) {
  const staticBySection = new Map();
  for (const f of staticFindings) {
    if (!staticBySection.has(f.section_id)) staticBySection.set(f.section_id, []);
    staticBySection.get(f.section_id).push({
      file: f.file,
      line: f.line || null,
      issue: f.issue,
      standard: f.standard,
      why_violation: f.why_violation,
    });
  }

  return expectedSections.map(section => {
    const found = (modelSections || []).find(s => s.id === section.id) || {};
    const modelApplicable = found.applicable;

    const modelViolations = Array.isArray(found.violations) ? found.violations.map(v => ({
      file: v.file || '',
      line: v.line || 0,
      issue: v.issue || '',
      standard: v.standard || '',
      why_violation: v.why_violation || '',
    })) : [];

    const staticViolations = staticBySection.get(section.id) || [];
    const hasFindings = modelViolations.length > 0 || staticViolations.length > 0;
    const inferred = inferApplicability(section.id, changedFiles, group === 'checklist');

    const applicable = hasFindings
      ? true
      : modelApplicable === false
        ? false
        : inferred || modelApplicable === true;

    const violations = applicable
      ? mergeViolations(modelViolations, staticViolations)
      : [];
    const suggestedFixes = Array.isArray(found.suggested_fixes) ? found.suggested_fixes : [];

    return {
      ...section,
      group,
      applicable,
      violation_count: applicable ? violations.length : 0,
      reason_not_applicable: applicable ? '' : (found.reason_not_applicable || 'This section is not touched by the PR changes.'),
      violations,
      suggested_fixes: suggestedFixes,
    };
  });
}

function buildSectionSchema() {
  return {
    type: 'object',
    additionalProperties: false,
    properties: {
      id: { type: 'string' },
      applicable: { type: 'boolean' },
      reason_not_applicable: { type: 'string' },
      violations: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          properties: {
            file: { type: 'string' },
            line: { type: 'integer' },
            issue: { type: 'string' },
            standard: { type: 'string' },
            why_violation: { type: 'string' },
          },
          required: ['file', 'line', 'issue', 'standard', 'why_violation'],
        },
      },
      suggested_fixes: { type: 'array', items: { type: 'string' } },
    },
    required: ['id', 'applicable', 'reason_not_applicable', 'violations', 'suggested_fixes'],
  };
}

async function callOpenAI({ phase, sections, sourceDoc, diff, files, fileSnippets }) {
  if (!OPENAI_KEY) throw new Error('OPENAI_KEY secret is missing');

  const sectionList = sections.map((s, i) => {
    const checks = s.checks ? `\n   Checks:\n${s.checks.map(c => `   - ${c}`).join('\n')}` : '';
    return `${i + 1}. id="${s.id}" title="${s.title}"\n   ${s.description || ''}${checks}`;
  }).join('\n\n');

  const phaseInstructions = phase === 'checklist'
    ? `PHASE 1 — PR COMPLIANCE CHECKLIST (HIGHEST PRIORITY)

You MUST evaluate the PR against pr_compliance_checklist.yaml FIRST.
For EACH of the ${sections.length} checklist sections below:
- Read every check item under that section.
- Inspect the PR diff and changed files for violations of ANY check item.
- If the PR touches Dart/Flutter code, UI, models, services, or project files relevant to a section, mark applicable=true.
- Only mark applicable=false when the PR clearly cannot relate to that section (explain why).
- Report EVERY deviation as a separate violation, including minor ones.
- Do NOT defer checklist violations to best practices — report them here.

Sections to evaluate:
${sectionList}`
    : `PHASE 2 — ADDITIONAL BEST PRACTICES (SECONDARY, AFTER CHECKLIST)

Evaluate ONLY against the General Product Engineering Practices in best_practices.md (Sections A–E).
Do NOT repeat violations already covered by pr_compliance_checklist.yaml.
Report NEW violations found in these supplemental areas only.

Sections to evaluate:
${sectionList}`;

  const schema = {
    name: `flutter_pr_${phase}_review`,
    schema: {
      type: 'object',
      additionalProperties: false,
      properties: {
        sections: {
          type: 'array',
          items: buildSectionSchema(),
        },
      },
      required: ['sections'],
    },
    strict: true,
  };

  const prompt = `
You are a strict Flutter PR compliance reviewer.

${phaseInstructions}

## Strictness rules
- Functional code that deviates from standards is still a violation.
- Do not skip minor violations.
- Logging policy: flag print() as a violation only. debugPrint() and log() are allowed and must NOT be reported as violations. For print(), suggest replacing with debugPrint() if logging is necessary, otherwise removing the statement.
- Evaluate only PR changes (diff), PR title, PR description, and changed file list.
- Include file path and line number when possible (use 0 for line if unknown).
- Each distinct issue = one violation.
- suggested_fixes: one actionable fix per violation or grouped clear recommendations.
- No scores, grades, or pass/fail ratings.

PR title: ${PR_TITLE}
PR description: ${PR_BODY || '(empty)'}

Changed files:
${files || '(none)'}

${sourceDoc.label}:
${sourceDoc.content}

Changed Dart file snippets (for context):
${truncate(fileSnippets || '(no dart files changed)', 30000)}

Git diff:
${truncate(diff, 70000)}
`;

  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${OPENAI_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: MODEL,
      temperature: 0.15,
      response_format: { type: 'json_schema', json_schema: schema },
      messages: [
        {
          role: 'system',
          content: 'Return only valid JSON matching the schema. Be strict and thorough. Missing violations is a failure.',
        },
        { role: 'user', content: prompt },
      ],
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`OpenAI request failed (${phase}): ${res.status} ${body}`);
  }

  const data = await res.json();
  return safeJsonParse(data.choices[0].message.content);
}

function getChangedFilesList(filesOutput) {
  return filesOutput.split('\n').map(f => f.trim()).filter(Boolean);
}

function getChangedDartSnippets(changedFiles) {
  const dartFiles = changedFiles.filter(f => f.endsWith('.dart') && fs.existsSync(f));
  const chunks = [];
  for (const file of dartFiles.slice(0, 12)) {
    try {
      const content = fs.readFileSync(file, 'utf8');
      chunks.push(`### ${file}\n${truncate(content, 8000)}`);
    } catch (_) {}
  }
  return chunks.join('\n\n');
}

function formatSummaryTable(sections, startSr) {
  let md = `| Sr. | Section ID | Violations |\n`;
  md += `| ---: | --- | ---: |\n`;
  sections.forEach((s, idx) => {
    const sr = startSr + idx;
    const count = s.applicable ? s.violation_count : 'N/A';
    md += `| ${sr} | \`${s.id}\` | ${count} |\n`;
  });
  return md;
}

function formatViolation(v) {
  const loc = v.file ? `${v.file}${v.line > 0 ? `:${v.line}` : ''}` : 'Changed code';
  let text = `* **${loc}** — ${v.issue}`;
  if (v.standard) text += `\n  * Standard: ${v.standard}`;
  if (v.why_violation) text += `\n  * Why: ${v.why_violation}`;
  return text;
}

function formatSectionDetail(s) {
  let md = `#### Section: ${s.title} (\`${s.id}\`)\n\n`;
  md += `**Violations Found**\n\n`;

  if (!s.applicable) {
    md += `* Not applicable — ${s.reason_not_applicable}\n`;
  } else if (s.violations.length === 0) {
    md += `* No violations detected.\n`;
  } else {
    for (const v of s.violations) md += `${formatViolation(v)}\n`;
  }

  md += `\n**Suggested Fixes**\n\n`;
  if (!s.applicable) {
    md += `* No fixes required — section not applicable.\n`;
  } else if (s.suggested_fixes.length > 0) {
    for (const fix of s.suggested_fixes) md += `* ${fix}\n`;
  } else if (s.violations.length === 0) {
    md += `* No fixes required.\n`;
  } else {
    for (const v of s.violations) {
      const loc = v.file ? `${v.file}${v.line > 0 ? `:${v.line}` : ''}` : 'Changed code';
      md += `* Fix **${loc}**: ${v.issue}\n`;
    }
  }

  md += `\n**Violation Count:** ${s.violation_count}\n\n---\n\n`;
  return md;
}

function formatComment(checklistSections, bestPracticeSections) {
  const allSections = [...checklistSections, ...bestPracticeSections];
  const checklistViolations = checklistSections.filter(s => s.applicable).reduce((n, s) => n + s.violation_count, 0);
  const bpViolations = bestPracticeSections.filter(s => s.applicable).reduce((n, s) => n + s.violation_count, 0);
  const totalViolations = checklistViolations + bpViolations;

  let md = `${MARKER}\n`;
  md += `# Flutter PR Compliance Review\n\n`;
  md += `**Review order:** 1) \`pr_compliance_checklist.yaml\` → 2) \`best_practices.md\` (Sections A–E)\n\n`;
  md += `**Total violations:** ${totalViolations} (Checklist: ${checklistViolations}, Best practices: ${bpViolations})\n\n`;

  md += `## Evaluation Summary\n\n`;
  md += `### PR Compliance Checklist (\`pr_compliance_checklist.yaml\`)\n\n`;
  md += formatSummaryTable(checklistSections, 1);

  md += `\n### Additional Best Practices (\`best_practices.md\`)\n\n`;
  md += formatSummaryTable(bestPracticeSections, checklistSections.length + 1);

  md += `\n---\n\n`;
  md += `## Phase 1 — PR Compliance Checklist Details\n\n`;
  for (const s of checklistSections) md += formatSectionDetail(s);

  md += `## Phase 2 — Additional Best Practices Details\n\n`;
  for (const s of bestPracticeSections) md += formatSectionDetail(s);

  return md;
}

async function githubRequest(path, options = {}) {
  const res = await fetch(`https://api.github.com${path}`, {
    ...options,
    headers: {
      Authorization: `Bearer ${GITHUB_TOKEN}`,
      Accept: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      ...(options.headers || {}),
    },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`GitHub request failed: ${res.status} ${body}`);
  }
  return res.status === 204 ? null : res.json();
}

async function upsertComment(body) {
  if (!GITHUB_TOKEN || !REPO || !PR_NUMBER) throw new Error('Missing GitHub env vars');
  const comments = await githubRequest(`/repos/${REPO}/issues/${PR_NUMBER}/comments?per_page=100`);
  const existing = comments.find(c => c.body && c.body.includes(MARKER));
  if (existing) {
    await githubRequest(`/repos/${REPO}/issues/comments/${existing.id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ body }),
    });
  } else {
    await githubRequest(`/repos/${REPO}/issues/${PR_NUMBER}/comments`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ body }),
    });
  }
}

async function main() {
  const checklist = readFile('pr_compliance_checklist.yaml');
  const bestPractices = readFile('best_practices.md');
  if (!checklist || !bestPractices) {
    throw new Error('best_practices.md and pr_compliance_checklist.yaml must exist in repo root');
  }

  try { sh(`git fetch origin ${BASE_REF} --depth=200`); } catch (_) {}

  let diff = '';
  try {
    diff = sh(`git diff --no-ext-diff --unified=80 origin/${BASE_REF}...HEAD`);
  } catch (_) {
    diff = sh(`git diff --no-ext-diff --unified=80 HEAD~1...HEAD`);
  }

  const filesOutput = (() => {
    try { return sh(`git diff --name-only origin/${BASE_REF}...HEAD`); } catch (_) { return ''; }
  })();

  const changedFiles = getChangedFilesList(filesOutput);
  const fileSnippets = getChangedDartSnippets(changedFiles);
  const staticFindings = parseDiffAddedLines(diff);

  const checklistSectionDefs = parseChecklistSections(checklist);
  const bpSectionDefs = BEST_PRACTICE_SECTIONS.map(s => ({ ...s, group: 'best_practices' }));

  console.log('Phase 1: Reviewing pr_compliance_checklist.yaml...');
  const checklistReview = await callOpenAI({
    phase: 'checklist',
    sections: checklistSectionDefs,
    sourceDoc: { label: 'pr_compliance_checklist.yaml', content: checklist },
    diff,
    files: filesOutput,
    fileSnippets,
  });

  console.log('Phase 2: Reviewing best_practices.md (Sections A–E)...');
  const bpReview = await callOpenAI({
    phase: 'best_practices',
    sections: bpSectionDefs,
    sourceDoc: { label: 'best_practices.md (General Product Engineering Practices)', content: bestPractices },
    diff,
    files: filesOutput,
    fileSnippets,
  });

  const checklistSections = normalizeSections(
    checklistReview.sections,
    checklistSectionDefs,
    changedFiles,
    staticFindings.filter(f => !f.section_id.startsWith('bp_')),
    'checklist',
  );

  const bestPracticeSections = normalizeSections(
    bpReview.sections,
    bpSectionDefs,
    changedFiles,
    staticFindings.filter(f => f.section_id.startsWith('bp_')),
    'best_practices',
  );

  const comment = formatComment(checklistSections, bestPracticeSections);
  await upsertComment(comment);

  const total = [...checklistSections, ...bestPracticeSections]
    .filter(s => s.applicable)
    .reduce((n, s) => n + s.violation_count, 0);
  console.log(`Flutter compliance review posted: ${total} violation(s)`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
