<!DOCTYPE html>
<html>
<head>
    <title>Trivy Report</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background: #f0f0f0; }
        .critical { background: #ffebee; }
        .high { background: #fff3e0; }
    </style>
</head>
<body>
    <h1>Trivy Scan - {{ index .Results 0 "ArtifactName" }}</h1>
    <p><strong>Scanned:</strong> {{ now }}</p>

    {{ range .Results }}
        {{ if .Vulnerabilities }}
            <h2>{{ .Target }}</h2>
            <table>
                <tr><th>ID</th><th>Severity</th><th>Title</th><th>Installed</th></tr>
                {{ range .Vulnerabilities }}
                <tr class="{{ .Severity | lower }}">
                    <td><a href="https://nvd.nist.gov/vuln/detail/{{ .VulnerabilityID }}">{{ .VulnerabilityID }}</a></td>
                    <td><strong>{{ .Severity }}</strong></td>
                    <td>{{ .Title }}</td>
                    <td>{{ .PkgName }} {{ .InstalledVersion }}</td>
                </tr>
                {{ end }}
            </table>
        {{ else }}
            <p>No vulnerabilities found in {{ .Target }}.</p>
        {{ end }}
    {{ end }}
</body>
</html>
