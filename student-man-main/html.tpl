<!DOCTYPE html>
<html>
<head>
    <title>Trivy Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background: #f0f0f0; }
        .critical { background: #ffebee; color: #c62828; }
        .high { background: #fff3e0; color: #ef6c00; }
        .medium { background: #fffde7; color: #f9a825; }
        .low { background: #e8f5e9; color: #2e7d32; }
    </style>
</head>
<body>
    <h1>Trivy Vulnerability Scan Report</h1>
    <p><strong>Image:</strong> {{ .ArtifactName }}</p>
    <p><strong>Scanned at:</strong> {{ now }}</p>

    {{ range .Results }}
        <h2>{{ .Target }} ({{ .Type }})</h2>
        {{ if .Vulnerabilities }}
            <table>
                <tr>
                    <th>ID</th>
                    <th>Severity</th>
                    <th>Title</th>
                    <th>Installed</th>
                    <th>Fixed In</th>
                </tr>
                {{ range .Vulnerabilities }}
                <tr class="{{ .Severity | lower }}">
                    <td><a href="https://nvd.nist.gov/vuln/detail/{{ .VulnerabilityID }}" target="_blank">{{ .VulnerabilityID }}</a></td>
                    <td><strong>{{ .Severity }}</strong></td>
                    <td>{{ .Title }}</td>
                    <td>{{ .PkgName }} {{ .InstalledVersion }}</td>
                    <td>{{ if .FixedVersion }}{{ .FixedVersion }}{{ else }}—{{ end }}</td>
                </tr>
                {{ end }}
            </table>
        {{ else }}
            <p>No vulnerabilities found.</p>
        {{ end }}
    {{ end }}
</body>
</html>
