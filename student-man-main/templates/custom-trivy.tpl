<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <title>Trivy Scan - Student Management (ghaith6789)</title>
  <style>
    body { font-family: 'Segoe UI', sans-serif; background: #0f172a; color: #e2e8f0; padding: 20px; }
    .header { text-align: center; padding: 30px; background: linear-gradient(135deg, #1e293b, #334155); border-radius: 12px; margin-bottom: 30px; }
    .header h1 { color: #38bdf8; margin: 0; font-size: 2.5em; }
    .header p { color: #94a3b8; font-size: 1.1em; }
    .container { max-width: 1200px; margin: auto; background: #1e293b; padding: 25px; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th { background: #334155; color: #38bdf8; padding: 15px; text-align: left; }
    td { padding: 12px; border-bottom: 1px solid #475569; }
    .critical { background: #7f1d1d; color: #fca5a5; }
    .high { background: #9a3412; color: #fdba74; }
    .medium { background: #78350f; color: #fbbf24; }
    .footer { text-align: center; margin-top: 40px; color: #64748b; font-size: 0.9em; }
    .badge { display: inline-block; padding: 5px 12px; border-radius: 20px; font-weight: bold; font-size: 0.8em; }
  </style>
</head>
<body>
  <div class="header">
    <h1>Trivy Security Scan</h1>
    <p><strong>Image:</strong> {{ .ArtifactName }} | <strong>Scan:</strong> {{ now }} | <strong>ghaith6789</strong></p>
  </div>

  <div class="container">
    {{ range .Results }}
      {{ if .Vulnerabilities }}
        <h2>Vulnérabilités détectées ({{ len .Vulnerabilities }})</h2>
        <table>
          <tr>
            <th>ID</th>
            <th>Sévérité</th>
            <th>Package</th>
            <th>Version</th>
            <th>Description</th>
          </tr>
          {{ range .Vulnerabilities }}
            <tr class="{{ .Severity | lower }}">
              <td><strong>{{ .VulnerabilityID }}</strong></td>
              <td><span class="badge {{ .Severity | lower }}">{{ .Severity }}</span></td>
              <td>{{ .PkgName }}</td>
              <td>{{ .InstalledVersion }}</td>
              <td>{{ .Title }}</td>
            </tr>
          {{ end }}
        </table>
      {{ else }}
        <h2>Aucune vulnérabilité détectée</h2>
        <p>Toutes les dépendances sont sécurisées.</p>
      {{ end }}
    {{ end }}
  </div>

  <div class="footer">
    <p>Généré par <strong>Trivy</strong> | Pipeline DevSecOps par <strong>Ghaith El Benna</strong> © 2025</p>
  </div>
</body>
</html>