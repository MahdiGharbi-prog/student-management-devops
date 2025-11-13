<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Trivy Scan Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f8f9fa;
        }
        h1 {
            color: #333;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
            background-color: #fff;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .CRITICAL {
            background-color: #dc3545;
            color: white;
            font-weight: bold;
        }
        .HIGH {
            background-color: #fd7e14;
            color: white;
            font-weight: bold;
        }
        .MEDIUM {
            background-color: #ffc107;
            color: black;
        }
        .LOW {
            background-color: #28a745;
            color: white;
        }
        .DATE {
            margin-top: 10px;
            font-size: 0.9em;
            color: #666;
        }
    </style>
</head>
<body>
    <h1>Trivy Vulnerability Scan Report</h1>
    <div class="DATE">Scan generated at: {{ .GeneratedAt }}</div>
    <table>
        <thead>
            <tr>
                <th>Target</th>
                <th>Type</th>
                <th>Vulnerability ID</th>
                <th>Pkg Name</th>
                <th>Installed Version</th>
                <th>Severity</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
        {{ range .Results }}
            {{ range .Vulnerabilities }}
            <tr>
                <td>{{ $.Target }}</td>
                <td>{{ $.Type }}</td>
                <td>{{ .VulnerabilityID }}</td>
                <td>{{ .PkgName }}</td>
                <td>{{ .InstalledVersion }}</td>
                <td class="{{ .Severity }}">{{ .Severity }}</td>
                <td>{{ .Description }}</td>
            </tr>
            {{ end }}
        {{ end }}
        </tbody>
    </table>
</body>
</html>
