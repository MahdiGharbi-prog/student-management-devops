<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:template match="/">
<html>
<head>
  <title>ZAP Scan - Student Management App</title>
  <style>
    body { font-family: 'Roboto', sans-serif; background: #0f172a; color: #e2e8f0; padding: 20px; }
    .header { background: #1e40af; padding: 30px; text-align: center; border-radius: 12px; }
    h1 { color: #60a5fa; margin: 0; }
    .alert { padding: 15px; margin: 10px 0; border-radius: 8px; }
    .high { background: #7f1d1d; border-left: 5px solid #ef4444; }
    .medium { background: #9a3412; border-left: 5px solid #f97316; }
    .low { background: #78350f; border-left: 5px solid #fbbf24; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    th, td { padding: 12px; border: 1px solid #475569; text-align: left; }
    th { background: #334155; color: #38bdf8; }
    .footer { text-align: center; margin-top: 50px; color: #94a3b8; font-size: 0.9em; }
  </style>
</head>
<body>
  <div class="header">
    <h1>OWASP ZAP DAST Report</h1>
    <p><strong>URL:</strong> http://host.docker.internal:8081 | <strong>Date:</strong> <xsl:value-of select="OWASPZAPReport/@generated"/></p>
    <p>Scanné par <strong>Ghaith El Benna</strong> – DevSecOps Engineer</p>
  </div>

  <div style="max-width:1200px; margin:auto; background:#1e293b; padding:25px; border-radius:12px;">
    <h2>Résumé des alertes</h2>
    <p><strong>Total:</strong> <xsl:value-of select="count(OWASPZAPReport/site/alerts/alert)"/></p>

    <xsl:for-each select="OWASPZAPReport/site/alerts/alert">
      <xsl:sort select="riskcode" order="descending"/>
      <div class="alert <xsl:value-of select="translate(riskdesc, ' ', '')"/>">
        <h3>[<xsl:value-of select="riskdesc"/>] <xsl:value-of select="name"/></h3>
        <p><strong>Description:</strong> <xsl:value-of select="desc"/></p>
        <p><strong>Solution:</strong> <xsl:value-of select="solution"/></p>
        <p><strong>URL:</strong> <xsl:value-of select="uri"/></p>
      </div>
    </xsl:for-each>
  </div>

  <div class="footer">
    <p>Généré par OWASP ZAP | Pipeline CI/CD sécurisé | <strong>ghaith6789</strong></p>
  </div>
</body>
</html>
</xsl:template>
</xsl:stylesheet>