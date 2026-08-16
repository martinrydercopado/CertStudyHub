/* ============================================================
   CertStudyHub — Single-page certification study app
   Vanilla JS, no build step, hash-based routing
   ============================================================ */

(function () {
  'use strict';

  // ── Global State ──────────────────────────────────────────
  const state = {
    certs: [],
    questions: {},
    studyData: {},
    currentCert: null,
    activeTab: 'quiz',

    quiz: {
      screen: 'start',
      selectedLength: null,
      questions: [],
      currentIndex: 0,
      score: 0,
      answered: 0,
      selectedOptions: new Set(),
      hasSubmitted: false,
      flaggedQuestions: [],
      reviewIndex: 0,
    },

    study: {
      screen: 'home',
      currentSection: null,
      currentObjective: null,
      currentTopicIndex: 0,
      isAnswerRevealed: false,
    },
  };

  // ── SF-style icon mapping (SwiftUI system name → emoji/svg) ──
  const iconMap = {
    'pencil.and.outline': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>',
    'cylinder.split.1x2': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><ellipse cx="12" cy="5" rx="8" ry="3"/><path d="M4 5v14c0 1.66 3.58 3 8 3s8-1.34 8-3V5"/><path d="M4 12c0 1.66 3.58 3 8 3s8-1.34 8-3"/></svg>',
    'cpu': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><line x1="9" y1="1" x2="9" y2="4"/><line x1="15" y1="1" x2="15" y2="4"/><line x1="9" y1="20" x2="9" y2="23"/><line x1="15" y1="20" x2="15" y2="23"/><line x1="20" y1="9" x2="23" y2="9"/><line x1="20" y1="14" x2="23" y2="14"/><line x1="1" y1="9" x2="4" y2="9"/><line x1="1" y1="14" x2="4" y2="14"/></svg>',
    'wrench.and.screwdriver': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>',
    'shield.checkered': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><line x1="12" y1="2" x2="12" y2="22"/><line x1="4" y1="10" x2="20" y2="10"/></svg>',
    'point.3.connected.trianglepath.dotted': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-dasharray="3 2"><polygon points="12 2 22 20 2 20"/><circle cx="12" cy="2" r="2" fill="currentColor" stroke-dasharray="0"/><circle cx="22" cy="20" r="2" fill="currentColor" stroke-dasharray="0"/><circle cx="2" cy="20" r="2" fill="currentColor" stroke-dasharray="0"/></svg>',
    'gearshape.2': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>',
    'bolt.fill': '<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>',
    'network': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><rect x="8" y="2" width="8" height="6" rx="1"/><rect x="1" y="16" width="8" height="6" rx="1"/><rect x="15" y="16" width="8" height="6" rx="1"/><line x1="12" y1="8" x2="12" y2="13"/><line x1="5" y1="16" x2="5" y2="13"/><line x1="19" y1="16" x2="19" y2="13"/><line x1="5" y1="13" x2="19" y2="13"/></svg>',
    'cloud.fill': '<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>',
    'book.fill': '<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>',
    'number': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="4" y1="9" x2="20" y2="9"/><line x1="4" y1="15" x2="20" y2="15"/><line x1="10" y1="3" x2="8" y2="21"/><line x1="16" y1="3" x2="14" y2="21"/></svg>',
    'arrow.triangle.branch': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="18" cy="18" r="3"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><path d="M6 15V6h6"/><path d="M15 6h-3"/></svg>',
    'lock.shield': '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><rect x="9" y="10" width="6" height="5" rx="1"/><path d="M10 10V8a2 2 0 0 1 4 0v2"/></svg>',
    'chart.bar.fill': '<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><rect x="2" y="12" width="4" height="10" rx="1"/><rect x="10" y="4" width="4" height="18" rx="1"/><rect x="18" y="8" width="4" height="14" rx="1"/></svg>',
  };

  function getSectionIcon(iconName) {
    if (iconMap[iconName]) return iconMap[iconName];
    // If it's an emoji (not an SF Symbol name), render as text span
    if (iconName && !/^[a-z]/.test(iconName)) {
      return '<span style="font-size:20px;line-height:1">' + iconName + '</span>';
    }
    return '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>';
  }

  // ── Utility Functions ─────────────────────────────────────

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function shuffleArray(arr) {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  }

  function setsEqual(a, b) {
    if (a.size !== b.size) return false;
    for (const v of a) if (!b.has(v)) return false;
    return true;
  }

  function hexToRgb(hex) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return { r, g, b };
  }

  function colorWithOpacity(hex, opacity) {
    const { r, g, b } = hexToRgb(hex);
    return `rgba(${r}, ${g}, ${b}, ${opacity})`;
  }

  // ── LocalStorage Helpers ──────────────────────────────────

  function getTopicStatus(certId, topicId) {
    const cert = state.currentCert;
    const prefix = cert ? cert.storageKeyPrefix : certId;
    const key = prefix + 'StudyTopicStatuses';
    const statuses = JSON.parse(localStorage.getItem(key) || '{}');
    return statuses[topicId] || 'not_started';
  }

  function setTopicStatus(certId, topicId, status) {
    const cert = state.currentCert;
    const prefix = cert ? cert.storageKeyPrefix : certId;
    const key = prefix + 'StudyTopicStatuses';
    const statuses = JSON.parse(localStorage.getItem(key) || '{}');
    statuses[topicId] = status;
    localStorage.setItem(key, JSON.stringify(statuses));
  }

  function getAllTopics(sections) {
    const topics = [];
    sections.forEach(function (s) {
      s.objectives.forEach(function (o) {
        o.topics.forEach(function (t) {
          topics.push(t);
        });
      });
    });
    return topics;
  }

  function getConfidentCount(certId, topics) {
    return topics.filter(function (t) {
      return getTopicStatus(certId, t.id) === 'confident';
    }).length;
  }

  function getTotalTopics(sections) {
    return sections.reduce(function (sum, s) {
      return sum + s.objectives.reduce(function (s2, o) {
        return s2 + o.topics.length;
      }, 0);
    }, 0);
  }

  function getNeedsReviewTopics(certId, sections) {
    var items = [];
    sections.forEach(function (section) {
      section.objectives.forEach(function (obj) {
        obj.topics.forEach(function (topic) {
          if (getTopicStatus(certId, topic.id) === 'needs_review') {
            items.push({
              topic: topic,
              objective: obj,
              section: section,
            });
          }
        });
      });
    });
    return items;
  }

  // ── Data Loading ──────────────────────────────────────────

  async function loadData() {
    try {
      const [certsRes, questionsRes, studyRes] = await Promise.all([
        fetch('data/certs.json'),
        fetch('data/questions.json'),
        fetch('data/study.json'),
      ]);
      state.certs = await certsRes.json();
      state.questions = await questionsRes.json();
      state.studyData = await studyRes.json();
      handleRoute();
    } catch (err) {
      document.getElementById('app').innerHTML =
        '<div class="error-screen"><h2>Failed to load data</h2><p>' +
        escapeHtml(err.message) +
        '</p><button onclick="location.reload()">Retry</button></div>';
    }
  }

  // ── Quiz Helpers ──────────────────────────────────────────

  function getQuestionsForCert(cert) {
    return state.questions[cert.questionBank] || [];
  }

  function startQuiz(lengthConfig) {
    var questions = getQuestionsForCert(state.currentCert);

    if (lengthConfig.questionIDRange) {
      var lo = lengthConfig.questionIDRange[0];
      var hi = lengthConfig.questionIDRange[1];
      questions = questions.filter(function (q) {
        var qid = parseInt(q.id, 10);
        return qid >= lo && qid <= hi;
      });
    }

    questions = shuffleArray(questions);
    var count = Math.min(lengthConfig.id, questions.length);
    questions = questions.slice(0, count);

    state.quiz = {
      screen: 'active',
      selectedLength: lengthConfig,
      questions: questions,
      currentIndex: 0,
      score: 0,
      answered: 0,
      selectedOptions: new Set(),
      hasSubmitted: false,
      flaggedQuestions: [],
      reviewIndex: 0,
    };

    location.hash = '#/cert/' + state.currentCert.id + '/quiz/active';
  }

  function submitAnswer() {
    state.quiz.hasSubmitted = true;
    state.quiz.answered++;
    var q = state.quiz.questions[state.quiz.currentIndex];
    var correct = new Set(q.correctIndices);
    var selected = state.quiz.selectedOptions;
    if (setsEqual(selected, correct)) {
      state.quiz.score++;
    }
    render();
  }

  function nextQuestion() {
    state.quiz.currentIndex++;
    state.quiz.selectedOptions = new Set();
    state.quiz.hasSubmitted = false;
    if (state.quiz.currentIndex >= state.quiz.questions.length) {
      location.hash = '#/cert/' + state.currentCert.id + '/quiz/results';
      return;
    }
    render();
  }

  function toggleFlag() {
    var q = state.quiz.questions[state.quiz.currentIndex];
    var idx = state.quiz.flaggedQuestions.findIndex(function (fq) {
      return fq.id === q.id;
    });
    if (idx >= 0) {
      state.quiz.flaggedQuestions.splice(idx, 1);
    } else {
      state.quiz.flaggedQuestions.push(q);
    }
    render();
  }

  function toggleOption(index) {
    if (state.quiz.hasSubmitted) return;
    var q = state.quiz.questions[state.quiz.currentIndex];
    var sel = state.quiz.selectedOptions;

    if (q.requiredSelections === 1) {
      sel.clear();
      sel.add(index);
    } else {
      if (sel.has(index)) {
        sel.delete(index);
      } else {
        if (sel.size < q.requiredSelections) {
          sel.add(index);
        }
      }
    }
    render();
  }

  function getGrade(percentage, passingScore) {
    if (percentage >= 90) return { text: 'Outstanding!', color: '#34C759' };
    if (percentage >= 80) return { text: 'Great Job!', color: '#007AFF' };
    if (percentage >= passingScore)
      return {
        text: 'Passing!',
        color: state.currentCert ? state.currentCert.primaryColor : '#007AFF',
      };
    if (percentage >= passingScore - 5) return { text: 'Almost There!', color: '#FF9500' };
    return { text: 'Keep Studying', color: '#FF3B30' };
  }

  // ── Router ────────────────────────────────────────────────

  function handleRoute() {
    var hash = location.hash || '#/';
    var parts = hash.replace('#/', '').split('/').filter(Boolean);

    // #/
    if (parts.length === 0) {
      state.currentCert = null;
      render();
      return;
    }

    // #/cert/{certId}/...
    if (parts[0] === 'cert' && parts.length >= 2) {
      var certId = parts[1];
      var cert = state.certs.find(function (c) { return c.id === certId; });
      if (!cert) {
        location.hash = '#/';
        return;
      }
      state.currentCert = cert;

      // #/cert/{certId}
      if (parts.length === 2) {
        var hasSections = (state.studyData[cert.studyBank] || []).length > 0;
        var hasQuiz = cert.quizLengths && cert.quizLengths.length > 0;
        if (!hasSections) {
          state.activeTab = 'quiz';
        } else if (!hasQuiz) {
          state.activeTab = 'study';
        }
        state.quiz.screen = 'start';
        render();
        return;
      }

      // #/cert/{certId}/quiz
      if (parts[2] === 'quiz') {
        state.activeTab = 'quiz';
        if (parts.length === 3) {
          state.quiz.screen = 'start';
        } else if (parts[3] === 'active') {
          state.quiz.screen = 'active';
        } else if (parts[3] === 'results') {
          state.quiz.screen = 'results';
        } else if (parts[3] === 'review') {
          state.quiz.screen = 'review';
        }
        render();
        return;
      }

      // #/cert/{certId}/study
      if (parts[2] === 'study') {
        state.activeTab = 'study';
        if (parts.length === 3) {
          state.study.screen = 'home';
          render();
          return;
        }

        // #/cert/{certId}/study/needs-review
        if (parts[3] === 'needs-review') {
          state.study.screen = 'needsReview';
          render();
          return;
        }

        // #/cert/{certId}/study/{sectionId}
        var sectionId = parts[3];
        var sections = state.studyData[cert.studyBank] || [];
        var section = sections.find(function (s) { return s.id === sectionId; });
        if (!section) {
          location.hash = '#/cert/' + certId + '/study';
          return;
        }
        state.study.currentSection = section;

        if (parts.length === 4) {
          state.study.screen = 'objectives';
          render();
          return;
        }

        // #/cert/{certId}/study/{sectionId}/{objectiveId}
        var objectiveId = parts[4];
        var objective = section.objectives.find(function (o) { return o.id === objectiveId; });
        if (!objective) {
          location.hash = '#/cert/' + certId + '/study/' + sectionId;
          return;
        }
        state.study.currentObjective = objective;
        state.study.screen = 'topic';
        state.study.isAnswerRevealed = false;
        render();
        return;
      }
    }

    // fallback
    location.hash = '#/';
  }

  // ── Main Render ───────────────────────────────────────────

  function render() {
    var app = document.getElementById('app');
    if (!app) return;

    var html = '';
    var hash = location.hash || '#/';

    if (!state.currentCert) {
      html = renderCertPicker();
    } else {
      html = renderCertHome();
    }

    app.innerHTML = html;

    // Trigger score circle animation after rendering results
    if (state.quiz.screen === 'results' && state.currentCert) {
      requestAnimationFrame(function () {
        var circle = document.querySelector('.score-progress');
        if (circle) {
          var pct = state.quiz.questions.length > 0
            ? (state.quiz.score / state.quiz.questions.length) * 100
            : 0;
          var circumference = 2 * Math.PI * 54;
          var offset = circumference - (pct / 100) * circumference;
          circle.style.strokeDashoffset = offset;
        }
      });
    }
  }

  // ── Cert Picker Screen ────────────────────────────────────

  function renderCertPicker() {
    var cards = state.certs.map(function (cert) {
      var qBank = getQuestionsForCert(cert);
      var questionCount = qBank.length;
      var studySections = state.studyData[cert.studyBank] || [];
      var topicCount = getTotalTopics(studySections);

      var bonusBadge = cert.isBonusTopic
        ? '<span class="bonus-badge">BONUS</span>'
        : '';

      var subtitleHtml = cert.subtitle
        ? '<p class="cert-card-subtitle">' + escapeHtml(cert.subtitle) + '</p>'
        : '';

      return (
        '<div class="cert-card" data-action="select-cert" data-cert-id="' + cert.id + '" ' +
        'style="--cert-primary: ' + cert.primaryColor + '; --cert-secondary: ' + cert.secondaryColor + '">' +
        '<div class="cert-card-header">' +
          '<span class="cert-card-icon">' + cert.icon + '</span>' +
          bonusBadge +
        '</div>' +
        '<h3 class="cert-card-name">' + escapeHtml(cert.name) + '</h3>' +
        subtitleHtml +
        '<div class="cert-card-stats">' +
          (questionCount > 0
            ? '<span class="cert-stat"><span class="cert-stat-icon">&#x1F4DD;</span> ' + questionCount + ' questions</span>'
            : '') +
          (topicCount > 0
            ? '<span class="cert-stat"><span class="cert-stat-icon">&#x1F4D6;</span> ' + topicCount + ' topics</span>'
            : '') +
          (!cert.isBonusTopic
            ? '<span class="cert-stat"><span class="cert-stat-icon">&#x2705;</span> ' + cert.passingScore + '% to pass</span>'
            : '') +
          (cert.guideFile
            ? '<span class="cert-stat cert-stat-guide"><span class="cert-stat-icon">&#x1F4D6;</span> Reference Guide</span>'
            : '') +
        '</div>' +
        '</div>'
      );
    }).join('');

    return (
      '<div class="screen cert-picker-screen">' +
        '<div class="picker-header">' +
          '<h1 class="picker-title">CertStudyHub</h1>' +
          '<p class="picker-subtitle">Choose a certification to study</p>' +
        '</div>' +
        '<div class="cert-grid">' + cards + '</div>' +
      '</div>'
    );
  }

  // ── Cert Home Screen ──────────────────────────────────────

  function renderCertHome() {
    var cert = state.currentCert;
    var sections = state.studyData[cert.studyBank] || [];
    var hasSections = sections.length > 0;

    var gradColors = cert.headerGradient || [cert.primaryColor, cert.secondaryColor || cert.primaryColor];
    var gradient = 'linear-gradient(135deg, ' + gradColors.join(', ') + ')';

    var hasQuiz = cert.quizLengths && cert.quizLengths.length > 0;
    var tabs = '';
    if (hasSections && hasQuiz) {
      tabs =
        '<div class="tab-bar">' +
          '<button class="tab-btn' + (state.activeTab === 'study' ? ' active' : '') + '" data-action="switch-tab" data-tab="study">Study Guide</button>' +
          '<button class="tab-btn' + (state.activeTab === 'quiz' ? ' active' : '') + '" data-action="switch-tab" data-tab="quiz">Quiz</button>' +
        '</div>';
    }

    var content = '';
    if ((state.activeTab === 'quiz' && hasQuiz) || !hasSections) {
      if (state.quiz.screen === 'start') {
        content = renderQuizStart();
      } else if (state.quiz.screen === 'active') {
        content = renderQuestion();
      } else if (state.quiz.screen === 'results') {
        content = renderResults();
      } else if (state.quiz.screen === 'review') {
        content = renderReview();
      }
    } else {
      if (state.study.screen === 'home') {
        content = renderStudyHome();
      } else if (state.study.screen === 'objectives') {
        content = renderObjectiveList();
      } else if (state.study.screen === 'topic') {
        content = renderTopicStudy();
      } else if (state.study.screen === 'needsReview') {
        content = renderNeedsReview();
      }
    }

    var guideLink = '';
    if (cert.guideFile) {
      guideLink =
        '<div class="guide-link-bar">' +
          '<a class="guide-link-btn" href="guides/viewer.html?guide=' + encodeURIComponent(cert.guideFile) + '" target="_blank" rel="noopener">' +
            '<span class="guide-link-icon">📖</span>' +
            '<span class="guide-link-text">Open Reference Guide</span>' +
            '<span class="guide-link-chevron">&rsaquo;</span>' +
          '</a>' +
        '</div>';
    }

    return (
      '<div class="screen cert-home-screen">' +
        '<div class="cert-header" style="background: ' + gradient + '">' +
          '<button class="back-btn" data-action="go-back">' +
            '<span class="back-chevron">&lsaquo;</span> Back' +
          '</button>' +
          '<div class="cert-header-info">' +
            '<span class="cert-header-icon">' + cert.icon + '</span>' +
            '<h2 class="cert-header-name">' + escapeHtml(cert.name) + '</h2>' +
          '</div>' +
        '</div>' +
        guideLink +
        tabs +
        '<div class="tab-content">' + content + '</div>' +
      '</div>'
    );
  }

  // ── Quiz Start Screen ────────────────────────────────────

  function renderQuizStart() {
    var cert = state.currentCert;
    var lengths = cert.quizLengths || [];

    var items = lengths.map(function (lc) {
      return (
        '<button class="quiz-length-btn" data-action="start-quiz" data-length-id="' + lc.id + '"' +
        (lc.questionIDRange ? ' data-range-lo="' + lc.questionIDRange[0] + '" data-range-hi="' + lc.questionIDRange[1] + '"' : '') + '>' +
          '<span class="ql-icon">' + lc.icon + '</span>' +
          '<div class="ql-info">' +
            '<span class="ql-label">' + escapeHtml(lc.label) + '</span>' +
            '<span class="ql-subtitle">' + escapeHtml(lc.subtitle) + '</span>' +
          '</div>' +
          '<span class="ql-duration">' + escapeHtml(lc.duration) + '</span>' +
          '<span class="ql-chevron">&rsaquo;</span>' +
        '</button>'
      );
    }).join('');

    return (
      '<div class="quiz-start">' +
        '<div class="quiz-start-header">' +
          '<span class="quiz-start-icon">' + cert.icon + '</span>' +
          '<h3>Choose Your Quiz</h3>' +
        '</div>' +
        '<div class="quiz-length-list">' + items + '</div>' +
      '</div>'
    );
  }

  // ── Active Question View ──────────────────────────────────

  function renderQuestion() {
    var quiz = state.quiz;
    var q = quiz.questions[quiz.currentIndex];
    if (!q) return '<div class="empty-state">No questions available.</div>';

    var total = quiz.questions.length;
    var progressPct = ((quiz.currentIndex + 1) / total) * 100;
    var isFlagged = quiz.flaggedQuestions.some(function (fq) { return fq.id === q.id; });
    var cert = state.currentCert;

    // Question type badge
    var typeBadge = '';
    if (q.questionType === 'multi-select') {
      typeBadge = '<span class="q-type-badge multi">Select ' + q.requiredSelections + '</span>';
    } else if (q.questionType === 'true-false') {
      typeBadge = '<span class="q-type-badge tf">True / False</span>';
    }

    // Options
    var optionsHtml = q.options.map(function (opt, idx) {
      var isSelected = quiz.selectedOptions.has(idx);
      var isCorrect = q.correctIndices.indexOf(idx) >= 0;
      var optClass = 'option-btn';
      var iconHtml = '';

      if (quiz.hasSubmitted) {
        if (isCorrect) {
          optClass += ' correct';
          iconHtml = '<span class="opt-status-icon correct-icon">&#x2713;</span>';
        } else if (isSelected && !isCorrect) {
          optClass += ' incorrect';
          iconHtml = '<span class="opt-status-icon incorrect-icon">&#x2717;</span>';
        }
      } else if (isSelected) {
        optClass += ' selected';
      }

      var selectIcon = '';
      if (q.requiredSelections === 1) {
        selectIcon = isSelected
          ? '<span class="radio-icon filled" style="border-color: ' + cert.primaryColor + '; background: ' + cert.primaryColor + '"></span>'
          : '<span class="radio-icon"></span>';
      } else {
        selectIcon = isSelected
          ? '<span class="check-icon filled" style="border-color: ' + cert.primaryColor + '; background: ' + cert.primaryColor + '">&#x2713;</span>'
          : '<span class="check-icon"></span>';
      }

      return (
        '<button class="' + optClass + '" data-action="select-option" data-option-index="' + idx + '">' +
          selectIcon +
          '<span class="opt-letter" style="background: ' + colorWithOpacity(cert.primaryColor, 0.12) + '; color: ' + cert.primaryColor + '">' + opt.letter + '</span>' +
          '<span class="opt-text">' + escapeHtml(opt.text) + '</span>' +
          iconHtml +
        '</button>'
      );
    }).join('');

    // Multi-select counter
    var multiCounter = '';
    if (q.requiredSelections > 1 && !quiz.hasSubmitted) {
      multiCounter =
        '<div class="multi-counter">' + quiz.selectedOptions.size + ' of ' + q.requiredSelections + ' selected</div>';
    }

    // Feedback
    var feedbackHtml = '';
    if (quiz.hasSubmitted) {
      var correct = new Set(q.correctIndices);
      var isRight = setsEqual(quiz.selectedOptions, correct);

      feedbackHtml =
        '<div class="feedback-box ' + (isRight ? 'correct' : 'incorrect') + '">' +
          '<div class="feedback-header">' +
            '<span class="feedback-icon">' + (isRight ? '&#x2705;' : '&#x274C;') + '</span>' +
            '<span class="feedback-label">' + (isRight ? 'Correct!' : 'Incorrect') + '</span>' +
          '</div>' +
          (q.explanation
            ? '<div class="feedback-explanation">' +
                '<span class="explanation-icon">&#x1F4A1;</span>' +
                '<p>' + escapeHtml(q.explanation) + '</p>' +
              '</div>'
            : '') +
        '</div>';
    }

    // Buttons
    var actionBtn = '';
    if (!quiz.hasSubmitted) {
      var canSubmit = quiz.selectedOptions.size > 0;
      if (q.requiredSelections > 1) {
        canSubmit = quiz.selectedOptions.size === q.requiredSelections;
      }
      actionBtn =
        '<button class="primary-btn submit-btn" data-action="submit-answer"' +
        (!canSubmit ? ' disabled' : '') +
        ' style="background: ' + cert.primaryColor + '">Submit Answer</button>';
    } else {
      var isLast = quiz.currentIndex >= quiz.questions.length - 1;
      actionBtn =
        '<button class="primary-btn next-btn" data-action="next-question" style="background: ' + cert.primaryColor + '">' +
          (isLast ? 'View Results' : 'Next Question') +
        '</button>';
    }

    return (
      '<div class="question-screen">' +
        // Progress bar
        '<div class="quiz-progress">' +
          '<div class="quiz-progress-bar">' +
            '<div class="quiz-progress-fill" style="width: ' + progressPct + '%; background: ' + cert.primaryColor + '"></div>' +
          '</div>' +
          '<div class="quiz-progress-stats">' +
            '<span>Question ' + (quiz.currentIndex + 1) + ' of ' + total + '</span>' +
            '<span class="progress-score">' +
              '<span class="score-correct">' + quiz.score + ' &#x2713;</span>' +
              '<span class="score-incorrect">' + (quiz.answered - quiz.score) + ' &#x2717;</span>' +
            '</span>' +
          '</div>' +
        '</div>' +
        // Question card
        '<div class="question-card">' +
          '<div class="question-header">' +
            '<span class="question-counter" style="color: ' + cert.primaryColor + '">QUESTION ' + (quiz.currentIndex + 1) + '</span>' +
            typeBadge +
            '<button class="flag-btn' + (isFlagged ? ' flagged' : '') + '" data-action="toggle-flag" title="Flag for review">' +
              (isFlagged ? '&#x1F6A9;' : '&#x2691;') +
            '</button>' +
          '</div>' +
          '<p class="question-text">' + escapeHtml(q.question) + '</p>' +
          '<div class="options-list">' + optionsHtml + '</div>' +
          multiCounter +
          feedbackHtml +
          '<div class="question-actions">' + actionBtn + '</div>' +
        '</div>' +
      '</div>'
    );
  }

  // ── Results Screen ────────────────────────────────────────

  function renderResults() {
    var quiz = state.quiz;
    var cert = state.currentCert;
    var total = quiz.questions.length;
    var pct = total > 0 ? Math.round((quiz.score / total) * 100) : 0;
    var grade = getGrade(pct, cert.passingScore);
    var passed = pct >= cert.passingScore;
    var incorrect = total - quiz.score;

    var circumference = 2 * Math.PI * 54;

    var flaggedSection = '';
    if (quiz.flaggedQuestions.length > 0) {
      flaggedSection =
        '<button class="result-action-btn flagged-btn" data-action="review-flagged">' +
          '<span class="ra-icon">&#x1F6A9;</span>' +
          '<span>Review Flagged (' + quiz.flaggedQuestions.length + ')</span>' +
        '</button>';
    }

    return (
      '<div class="results-screen">' +
        '<div class="score-circle-container">' +
          '<svg class="score-svg" width="140" height="140" viewBox="0 0 120 120">' +
            '<circle class="score-bg" cx="60" cy="60" r="54" fill="none" stroke-width="8"/>' +
            '<circle class="score-progress" cx="60" cy="60" r="54" fill="none" ' +
              'stroke="' + grade.color + '" stroke-width="8" stroke-linecap="round" ' +
              'stroke-dasharray="' + circumference + '" ' +
              'stroke-dashoffset="' + circumference + '" ' +
              'transform="rotate(-90 60 60)"/>' +
          '</svg>' +
          '<div class="score-text">' +
            '<span class="score-pct">' + pct + '%</span>' +
            '<span class="score-label">Score</span>' +
          '</div>' +
        '</div>' +

        '<div class="result-indicator" style="color: ' + grade.color + '">' +
          '<span class="result-icon">' + (passed ? '&#x2705;' : '&#x274C;') + '</span>' +
          '<span class="result-grade">' + grade.text + '</span>' +
        '</div>' +

        '<p class="result-summary">You scored <strong>' + quiz.score + '</strong> out of <strong>' + total + '</strong> questions correctly.</p>' +

        '<div class="result-stats">' +
          '<div class="stat-card correct"><span class="stat-num">' + quiz.score + '</span><span class="stat-lbl">Correct</span></div>' +
          '<div class="stat-card incorrect"><span class="stat-num">' + incorrect + '</span><span class="stat-lbl">Incorrect</span></div>' +
          '<div class="stat-card total"><span class="stat-num">' + total + '</span><span class="stat-lbl">Total</span></div>' +
          (quiz.flaggedQuestions.length > 0
            ? '<div class="stat-card flagged"><span class="stat-num">' + quiz.flaggedQuestions.length + '</span><span class="stat-lbl">Flagged</span></div>'
            : '') +
        '</div>' +

        '<div class="result-actions">' +
          flaggedSection +
          '<button class="result-action-btn retry-btn" data-action="retry-quiz" style="background: ' + cert.primaryColor + '">' +
            '<span class="ra-icon">&#x1F504;</span>' +
            '<span>Retry Quiz</span>' +
          '</button>' +
          '<button class="result-action-btn change-btn" data-action="change-quiz-length">' +
            '<span class="ra-icon">&#x1F522;</span>' +
            '<span>Change Quiz Length</span>' +
          '</button>' +
        '</div>' +
      '</div>'
    );
  }

  // ── Review Screen ─────────────────────────────────────────

  function renderReview() {
    var quiz = state.quiz;
    var cert = state.currentCert;
    var flagged = quiz.flaggedQuestions;

    if (flagged.length === 0) {
      return (
        '<div class="review-empty">' +
          '<button class="back-bar-btn" data-action="back-to-results">&lsaquo; Back to Results</button>' +
          '<div class="empty-state">' +
            '<span class="empty-icon">&#x2705;</span>' +
            '<h3>No Flagged Questions</h3>' +
            '<p>You didn\'t flag any questions for review.</p>' +
          '</div>' +
        '</div>'
      );
    }

    var idx = quiz.reviewIndex;
    if (idx >= flagged.length) idx = flagged.length - 1;
    if (idx < 0) idx = 0;
    quiz.reviewIndex = idx;
    var q = flagged[idx];

    var optionsHtml = q.options.map(function (opt, oi) {
      var isCorrect = q.correctIndices.indexOf(oi) >= 0;
      var cls = 'option-btn review-opt' + (isCorrect ? ' correct' : '');
      return (
        '<div class="' + cls + '">' +
          (isCorrect
            ? '<span class="opt-status-icon correct-icon">&#x2713;</span>'
            : '<span class="opt-status-icon dim-icon">&#x25CB;</span>') +
          '<span class="opt-letter" style="background: ' + colorWithOpacity(cert.primaryColor, 0.12) + '; color: ' + cert.primaryColor + '">' + opt.letter + '</span>' +
          '<span class="opt-text">' + escapeHtml(opt.text) + '</span>' +
        '</div>'
      );
    }).join('');

    return (
      '<div class="review-screen">' +
        '<div class="review-header">' +
          '<button class="back-bar-btn" data-action="back-to-results">&lsaquo; Back</button>' +
          '<span class="review-counter">' + (idx + 1) + ' of ' + flagged.length + '</span>' +
          '<button class="remove-flag-btn" data-action="remove-flag" title="Remove flag">&#x1F6A9; Remove</button>' +
        '</div>' +
        '<div class="question-card review-card">' +
          '<div class="question-header">' +
            '<span class="question-counter" style="color: ' + cert.primaryColor + '">FLAGGED QUESTION</span>' +
          '</div>' +
          '<p class="question-text">' + escapeHtml(q.question) + '</p>' +
          '<div class="options-list">' + optionsHtml + '</div>' +
          (q.explanation
            ? '<div class="feedback-box correct review-explanation">' +
                '<span class="explanation-icon">&#x1F4A1;</span>' +
                '<p>' + escapeHtml(q.explanation) + '</p>' +
              '</div>'
            : '') +
        '</div>' +
        '<div class="review-nav">' +
          '<button class="nav-btn" data-action="review-prev"' + (idx === 0 ? ' disabled' : '') + '>&lsaquo; Previous</button>' +
          '<button class="nav-btn" data-action="review-next"' + (idx >= flagged.length - 1 ? ' disabled' : '') + '>Next &rsaquo;</button>' +
        '</div>' +
      '</div>'
    );
  }

  // ── Study Home Screen ─────────────────────────────────────

  function renderStudyHome() {
    var cert = state.currentCert;
    var sections = state.studyData[cert.studyBank] || [];
    var allTopics = getAllTopics(sections);
    var totalTopics = allTopics.length;
    var confidentTotal = getConfidentCount(cert.id, allTopics);
    var progressPct = totalTopics > 0 ? (confidentTotal / totalTopics) * 100 : 0;

    var needsReviewCount = getNeedsReviewTopics(cert.id, sections).length;

    var sectionCards = sections.map(function (section) {
      var sectionTopics = getAllTopics([section]);
      var sectionConfident = getConfidentCount(cert.id, sectionTopics);
      var sectionTotal = sectionTopics.length;
      var objCount = section.objectives.length;
      var sPct = sectionTotal > 0 ? (sectionConfident / sectionTotal) * 100 : 0;

      return (
        '<button class="study-section-card" data-action="open-section" data-section-id="' + section.id + '">' +
          '<div class="section-icon-box" style="background: ' + colorWithOpacity(section.color, 0.15) + '; color: ' + section.color + '">' +
            getSectionIcon(section.icon) +
          '</div>' +
          '<div class="section-info">' +
            '<span class="section-title">' + escapeHtml(section.title) + '</span>' +
            '<span class="section-meta">' + objCount + ' objective' + (objCount !== 1 ? 's' : '') + ' &middot; ' + sectionTotal + ' topics</span>' +
            '<div class="section-progress-row">' +
              '<span class="section-confident">' + sectionConfident + '/' + sectionTotal + ' confident</span>' +
            '</div>' +
            '<div class="progress-bar-sm"><div class="progress-fill-sm" style="width: ' + sPct + '%; background: ' + section.color + '"></div></div>' +
          '</div>' +
          '<span class="section-chevron">&rsaquo;</span>' +
        '</button>'
      );
    }).join('');

    var needsReviewBtn = '';
    if (needsReviewCount > 0) {
      needsReviewBtn =
        '<button class="needs-review-card" data-action="open-needs-review">' +
          '<span class="nr-icon">&#x26A0;&#xFE0F;</span>' +
          '<div class="nr-info">' +
            '<span class="nr-title">Needs Review</span>' +
            '<span class="nr-count">' + needsReviewCount + ' topic' + (needsReviewCount !== 1 ? 's' : '') + ' to review</span>' +
          '</div>' +
          '<span class="section-chevron">&rsaquo;</span>' +
        '</button>';
    }

    return (
      '<div class="study-home">' +
        '<div class="study-overview">' +
          '<div class="study-overview-header">' +
            '<span class="study-overview-icon">' + cert.icon + '</span>' +
            '<div class="study-overview-info">' +
              '<h3>Study Guide</h3>' +
              '<span class="overview-confident">' + confidentTotal + ' of ' + totalTopics + ' confident</span>' +
            '</div>' +
          '</div>' +
          '<div class="progress-bar"><div class="progress-fill" style="width: ' + progressPct + '%; background: ' + cert.primaryColor + '"></div></div>' +
        '</div>' +
        needsReviewBtn +
        '<div class="section-list">' + sectionCards + '</div>' +
      '</div>'
    );
  }

  // ── Objective List View ───────────────────────────────────

  function renderObjectiveList() {
    var cert = state.currentCert;
    var section = state.study.currentSection;
    if (!section) return '<div class="empty-state">Section not found.</div>';

    var sectionTopics = getAllTopics([section]);
    var sectionTotal = sectionTopics.length;
    var sectionConfident = getConfidentCount(cert.id, sectionTopics);
    var sPct = sectionTotal > 0 ? (sectionConfident / sectionTotal) * 100 : 0;

    var objCards = section.objectives.map(function (obj) {
      var objTopicCount = obj.topics.length;
      var objConfident = getConfidentCount(cert.id, obj.topics);
      var objReview = obj.topics.filter(function (t) { return getTopicStatus(cert.id, t.id) === 'needs_review'; }).length;
      var objPct = objTopicCount > 0 ? (objConfident / objTopicCount) * 100 : 0;

      var reviewBadge = objReview > 0
        ? '<span class="obj-review-badge">' + objReview + ' needs review</span>'
        : '';

      return (
        '<button class="objective-card" data-action="open-objective" data-section-id="' + section.id + '" data-objective-id="' + obj.id + '">' +
          '<div class="obj-info">' +
            '<span class="obj-title">' + escapeHtml(obj.title) + '</span>' +
            '<span class="obj-meta">' + objTopicCount + ' topic' + (objTopicCount !== 1 ? 's' : '') + '</span>' +
            '<div class="obj-status-row">' +
              '<span class="obj-confident-count" style="color: ' + section.color + '">' + objConfident + '/' + objTopicCount + ' confident</span>' +
              reviewBadge +
            '</div>' +
            '<div class="progress-bar-sm"><div class="progress-fill-sm" style="width: ' + objPct + '%; background: ' + section.color + '"></div></div>' +
          '</div>' +
          '<span class="section-chevron">&rsaquo;</span>' +
        '</button>'
      );
    }).join('');

    return (
      '<div class="objective-list-screen">' +
        '<button class="back-bar-btn" data-action="back-to-study">&lsaquo; Study Guide</button>' +
        '<div class="section-header-card" style="border-left: 4px solid ' + section.color + '">' +
          '<div class="section-icon-box" style="background: ' + colorWithOpacity(section.color, 0.15) + '; color: ' + section.color + '">' +
            getSectionIcon(section.icon) +
          '</div>' +
          '<div class="section-info">' +
            '<span class="section-title">' + escapeHtml(section.title) + '</span>' +
            '<span class="overview-confident">' + sectionConfident + ' of ' + sectionTotal + ' confident</span>' +
            '<div class="progress-bar-sm"><div class="progress-fill-sm" style="width: ' + sPct + '%; background: ' + section.color + '"></div></div>' +
          '</div>' +
        '</div>' +
        '<div class="objectives-container">' + objCards + '</div>' +
      '</div>'
    );
  }

  // ── Topic Study View ──────────────────────────────────────

  function renderTopicStudy() {
    var cert = state.currentCert;
    var section = state.study.currentSection;
    var objective = state.study.currentObjective;
    if (!section || !objective) return '<div class="empty-state">Topic not found.</div>';

    var topics = objective.topics;
    var idx = state.study.currentTopicIndex;
    if (idx >= topics.length) idx = topics.length - 1;
    if (idx < 0) idx = 0;
    state.study.currentTopicIndex = idx;
    var topic = topics[idx];
    var status = getTopicStatus(cert.id, topic.id);

    var answerHtml = '';
    if (state.study.isAnswerRevealed) {
      answerHtml =
        '<div class="answer-box" style="background: ' + colorWithOpacity(section.color, 0.06) + '; border-left: 4px solid ' + section.color + '">' +
          '<div class="answer-header">' +
            '<span class="answer-icon">&#x1F4A1;</span>' +
            '<span class="answer-label">Answer</span>' +
          '</div>' +
          '<p class="answer-text">' + escapeHtml(topic.answer) + '</p>' +
        '</div>';
    }

    var toggleAnswerBtn =
      '<button class="primary-btn toggle-answer-btn" data-action="toggle-answer" style="background: ' + section.color + '">' +
        (state.study.isAnswerRevealed ? 'Hide Answer' : 'Show Answer') +
      '</button>';

    // Confidence buttons
    var statuses = [
      { key: 'not_started', label: 'Not Started', color: '#8E8E93' },
      { key: 'needs_review', label: 'Needs Review', color: '#FF9500' },
      { key: 'confident', label: 'Confident', color: '#34C759' },
    ];

    var confidenceBtns = statuses.map(function (s) {
      var isActive = status === s.key;
      var style = isActive
        ? 'background: ' + s.color + '; color: #fff; border-color: ' + s.color
        : 'background: transparent; color: ' + s.color + '; border-color: ' + s.color;
      return (
        '<button class="confidence-btn' + (isActive ? ' active' : '') + '" data-action="set-confidence" data-status="' + s.key + '" style="' + style + '">' +
          escapeHtml(s.label) +
        '</button>'
      );
    }).join('');

    // Topic dots
    var dots = topics.map(function (t, i) {
      var tStatus = getTopicStatus(cert.id, t.id);
      var dotColor = '#8E8E93';
      if (tStatus === 'confident') dotColor = '#34C759';
      else if (tStatus === 'needs_review') dotColor = '#FF9500';
      var activeCls = i === idx ? ' active-dot' : '';
      return '<span class="topic-dot' + activeCls + '" style="background: ' + dotColor + '" data-action="go-to-topic" data-topic-idx="' + i + '"></span>';
    }).join('');

    return (
      '<div class="topic-study-screen">' +
        '<div class="topic-nav-bar">' +
          '<button class="back-bar-btn" data-action="back-to-objectives">&lsaquo; Back</button>' +
          '<span class="topic-counter">' + (idx + 1) + ' of ' + topics.length + '</span>' +
        '</div>' +
        '<div class="topic-content">' +
          '<div class="topic-header">' +
            '<span class="topic-number" style="color: ' + section.color + '">Q' + topic.number + '</span>' +
            '<span class="topic-obj-title">' + escapeHtml(objective.title) + '</span>' +
          '</div>' +
          '<p class="topic-question">' + escapeHtml(topic.question) + '</p>' +
          answerHtml +
          toggleAnswerBtn +
          '<div class="confidence-buttons">' + confidenceBtns + '</div>' +
          '<div class="topic-dots">' + dots + '</div>' +
          '<div class="topic-nav-buttons">' +
            '<button class="nav-btn" data-action="prev-topic"' + (idx === 0 ? ' disabled' : '') + '>&lsaquo; Previous</button>' +
            '<button class="nav-btn" data-action="next-topic"' + (idx >= topics.length - 1 ? ' disabled' : '') + '>Next &rsaquo;</button>' +
          '</div>' +
        '</div>' +
      '</div>'
    );
  }

  // ── Needs Review Screen ───────────────────────────────────

  function renderNeedsReview() {
    var cert = state.currentCert;
    var sections = state.studyData[cert.studyBank] || [];
    var items = getNeedsReviewTopics(cert.id, sections);

    var content = '';
    if (items.length === 0) {
      content =
        '<div class="empty-state">' +
          '<span class="empty-icon" style="color: #34C759">&#x2705;</span>' +
          '<h3>All Clear!</h3>' +
          '<p>No topics need review. Great job!</p>' +
        '</div>';
    } else {
      content = items.map(function (item) {
        return (
          '<button class="needs-review-item" data-action="go-to-review-topic" ' +
            'data-section-id="' + item.section.id + '" ' +
            'data-objective-id="' + item.objective.id + '" ' +
            'data-topic-id="' + item.topic.id + '">' +
            '<div class="nr-item-header">' +
              '<span class="nr-warning-icon">&#x26A0;&#xFE0F;</span>' +
              '<span class="nr-section-badge" style="background: ' + colorWithOpacity(item.section.color, 0.15) + '; color: ' + item.section.color + '">' +
                escapeHtml(item.section.title) +
              '</span>' +
            '</div>' +
            '<p class="nr-item-question">' + escapeHtml(item.topic.question) + '</p>' +
            '<span class="nr-item-objective">' + escapeHtml(item.objective.title) + '</span>' +
          '</button>'
        );
      }).join('');
    }

    return (
      '<div class="needs-review-screen">' +
        '<button class="back-bar-btn" data-action="back-to-study">&lsaquo; Study Guide</button>' +
        '<h3 class="nr-screen-title">Needs Review</h3>' +
        '<div class="nr-items">' + content + '</div>' +
      '</div>'
    );
  }

  // ── Event Delegation ──────────────────────────────────────

  document.addEventListener('DOMContentLoaded', function () {
    var app = document.getElementById('app');
    if (!app) return;

    app.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-action]');
      if (!btn) return;
      var action = btn.dataset.action;

      switch (action) {

        // Cert Picker
        case 'select-cert': {
          var certId = btn.dataset.certId;
          location.hash = '#/cert/' + certId;
          break;
        }

        // Navigation
        case 'go-back': {
          // Context-aware back navigation
          var hash = location.hash || '#/';
          if (hash.indexOf('/quiz/review') >= 0) {
            location.hash = '#/cert/' + state.currentCert.id + '/quiz/results';
          } else if (hash.indexOf('/quiz/results') >= 0 || hash.indexOf('/quiz/active') >= 0) {
            location.hash = '#/cert/' + state.currentCert.id;
          } else if (hash.indexOf('/study/needs-review') >= 0) {
            location.hash = '#/cert/' + state.currentCert.id + '/study';
          } else if (hash.indexOf('/study/') >= 0) {
            // Drill up study hierarchy
            var parts = hash.replace('#/', '').split('/').filter(Boolean);
            if (parts.length >= 5) {
              // at topic level, go to section
              location.hash = '#/cert/' + state.currentCert.id + '/study/' + parts[3];
            } else if (parts.length >= 4) {
              location.hash = '#/cert/' + state.currentCert.id + '/study';
            } else {
              location.hash = '#/cert/' + state.currentCert.id;
            }
          } else {
            location.hash = '#/';
          }
          break;
        }

        // Tabs
        case 'switch-tab': {
          var tab = btn.dataset.tab;
          state.activeTab = tab;
          if (tab === 'quiz') {
            state.quiz.screen = 'start';
            location.hash = '#/cert/' + state.currentCert.id;
          } else {
            state.study.screen = 'home';
            location.hash = '#/cert/' + state.currentCert.id + '/study';
          }
          break;
        }

        // Quiz
        case 'start-quiz': {
          var lengthId = parseInt(btn.dataset.lengthId, 10);
          var cert = state.currentCert;
          var lengthConfig = cert.quizLengths.find(function (l) { return l.id === lengthId; });
          if (!lengthConfig) break;
          // rebuild config with range from data attrs if present
          if (btn.dataset.rangeLo && btn.dataset.rangeHi) {
            lengthConfig = Object.assign({}, lengthConfig, {
              questionIDRange: [parseInt(btn.dataset.rangeLo, 10), parseInt(btn.dataset.rangeHi, 10)]
            });
          }
          startQuiz(lengthConfig);
          break;
        }

        case 'select-option': {
          var optIdx = parseInt(btn.dataset.optionIndex, 10);
          toggleOption(optIdx);
          break;
        }

        case 'submit-answer': {
          if (!btn.disabled) submitAnswer();
          break;
        }

        case 'next-question': {
          nextQuestion();
          break;
        }

        case 'toggle-flag': {
          toggleFlag();
          break;
        }

        // Results
        case 'review-flagged': {
          state.quiz.reviewIndex = 0;
          state.quiz.screen = 'review';
          location.hash = '#/cert/' + state.currentCert.id + '/quiz/review';
          break;
        }

        case 'retry-quiz': {
          if (state.quiz.selectedLength) {
            startQuiz(state.quiz.selectedLength);
          }
          break;
        }

        case 'change-quiz-length': {
          state.quiz.screen = 'start';
          location.hash = '#/cert/' + state.currentCert.id;
          break;
        }

        // Review
        case 'back-to-results': {
          state.quiz.screen = 'results';
          location.hash = '#/cert/' + state.currentCert.id + '/quiz/results';
          break;
        }

        case 'review-prev': {
          if (state.quiz.reviewIndex > 0) {
            state.quiz.reviewIndex--;
            render();
          }
          break;
        }

        case 'review-next': {
          if (state.quiz.reviewIndex < state.quiz.flaggedQuestions.length - 1) {
            state.quiz.reviewIndex++;
            render();
          }
          break;
        }

        case 'remove-flag': {
          var flagged = state.quiz.flaggedQuestions;
          if (flagged.length > 0) {
            flagged.splice(state.quiz.reviewIndex, 1);
            if (state.quiz.reviewIndex >= flagged.length && flagged.length > 0) {
              state.quiz.reviewIndex = flagged.length - 1;
            }
          }
          render();
          break;
        }

        // Study
        case 'open-section': {
          var secId = btn.dataset.sectionId;
          location.hash = '#/cert/' + state.currentCert.id + '/study/' + secId;
          break;
        }

        case 'open-objective': {
          var secId2 = btn.dataset.sectionId;
          var objId = btn.dataset.objectiveId;
          state.study.currentTopicIndex = 0;
          state.study.isAnswerRevealed = false;
          location.hash = '#/cert/' + state.currentCert.id + '/study/' + secId2 + '/' + objId;
          break;
        }

        case 'open-needs-review': {
          location.hash = '#/cert/' + state.currentCert.id + '/study/needs-review';
          break;
        }

        case 'back-to-study': {
          location.hash = '#/cert/' + state.currentCert.id + '/study';
          break;
        }

        case 'back-to-objectives': {
          if (state.study.currentSection) {
            location.hash = '#/cert/' + state.currentCert.id + '/study/' + state.study.currentSection.id;
          } else {
            location.hash = '#/cert/' + state.currentCert.id + '/study';
          }
          break;
        }

        case 'toggle-answer': {
          state.study.isAnswerRevealed = !state.study.isAnswerRevealed;
          render();
          break;
        }

        case 'set-confidence': {
          var newStatus = btn.dataset.status;
          var objective2 = state.study.currentObjective;
          if (objective2) {
            var t = objective2.topics[state.study.currentTopicIndex];
            if (t) {
              setTopicStatus(state.currentCert.id, t.id, newStatus);
              render();
            }
          }
          break;
        }

        case 'prev-topic': {
          if (state.study.currentTopicIndex > 0) {
            state.study.currentTopicIndex--;
            state.study.isAnswerRevealed = false;
            render();
          }
          break;
        }

        case 'next-topic': {
          var obj2 = state.study.currentObjective;
          if (obj2 && state.study.currentTopicIndex < obj2.topics.length - 1) {
            state.study.currentTopicIndex++;
            state.study.isAnswerRevealed = false;
            render();
          }
          break;
        }

        case 'go-to-topic': {
          var ti = parseInt(btn.dataset.topicIdx, 10);
          state.study.currentTopicIndex = ti;
          state.study.isAnswerRevealed = false;
          render();
          break;
        }

        case 'go-to-review-topic': {
          var rsId = btn.dataset.sectionId;
          var roId = btn.dataset.objectiveId;
          var rtId = btn.dataset.topicId;
          // Find section and objective
          var secs = state.studyData[state.currentCert.studyBank] || [];
          var rSec = secs.find(function (s) { return s.id === rsId; });
          if (rSec) {
            state.study.currentSection = rSec;
            var rObj = rSec.objectives.find(function (o) { return o.id === roId; });
            if (rObj) {
              state.study.currentObjective = rObj;
              var tIdx = rObj.topics.findIndex(function (t) { return t.id === rtId; });
              state.study.currentTopicIndex = tIdx >= 0 ? tIdx : 0;
              state.study.isAnswerRevealed = false;
              location.hash = '#/cert/' + state.currentCert.id + '/study/' + rsId + '/' + roId;
            }
          }
          break;
        }
      }
    });

    // Listen for hash changes
    window.addEventListener('hashchange', handleRoute);

    // Initial load
    loadData();
  });

  // ── Inject Styles ─────────────────────────────────────────

  function injectStyles() {
    var style = document.createElement('style');
    style.textContent = '' +
      /* Reset and base */
      '*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }' +
      ':root {' +
        '--bg: #F2F2F7; --bg2: #FFFFFF; --text: #1C1C1E; --text2: #636366; --text3: #AEAEB2;' +
        '--separator: #E5E5EA; --card-bg: #FFFFFF; --card-shadow: 0 1px 3px rgba(0,0,0,0.08);' +
        '--green: #34C759; --red: #FF3B30; --blue: #007AFF; --orange: #FF9500; --radius: 12px;' +
      '}' +
      '@media (prefers-color-scheme: dark) {' +
        ':root {' +
          '--bg: #000000; --bg2: #1C1C1E; --text: #FFFFFF; --text2: #ABABAF; --text3: #636366;' +
          '--separator: #38383A; --card-bg: #1C1C1E; --card-shadow: 0 1px 4px rgba(0,0,0,0.3);' +
        '}' +
      '}' +
      'body { font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", system-ui, sans-serif; ' +
        'background: var(--bg); color: var(--text); line-height: 1.5; -webkit-font-smoothing: antialiased; }' +
      '#app { max-width: 960px; margin: 0 auto; min-height: 100vh; }' +

      /* Cert Picker */
      '.cert-picker-screen { padding: 20px 16px 40px; }' +
      '.picker-header { text-align: center; padding: 32px 0 24px; }' +
      '.picker-title { font-size: 34px; font-weight: 700; letter-spacing: -0.5px; }' +
      '.picker-subtitle { font-size: 17px; color: var(--text2); margin-top: 6px; }' +
      '.cert-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; }' +
      '.cert-card { background: var(--card-bg); border-radius: var(--radius); padding: 20px; cursor: pointer; ' +
        'box-shadow: var(--card-shadow); transition: transform 0.2s, box-shadow 0.2s; border: 1px solid var(--separator); position: relative; overflow: hidden; }' +
      '.cert-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.12); }' +
      '.cert-card:active { transform: scale(0.98); }' +
      '.cert-card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }' +
      '.cert-card-icon { font-size: 36px; }' +
      '.bonus-badge { background: var(--orange); color: #fff; font-size: 10px; font-weight: 700; padding: 3px 8px; border-radius: 6px; text-transform: uppercase; letter-spacing: 0.5px; }' +
      '.cert-card-name { font-size: 18px; font-weight: 600; margin-bottom: 4px; }' +
      '.cert-card-subtitle { font-size: 13px; color: var(--text3); margin-bottom: 8px; }' +
      '.cert-card-stats { display: flex; flex-wrap: wrap; gap: 8px 16px; margin-top: 12px; }' +
      '.cert-stat { font-size: 13px; color: var(--text2); display: flex; align-items: center; gap: 4px; }' +
      '.cert-stat-guide { color: var(--tint, #007AFF); font-weight: 500; }' +
      '.cert-stat-icon { font-size: 14px; }' +

      /* Cert Home */
      '.cert-home-screen { min-height: 100vh; }' +
      '.cert-header { padding: 16px 16px 20px; color: #fff; }' +
      '.back-btn { background: none; border: none; color: rgba(255,255,255,0.9); font-size: 16px; cursor: pointer; padding: 4px 0; display: flex; align-items: center; gap: 2px; }' +
      '.back-btn:hover { color: #fff; }' +
      '.back-chevron { font-size: 22px; line-height: 1; margin-right: 2px; }' +
      '.cert-header-info { display: flex; align-items: center; gap: 12px; margin-top: 12px; }' +
      '.cert-header-icon { font-size: 32px; }' +
      '.cert-header-name { font-size: 22px; font-weight: 700; }' +

      /* Tab Bar */
      '.tab-bar { display: flex; background: var(--bg2); border-bottom: 1px solid var(--separator); padding: 0 16px; }' +
      '.tab-btn { flex: 1; padding: 12px 0; font-size: 15px; font-weight: 600; background: none; border: none; cursor: pointer; ' +
        'color: var(--text3); border-bottom: 2.5px solid transparent; transition: color 0.2s, border-color 0.2s; }' +
      '.tab-btn.active { color: var(--text); border-bottom-color: var(--blue); }' +
      '.tab-content { padding: 16px; }' +

      /* Quiz Start */
      '.quiz-start { padding: 8px 0; }' +
      '.quiz-start-header { text-align: center; padding: 20px 0; }' +
      '.quiz-start-icon { font-size: 48px; display: block; margin-bottom: 8px; }' +
      '.quiz-start-header h3 { font-size: 22px; font-weight: 700; }' +
      '.quiz-length-list { display: flex; flex-direction: column; gap: 10px; }' +
      '.quiz-length-btn { display: flex; align-items: center; gap: 14px; width: 100%; background: var(--card-bg); ' +
        'border: 1px solid var(--separator); border-radius: var(--radius); padding: 16px; cursor: pointer; text-align: left; transition: transform 0.15s; }' +
      '.quiz-length-btn:hover { transform: translateX(2px); }' +
      '.quiz-length-btn:active { transform: scale(0.98); }' +
      '.ql-icon { font-size: 28px; flex-shrink: 0; }' +
      '.ql-info { flex: 1; display: flex; flex-direction: column; }' +
      '.ql-label { font-size: 16px; font-weight: 600; color: var(--text); }' +
      '.ql-subtitle { font-size: 13px; color: var(--text2); }' +
      '.ql-duration { font-size: 12px; color: var(--text3); background: var(--bg); padding: 4px 10px; border-radius: 8px; white-space: nowrap; }' +
      '.ql-chevron { font-size: 22px; color: var(--text3); }' +

      /* Question Screen */
      '.question-screen { padding: 0; }' +
      '.quiz-progress { margin-bottom: 16px; }' +
      '.quiz-progress-bar { height: 6px; background: var(--separator); border-radius: 3px; overflow: hidden; }' +
      '.quiz-progress-fill { height: 100%; border-radius: 3px; transition: width 0.3s ease; }' +
      '.quiz-progress-stats { display: flex; justify-content: space-between; align-items: center; margin-top: 8px; font-size: 13px; color: var(--text2); }' +
      '.progress-score { display: flex; gap: 12px; }' +
      '.score-correct { color: var(--green); font-weight: 600; }' +
      '.score-incorrect { color: var(--red); font-weight: 600; }' +
      '.question-card { background: var(--card-bg); border-radius: var(--radius); padding: 20px; box-shadow: var(--card-shadow); border: 1px solid var(--separator); }' +
      '.question-header { display: flex; align-items: center; gap: 10px; margin-bottom: 16px; flex-wrap: wrap; }' +
      '.question-counter { font-size: 12px; font-weight: 700; letter-spacing: 1px; }' +
      '.q-type-badge { font-size: 11px; font-weight: 600; padding: 3px 8px; border-radius: 6px; }' +
      '.q-type-badge.multi { background: rgba(0,122,255,0.12); color: var(--blue); }' +
      '.q-type-badge.tf { background: rgba(175,82,222,0.12); color: #AF52DE; }' +
      '.flag-btn { margin-left: auto; background: none; border: none; cursor: pointer; font-size: 20px; padding: 4px 8px; border-radius: 8px; transition: background 0.2s; }' +
      '.flag-btn:hover { background: var(--bg); }' +
      '.flag-btn.flagged { color: var(--orange); }' +
      '.question-text { font-size: 16px; line-height: 1.6; margin-bottom: 20px; white-space: pre-line; }' +
      '.options-list { display: flex; flex-direction: column; gap: 8px; margin-bottom: 12px; }' +
      '.option-btn { display: flex; align-items: flex-start; gap: 10px; width: 100%; padding: 14px; border-radius: 10px; ' +
        'border: 1.5px solid var(--separator); background: var(--card-bg); cursor: pointer; text-align: left; transition: border-color 0.2s, background 0.2s; font-size: 15px; line-height: 1.5; }' +
      '.option-btn:hover:not(.correct):not(.incorrect):not(.review-opt) { background: var(--bg); }' +
      '.option-btn.selected { border-color: var(--blue); background: rgba(0,122,255,0.06); }' +
      '.option-btn.correct { border-color: var(--green); background: rgba(52,199,89,0.08); }' +
      '.option-btn.incorrect { border-color: var(--red); background: rgba(255,59,48,0.08); }' +
      '.opt-letter { flex-shrink: 0; width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; ' +
        'border-radius: 8px; font-size: 13px; font-weight: 700; margin-top: 1px; }' +
      '.opt-text { flex: 1; color: var(--text); }' +
      '.opt-status-icon { flex-shrink: 0; font-size: 18px; margin-left: auto; line-height: 1; margin-top: 3px; }' +
      '.correct-icon { color: var(--green); }' +
      '.incorrect-icon { color: var(--red); }' +
      '.dim-icon { color: var(--text3); }' +
      '.radio-icon { width: 22px; height: 22px; border-radius: 50%; border: 2px solid var(--text3); flex-shrink: 0; margin-top: 2px; transition: all 0.2s; }' +
      '.radio-icon.filled { border-width: 6px; }' +
      '.check-icon { width: 22px; height: 22px; border-radius: 6px; border: 2px solid var(--text3); flex-shrink: 0; margin-top: 2px; ' +
        'display: flex; align-items: center; justify-content: center; font-size: 14px; color: #fff; transition: all 0.2s; }' +
      '.check-icon.filled { border-width: 0; }' +
      '.multi-counter { text-align: center; font-size: 13px; color: var(--text2); margin: 4px 0 8px; }' +

      /* Feedback */
      '.feedback-box { padding: 16px; border-radius: 10px; margin: 16px 0 8px; }' +
      '.feedback-box.correct { background: rgba(52,199,89,0.08); border: 1px solid rgba(52,199,89,0.2); }' +
      '.feedback-box.incorrect { background: rgba(255,59,48,0.06); border: 1px solid rgba(255,59,48,0.15); }' +
      '.feedback-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }' +
      '.feedback-icon { font-size: 20px; }' +
      '.feedback-label { font-size: 16px; font-weight: 700; }' +
      '.feedback-box.correct .feedback-label { color: var(--green); }' +
      '.feedback-box.incorrect .feedback-label { color: var(--red); }' +
      '.feedback-explanation { display: flex; gap: 8px; align-items: flex-start; }' +
      '.explanation-icon { font-size: 18px; flex-shrink: 0; margin-top: 2px; }' +
      '.feedback-explanation p, .review-explanation p { font-size: 14px; color: var(--text2); line-height: 1.6; white-space: pre-line; }' +
      '.review-explanation { background: rgba(0,122,255,0.06); border: 1px solid rgba(0,122,255,0.15); display: flex; gap: 8px; align-items: flex-start; }' +

      /* Action buttons */
      '.question-actions { margin-top: 16px; }' +
      '.primary-btn { width: 100%; padding: 14px; border-radius: 12px; border: none; color: #fff; font-size: 17px; font-weight: 600; cursor: pointer; transition: opacity 0.2s, transform 0.15s; }' +
      '.primary-btn:hover { opacity: 0.92; }' +
      '.primary-btn:active { transform: scale(0.98); }' +
      '.primary-btn:disabled { opacity: 0.4; cursor: not-allowed; transform: none; }' +
      '.submit-btn { }' +

      /* Results */
      '.results-screen { padding: 20px 0; text-align: center; }' +
      '.score-circle-container { position: relative; display: inline-flex; align-items: center; justify-content: center; margin: 16px 0 24px; }' +
      '.score-svg { display: block; }' +
      '.score-bg { stroke: var(--separator); }' +
      '.score-progress { transition: stroke-dashoffset 1s ease-out; }' +
      '.score-text { position: absolute; display: flex; flex-direction: column; align-items: center; }' +
      '.score-pct { font-size: 36px; font-weight: 800; }' +
      '.score-label { font-size: 14px; color: var(--text2); font-weight: 500; }' +
      '.result-indicator { display: flex; align-items: center; justify-content: center; gap: 8px; margin-bottom: 16px; }' +
      '.result-icon { font-size: 22px; }' +
      '.result-grade { font-size: 24px; font-weight: 700; }' +
      '.result-summary { font-size: 16px; color: var(--text2); margin-bottom: 24px; }' +
      '.result-summary strong { color: var(--text); }' +
      '.result-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(80px, 1fr)); gap: 10px; margin-bottom: 28px; }' +
      '.stat-card { padding: 14px 8px; border-radius: 12px; text-align: center; }' +
      '.stat-card.correct { background: rgba(52,199,89,0.1); }' +
      '.stat-card.incorrect { background: rgba(255,59,48,0.1); }' +
      '.stat-card.total { background: rgba(0,122,255,0.1); }' +
      '.stat-card.flagged { background: rgba(255,149,0,0.1); }' +
      '.stat-num { display: block; font-size: 28px; font-weight: 700; }' +
      '.stat-card.correct .stat-num { color: var(--green); }' +
      '.stat-card.incorrect .stat-num { color: var(--red); }' +
      '.stat-card.total .stat-num { color: var(--blue); }' +
      '.stat-card.flagged .stat-num { color: var(--orange); }' +
      '.stat-lbl { font-size: 12px; color: var(--text2); text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px; }' +
      '.result-actions { display: flex; flex-direction: column; gap: 10px; }' +
      '.result-action-btn { display: flex; align-items: center; justify-content: center; gap: 8px; width: 100%; padding: 14px; border-radius: 12px; ' +
        'font-size: 16px; font-weight: 600; cursor: pointer; border: 1.5px solid var(--separator); background: var(--card-bg); color: var(--text); transition: transform 0.15s; }' +
      '.result-action-btn:hover { transform: translateY(-1px); }' +
      '.result-action-btn:active { transform: scale(0.98); }' +
      '.result-action-btn.retry-btn { color: #fff; border-color: transparent; }' +
      '.result-action-btn.flagged-btn { border-color: var(--orange); color: var(--orange); }' +
      '.ra-icon { font-size: 18px; }' +

      /* Review */
      '.review-screen { }' +
      '.review-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; gap: 12px; }' +
      '.review-counter { font-size: 15px; font-weight: 600; color: var(--text2); }' +
      '.remove-flag-btn { background: none; border: 1px solid var(--orange); color: var(--orange); padding: 6px 12px; border-radius: 8px; cursor: pointer; font-size: 13px; font-weight: 600; }' +
      '.review-card { }' +
      '.review-nav { display: flex; gap: 10px; margin-top: 16px; }' +

      /* Back bar button */
      '.back-bar-btn { background: none; border: none; color: var(--blue); font-size: 16px; cursor: pointer; padding: 8px 0; display: inline-flex; align-items: center; }' +
      '.back-bar-btn:hover { opacity: 0.8; }' +

      /* Nav buttons */
      '.nav-btn { flex: 1; padding: 12px; border-radius: 10px; border: 1.5px solid var(--separator); background: var(--card-bg); ' +
        'font-size: 15px; font-weight: 600; cursor: pointer; color: var(--text); transition: background 0.2s; }' +
      '.nav-btn:hover:not(:disabled) { background: var(--bg); }' +
      '.nav-btn:disabled { opacity: 0.35; cursor: not-allowed; }' +

      /* Study Home */
      '.study-home { }' +
      '.study-overview { background: var(--card-bg); border-radius: var(--radius); padding: 20px; margin-bottom: 16px; box-shadow: var(--card-shadow); border: 1px solid var(--separator); }' +
      '.study-overview-header { display: flex; align-items: center; gap: 12px; margin-bottom: 14px; }' +
      '.study-overview-icon { font-size: 36px; }' +
      '.study-overview-info h3 { font-size: 20px; font-weight: 700; }' +
      '.overview-confident { font-size: 14px; color: var(--text2); }' +
      '.progress-bar { height: 8px; background: var(--separator); border-radius: 4px; overflow: hidden; }' +
      '.progress-fill { height: 100%; border-radius: 4px; transition: width 0.4s ease; }' +
      '.progress-bar-sm { height: 5px; background: var(--separator); border-radius: 3px; overflow: hidden; margin-top: 8px; }' +
      '.progress-fill-sm { height: 100%; border-radius: 3px; transition: width 0.3s ease; }' +

      /* Needs Review Card */
      '.needs-review-card { display: flex; align-items: center; gap: 12px; width: 100%; padding: 16px; background: var(--card-bg); ' +
        'border-radius: var(--radius); border: 1.5px solid var(--orange); cursor: pointer; margin-bottom: 16px; text-align: left; transition: transform 0.15s; }' +
      '.needs-review-card:hover { transform: translateX(2px); }' +
      '.nr-icon { font-size: 24px; }' +
      '.nr-info { flex: 1; }' +
      '.nr-title { font-size: 16px; font-weight: 600; display: block; color: var(--text); }' +
      '.nr-count { font-size: 13px; color: var(--orange); }' +

      /* Section Cards */
      '.section-list { display: flex; flex-direction: column; gap: 10px; }' +
      '.study-section-card { display: flex; align-items: center; gap: 14px; width: 100%; padding: 16px; background: var(--card-bg); ' +
        'border-radius: var(--radius); border: 1px solid var(--separator); cursor: pointer; text-align: left; box-shadow: var(--card-shadow); transition: transform 0.15s; }' +
      '.study-section-card:hover { transform: translateX(2px); }' +
      '.section-icon-box { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }' +
      '.section-info { flex: 1; min-width: 0; }' +
      '.section-title { font-size: 16px; font-weight: 600; display: block; margin-bottom: 2px; color: var(--text); }' +
      '.section-meta { font-size: 13px; color: var(--text2); }' +
      '.section-progress-row { display: flex; align-items: center; gap: 8px; margin-top: 4px; }' +
      '.section-confident { font-size: 12px; color: var(--text2); }' +
      '.section-chevron { font-size: 22px; color: var(--text3); flex-shrink: 0; }' +

      /* Objective List */
      '.objective-list-screen { }' +
      '.section-header-card { display: flex; align-items: center; gap: 14px; padding: 16px; background: var(--card-bg); border-radius: var(--radius); ' +
        'margin: 12px 0 16px; box-shadow: var(--card-shadow); border: 1px solid var(--separator); }' +
      '.objectives-container { display: flex; flex-direction: column; gap: 10px; }' +
      '.objective-card { display: flex; align-items: center; gap: 12px; width: 100%; padding: 16px; background: var(--card-bg); ' +
        'border-radius: var(--radius); border: 1px solid var(--separator); cursor: pointer; text-align: left; box-shadow: var(--card-shadow); transition: transform 0.15s; }' +
      '.objective-card:hover { transform: translateX(2px); }' +
      '.obj-info { flex: 1; min-width: 0; }' +
      '.obj-title { font-size: 15px; font-weight: 600; display: block; margin-bottom: 3px; color: var(--text); line-height: 1.4; }' +
      '.obj-meta { font-size: 13px; color: var(--text2); }' +
      '.obj-status-row { display: flex; align-items: center; gap: 8px; margin-top: 4px; flex-wrap: wrap; }' +
      '.obj-confident-count { font-size: 12px; font-weight: 600; }' +
      '.obj-review-badge { font-size: 11px; color: var(--orange); background: rgba(255,149,0,0.12); padding: 2px 8px; border-radius: 6px; font-weight: 600; }' +

      /* Topic Study */
      '.topic-study-screen { }' +
      '.topic-nav-bar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }' +
      '.topic-counter { font-size: 15px; font-weight: 600; color: var(--text2); }' +
      '.topic-content { background: var(--card-bg); border-radius: var(--radius); padding: 20px; box-shadow: var(--card-shadow); border: 1px solid var(--separator); }' +
      '.topic-header { margin-bottom: 16px; }' +
      '.topic-number { font-size: 13px; font-weight: 700; letter-spacing: 0.5px; }' +
      '.topic-obj-title { display: block; font-size: 13px; color: var(--text2); margin-top: 4px; }' +
      '.topic-question { font-size: 17px; font-weight: 500; line-height: 1.6; margin-bottom: 20px; white-space: pre-line; }' +
      '.answer-box { padding: 16px; border-radius: 10px; margin-bottom: 16px; }' +
      '.answer-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }' +
      '.answer-icon { font-size: 18px; }' +
      '.answer-label { font-size: 14px; font-weight: 700; color: var(--text2); }' +
      '.answer-text { font-size: 15px; color: var(--text); line-height: 1.7; white-space: pre-line; }' +
      '.toggle-answer-btn { margin-bottom: 20px; }' +

      /* Confidence Buttons */
      '.confidence-buttons { display: flex; gap: 8px; margin-bottom: 20px; }' +
      '.confidence-btn { flex: 1; padding: 10px 6px; border-radius: 10px; border: 1.5px solid; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s; }' +
      '.confidence-btn:hover { opacity: 0.85; }' +
      '.confidence-btn:active { transform: scale(0.96); }' +

      /* Topic Dots */
      '.topic-dots { display: flex; justify-content: center; gap: 6px; flex-wrap: wrap; margin-bottom: 16px; padding: 8px 0; }' +
      '.topic-dot { width: 10px; height: 10px; border-radius: 50%; cursor: pointer; transition: transform 0.2s; opacity: 0.6; }' +
      '.topic-dot.active-dot { transform: scale(1.4); opacity: 1; box-shadow: 0 0 0 2px var(--bg), 0 0 0 3.5px currentColor; }' +
      '.topic-dot:hover { transform: scale(1.3); opacity: 0.9; }' +
      '.topic-nav-buttons { display: flex; gap: 10px; }' +

      /* Needs Review Screen */
      '.needs-review-screen { }' +
      '.nr-screen-title { font-size: 22px; font-weight: 700; margin: 12px 0 16px; }' +
      '.nr-items { display: flex; flex-direction: column; gap: 10px; }' +
      '.needs-review-item { width: 100%; padding: 16px; background: var(--card-bg); border-radius: var(--radius); ' +
        'border: 1px solid var(--separator); border-left: 4px solid var(--orange); cursor: pointer; text-align: left; box-shadow: var(--card-shadow); transition: transform 0.15s; }' +
      '.needs-review-item:hover { transform: translateX(2px); }' +
      '.nr-item-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }' +
      '.nr-warning-icon { font-size: 16px; }' +
      '.nr-section-badge { font-size: 11px; font-weight: 600; padding: 3px 8px; border-radius: 6px; }' +
      '.nr-item-question { font-size: 15px; font-weight: 500; margin-bottom: 6px; line-height: 1.5; color: var(--text); }' +
      '.nr-item-objective { font-size: 12px; color: var(--text2); }' +

      /* Empty state */
      '.empty-state { text-align: center; padding: 48px 20px; }' +
      '.empty-icon { font-size: 48px; display: block; margin-bottom: 12px; }' +
      '.empty-state h3 { font-size: 20px; font-weight: 700; margin-bottom: 8px; }' +
      '.empty-state p { font-size: 15px; color: var(--text2); }' +

      /* Error screen */
      '.error-screen { text-align: center; padding: 60px 20px; }' +
      '.error-screen h2 { margin-bottom: 12px; }' +
      '.error-screen button { margin-top: 16px; padding: 10px 24px; border-radius: 10px; border: none; background: var(--blue); color: #fff; font-size: 16px; cursor: pointer; }' +

      /* Review empty */
      '.review-empty { padding: 0; }' +

      /* Responsive */
      '@media (max-width: 600px) {' +
        '.cert-grid { grid-template-columns: 1fr; }' +
        '.result-stats { grid-template-columns: repeat(2, 1fr); }' +
        '.confidence-buttons { flex-direction: column; }' +
      '}' +

      /* Scrollbar */
      '#app { overflow-y: auto; }' +

      /* Loading state */
      '.loading-screen { display: flex; align-items: center; justify-content: center; height: 100vh; }' +
      '.loading-spinner { width: 40px; height: 40px; border: 4px solid var(--separator); border-top-color: var(--blue); border-radius: 50%; animation: spin 0.8s linear infinite; }' +
      '@keyframes spin { to { transform: rotate(360deg); } }' +

      /* Reference Guide link */
      '.guide-link-bar { padding: 12px 16px 0; }' +
      '.guide-link-btn { display: flex; align-items: center; gap: 10px; width: 100%; padding: 12px 16px; background: var(--card-bg); border: 1px solid var(--separator); border-radius: 12px; text-decoration: none; color: var(--text); font-size: 15px; font-weight: 500; transition: background 0.15s; }' +
      '.guide-link-btn:hover { background: var(--hover-bg, var(--grouped-bg)); }' +
      '.guide-link-icon { font-size: 20px; }' +
      '.guide-link-text { flex: 1; }' +
      '.guide-link-chevron { color: var(--secondary-text); font-size: 18px; font-weight: 300; }' +

      '';
    document.head.appendChild(style);
  }

  // ── Initialize ────────────────────────────────────────────

  // Inject CSS immediately
  injectStyles();

  // Show loading state
  document.addEventListener('DOMContentLoaded', function () {
    var app = document.getElementById('app');
    if (app && !app.innerHTML.trim()) {
      app.innerHTML = '<div class="loading-screen"><div class="loading-spinner"></div></div>';
    }
  });

})();
