import SwiftUI
import WebKit

// MARK: - Reference Guide View

struct ReferenceGuideView: View {
    let guideFile: String
    let certConfig: CertConfig

    @State private var htmlContent: String?
    @State private var loadError: String?

    var body: some View {
        Group {
            if let html = htmlContent {
                WebViewWrapper(htmlString: html)
                    .ignoresSafeArea(edges: .bottom)
            } else if let error = loadError {
                ContentUnavailableView {
                    Label("Guide Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                }
            } else {
                ProgressView("Loading guide...")
            }
        }
        .task {
            loadGuide()
        }
    }

    private func loadGuide() {
        // Load the markdown content from the app bundle
        guard let mdURL = Bundle.main.url(forResource: guideFile, withExtension: "md"),
              let mdContent = try? String(contentsOf: mdURL, encoding: .utf8) else {
            loadError = "Could not find guide file \"\(guideFile).md\" in the app bundle."
            return
        }

        // Load marked.min.js from the app bundle
        guard let jsURL = Bundle.main.url(forResource: "marked.min", withExtension: "js"),
              let jsContent = try? String(contentsOf: jsURL, encoding: .utf8) else {
            loadError = "Could not find the markdown renderer in the app bundle."
            return
        }

        // JSON-encode the markdown for safe JS embedding
        guard let jsonData = try? JSONSerialization.data(withJSONObject: mdContent, options: .fragmentsAllowed),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            loadError = "Failed to encode guide content."
            return
        }

        htmlContent = buildHTML(markdownJSON: jsonString, markedJS: jsContent)
    }

    // MARK: - HTML Builder

    private func buildHTML(markdownJSON: String, markedJS: String) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Reference Guide</title>
          <style>
            :root {
              --bg: #F2F2F7;
              --bg2: #FFFFFF;
              --bg3: #E5E5EA;
              --text: #1C1C1E;
              --text2: #636366;
              --text3: #AEAEB2;
              --separator: #C6C6C8;
              --link: #007AFF;
              --code-bg: #F0F0F5;
              --table-stripe: #F8F8FC;
              --radius: 10px;
              --shadow: 0 1px 3px rgba(0,0,0,0.08);
              --sidebar-w: 280px;
            }
            @media (prefers-color-scheme: dark) {
              :root {
                --bg: #000000;
                --bg2: #1C1C1E;
                --bg3: #2C2C2E;
                --text: #F2F2F7;
                --text2: #AEAEB2;
                --text3: #636366;
                --separator: #38383A;
                --link: #0A84FF;
                --code-bg: #2C2C2E;
                --table-stripe: #252528;
                --shadow: 0 1px 3px rgba(0,0,0,0.3);
              }
            }

            * { margin: 0; padding: 0; box-sizing: border-box; }

            html { scroll-padding-top: 16px; }

            body {
              font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", system-ui, sans-serif;
              background: var(--bg);
              color: var(--text);
              line-height: 1.65;
              font-size: 16px;
              -webkit-font-smoothing: antialiased;
            }

            /* Sidebar (desktop / iPad landscape, >=900px) */
            .sidebar {
              display: none;
            }

            @media (min-width: 900px) {
              .sidebar {
                display: block;
                position: fixed;
                top: 0;
                left: 0;
                bottom: 0;
                width: var(--sidebar-w);
                background: var(--bg2);
                border-right: 1px solid var(--separator);
                overflow-y: auto;
                overflow-x: hidden;
                padding: 16px 0;
                z-index: 50;
                scrollbar-width: thin;
                scrollbar-color: var(--separator) transparent;
              }
              .sidebar::-webkit-scrollbar { width: 4px; }
              .sidebar::-webkit-scrollbar-track { background: transparent; }
              .sidebar::-webkit-scrollbar-thumb { background: var(--separator); border-radius: 2px; }

              .main-content {
                margin-left: var(--sidebar-w);
              }
            }

            .sidebar-title {
              padding: 0 16px 10px;
              font-size: 11px;
              font-weight: 700;
              text-transform: uppercase;
              letter-spacing: 0.6px;
              color: var(--text3);
            }

            .sidebar-list {
              list-style: none;
              padding: 0;
            }
            .sidebar-list li a {
              display: block;
              padding: 5px 16px 5px 16px;
              font-size: 13px;
              line-height: 1.4;
              color: var(--text2);
              text-decoration: none;
              border-left: 3px solid transparent;
              transition: background 0.1s, color 0.1s, border-color 0.1s;
            }
            .sidebar-list li a:hover {
              background: var(--bg3);
              color: var(--text);
            }
            .sidebar-list li a.active {
              color: var(--link);
              border-left-color: var(--link);
              background: rgba(0, 122, 255, 0.06);
              font-weight: 600;
            }
            .sidebar-list li.toc-h3 a {
              padding-left: 32px;
              font-size: 12.5px;
            }

            /* Main content */
            .container {
              max-width: 820px;
              margin: 0 auto;
              padding: 24px 20px 80px;
            }

            /* Content styles */
            .guide-content h1 {
              font-size: 28px;
              font-weight: 800;
              margin: 0 0 8px;
              line-height: 1.2;
            }
            .guide-content h2 {
              font-size: 22px;
              font-weight: 700;
              margin: 40px 0 16px;
              padding-top: 20px;
              border-top: 1px solid var(--separator);
              line-height: 1.3;
            }
            .guide-content h2:first-child { border-top: none; margin-top: 0; padding-top: 0; }
            .guide-content h3 {
              font-size: 18px;
              font-weight: 600;
              margin: 28px 0 12px;
              line-height: 1.3;
            }
            .guide-content h4 {
              font-size: 16px;
              font-weight: 600;
              margin: 20px 0 8px;
            }
            .guide-content p { margin: 0 0 14px; }
            .guide-content ul, .guide-content ol {
              margin: 0 0 14px;
              padding-left: 24px;
            }
            .guide-content li { margin: 4px 0; }
            .guide-content li > ul, .guide-content li > ol { margin: 4px 0 4px; }
            .guide-content strong { font-weight: 600; }
            .guide-content a { color: var(--link); text-decoration: none; }
            .guide-content a:hover { text-decoration: underline; }
            .guide-content hr {
              border: none;
              border-top: 1px solid var(--separator);
              margin: 32px 0;
            }
            .guide-content blockquote {
              border-left: 3px solid var(--link);
              padding: 10px 16px;
              margin: 0 0 14px;
              background: var(--code-bg);
              border-radius: 0 var(--radius) var(--radius) 0;
              color: var(--text2);
              font-size: 15px;
            }
            .guide-content blockquote p { margin: 0 0 6px; }
            .guide-content blockquote p:last-child { margin: 0; }

            /* Tables */
            .table-wrap {
              overflow-x: auto;
              margin: 0 0 14px;
              border: 1px solid var(--separator);
              border-radius: var(--radius);
            }
            .guide-content table {
              width: 100%;
              border-collapse: collapse;
              font-size: 14px;
            }
            .guide-content th {
              background: var(--bg3);
              font-weight: 600;
              text-align: left;
              padding: 10px 12px;
              white-space: nowrap;
            }
            .guide-content td {
              padding: 8px 12px;
              border-top: 1px solid var(--separator);
              vertical-align: top;
            }
            .guide-content tr:nth-child(even) td { background: var(--table-stripe); }

            /* Code */
            .guide-content code {
              font-family: "SF Mono", "Menlo", "Monaco", "Courier New", monospace;
              font-size: 13px;
              background: var(--code-bg);
              padding: 2px 6px;
              border-radius: 4px;
            }
            .guide-content pre {
              background: var(--code-bg);
              border: 1px solid var(--separator);
              border-radius: var(--radius);
              padding: 14px 16px;
              overflow-x: auto;
              margin: 0 0 14px;
              font-size: 13px;
              line-height: 1.5;
            }
            .guide-content pre code {
              background: none;
              padding: 0;
              border-radius: 0;
              font-size: inherit;
            }

            /* Scroll-to-top */
            .scroll-top {
              position: fixed;
              bottom: 24px;
              right: 24px;
              width: 44px;
              height: 44px;
              border-radius: 50%;
              background: var(--bg2);
              border: 1px solid var(--separator);
              box-shadow: 0 2px 8px rgba(0,0,0,0.15);
              cursor: pointer;
              display: none;
              align-items: center;
              justify-content: center;
              font-size: 20px;
              color: var(--text2);
              z-index: 99;
              transition: opacity 0.2s;
            }
            .scroll-top.visible { display: flex; }
            .scroll-top:hover { background: var(--bg3); }

            @media (max-width: 600px) {
              .guide-content h1 { font-size: 24px; }
              .guide-content h2 { font-size: 19px; }
              .guide-content h3 { font-size: 16px; }
              .container { padding: 16px 14px 60px; }
              .guide-content pre { font-size: 12px; padding: 10px 12px; }
              .guide-content table { font-size: 13px; }
            }

            @media print {
              .scroll-top, .sidebar { display: none !important; }
              .main-content { margin-left: 0 !important; }
              .container { max-width: 100%; padding: 0; }
            }
          </style>
        </head>
        <body>

          <div class="layout">
            <nav class="sidebar" id="sidebar">
              <div class="sidebar-title">Table of Contents</div>
              <ol class="sidebar-list" id="sidebarList"></ol>
            </nav>

            <div class="main-content">
              <div class="container">
                <div id="content" class="guide-content"></div>
              </div>
            </div>
          </div>

          <button class="scroll-top" id="scrollTop" title="Back to top">&uarr;</button>

          <script>\(markedJS)</script>
          <script>
            (function() {
              var md = \(markdownJSON);

              // Configure marked
              marked.setOptions({ breaks: false, gfm: true });

              // GitHub-style heading slug
              var usedIds = {};
              function githubSlug(text) {
                var slug = text.toLowerCase()
                  .replace(/<[^>]*>/g, '')
                  .replace(/\\u2014/g, '--')
                  .replace(/ & /g, ' -- ')
                  .replace(/ \\+ /g, ' -- ')
                  .replace(/[^\\w\\s-]/g, '')
                  .replace(/\\s+/g, '-')
                  .replace(/-{3,}/g, '--')
                  .replace(/^-+|-+$/g, '');
                if (usedIds[slug]) {
                  usedIds[slug]++;
                  slug = slug + '-' + (usedIds[slug] - 1);
                } else {
                  usedIds[slug] = 1;
                }
                return slug;
              }

              // Custom renderer
              var renderer = new marked.Renderer();
              renderer.heading = function(token) {
                var text = typeof token === 'object' && token.text ? token.text : String(token);
                var depth = typeof token === 'object' && token.depth ? token.depth : 2;
                var rawText = text.replace(/<[^>]*>/g, '');
                var id = githubSlug(rawText);
                return '<h' + depth + ' id="' + id + '">' + text + '</h' + depth + '>\\n';
              };
              renderer.table = function(header, body) {
                if (typeof header === 'object' && header.header && header.rows) {
                  var token = header;
                  var html = '<div class="table-wrap"><table><thead><tr>';
                  token.header.forEach(function(cell) {
                    html += '<th>' + this.parser.parseInline(cell.tokens) + '</th>';
                  }.bind(this));
                  html += '</tr></thead><tbody>';
                  token.rows.forEach(function(row) {
                    html += '<tr>';
                    row.forEach(function(cell) {
                      html += '<td>' + this.parser.parseInline(cell.tokens) + '</td>';
                    }.bind(this));
                    html += '</tr>';
                  }.bind(this));
                  html += '</tbody></table></div>';
                  return html;
                }
                return '<div class="table-wrap"><table><thead>' + header + '</thead><tbody>' + body + '</tbody></table></div>';
              };

              // Render
              var html = marked.parse(md, { renderer: renderer });
              document.getElementById('content').innerHTML = html;

              buildTOC();
              wrapTables();
              initScrollSpy();

              function buildTOC() {
                var content = document.getElementById('content');
                var headings = content.querySelectorAll('h2, h3');
                if (headings.length === 0) return;

                var items = [];
                headings.forEach(function(h) {
                  var text = h.textContent;
                  var id = h.id;
                  if (!id) {
                    id = text.toLowerCase().replace(/[^\\w\\s-]/g, '').replace(/\\s+/g, '-').replace(/^-+|-+$/g, '');
                    h.id = id;
                  }
                  items.push({ level: h.tagName.toLowerCase(), text: text, id: id });
                });

                var sidebarHtml = '';
                items.forEach(function(item) {
                  var cls = item.level === 'h3' ? ' class="toc-h3"' : '';
                  sidebarHtml += '<li' + cls + '><a href="#' + item.id + '" data-toc-id="' + item.id + '">' + item.text + '</a></li>';
                });
                document.getElementById('sidebarList').innerHTML = sidebarHtml;
              }

              function initScrollSpy() {
                var sidebarLinks = document.querySelectorAll('.sidebar-list a[data-toc-id]');
                if (sidebarLinks.length === 0) return;

                var headingEls = [];
                sidebarLinks.forEach(function(link) {
                  var el = document.getElementById(link.getAttribute('data-toc-id'));
                  if (el) headingEls.push({ el: el, link: link });
                });

                var ticking = false;
                function onScroll() {
                  if (ticking) return;
                  ticking = true;
                  requestAnimationFrame(function() {
                    var scrollY = window.scrollY + 60;
                    var activeIdx = 0;
                    for (var i = headingEls.length - 1; i >= 0; i--) {
                      if (headingEls[i].el.offsetTop <= scrollY) {
                        activeIdx = i;
                        break;
                      }
                    }
                    sidebarLinks.forEach(function(l) { l.classList.remove('active'); });
                    headingEls[activeIdx].link.classList.add('active');

                    var activeLink = headingEls[activeIdx].link;
                    var sidebar = document.getElementById('sidebar');
                    var linkTop = activeLink.offsetTop;
                    var sidebarHeight = sidebar.clientHeight;
                    if (linkTop < sidebar.scrollTop + 60 || linkTop > sidebar.scrollTop + sidebarHeight - 60) {
                      sidebar.scrollTo({ top: linkTop - sidebarHeight / 3, behavior: 'smooth' });
                    }

                    ticking = false;
                  });
                }
                window.addEventListener('scroll', onScroll, { passive: true });
                onScroll();
              }

              function wrapTables() {
                var tables = document.querySelectorAll('.guide-content table');
                tables.forEach(function(table) {
                  if (table.parentElement.classList.contains('table-wrap')) return;
                  var wrapper = document.createElement('div');
                  wrapper.className = 'table-wrap';
                  table.parentNode.insertBefore(wrapper, table);
                  wrapper.appendChild(table);
                });
              }

              // Scroll-to-top button
              var scrollBtn = document.getElementById('scrollTop');
              window.addEventListener('scroll', function() {
                if (window.scrollY > 400) {
                  scrollBtn.classList.add('visible');
                } else {
                  scrollBtn.classList.remove('visible');
                }
              });
              scrollBtn.addEventListener('click', function() {
                window.scrollTo({ top: 0, behavior: 'smooth' });
              });

              // Smooth scroll for anchor links
              document.addEventListener('click', function(e) {
                var link = e.target.closest('a[href^="#"]');
                if (link) {
                  e.preventDefault();
                  var targetId = link.getAttribute('href').slice(1);
                  var target = document.getElementById(targetId);
                  if (target) {
                    var targetTop = target.getBoundingClientRect().top + window.pageYOffset - 16;
                    window.scrollTo({ top: targetTop, behavior: 'smooth' });
                    history.replaceState(null, '', '#' + targetId);
                  }
                }
              });
            })();
          </script>
        </body>
        </html>
        """
    }
}

// MARK: - Navigation Delegate

private class ExternalLinkDelegate: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Allow in-page anchors and initial content load
        if url.scheme == nil || url.scheme == "about" || url.absoluteString.hasPrefix("about:") {
            decisionHandler(.allow)
            return
        }

        // Open external links in the system browser
        if url.scheme == "http" || url.scheme == "https" {
            #if os(iOS)
            UIApplication.shared.open(url)
            #elseif os(macOS)
            NSWorkspace.shared.open(url)
            #endif
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}

// MARK: - Platform-specific WebView Wrappers

#if os(iOS)
import UIKit

private struct WebViewWrapper: UIViewRepresentable {
    let htmlString: String

    func makeCoordinator() -> ExternalLinkDelegate {
        ExternalLinkDelegate()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
#elseif os(macOS)
import AppKit

private struct WebViewWrapper: NSViewRepresentable {
    let htmlString: String

    func makeCoordinator() -> ExternalLinkDelegate {
        ExternalLinkDelegate()
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.loadHTMLString(htmlString, baseURL: nil)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {}
}
#endif
