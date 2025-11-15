# Installer et utiliser Semgrep sur Windows (PowerShell)

Ce document décrit les options pour installer `semgrep` sur une machine Windows où `python` n'est pas installé, et fournit des commandes PowerShell concrètes pour la séance.

---

## 1) Vérifier si `winget` ou `choco` est disponible
PowerShell :

```powershell
winget --version
# ou
choco --version
```

Si `winget` ou `choco` n'est pas installé, installez Python depuis https://www.python.org/downloads/ ou via l'installateur Windows.

## 2) Installer Python (recommandé) avec `winget` (Windows 10/11)

```powershell
# Installe Python 3 (version stable depuis winget)
winget install --id Python.Python.3 -e --source winget

# Fermez et rouvrez PowerShell après l'install pour mettre à jour le PATH
```

Alternative via Chocolatey (si `choco` installé) :

```powershell
choco install python -y
# Fermez et rouvrez PowerShell
```

## 3) Installer `pipx` (isole semgrep du Python global) et `semgrep`

```powershell
# installer pipx (user install)
python -m pip install --upgrade pip
python -m pip install --user pipx
python -m pipx ensurepath

# Fermez et rouvrez PowerShell _avant_ l'étape suivante

# installer semgrep via pipx (binaire isolé et mis sur PATH)
pipx install semgrep

# vérifier
semgrep --version
```

Remarque : si `pipx` n'est pas souhaité, installer directement via pip :

```powershell
python -m pip install --upgrade pip
python -m pip install semgrep
# puis vérifier
semgrep --version
```

## 4) Utiliser semgrep (depuis la racine du repo)

```powershell
cd C:\Vagrant\PROJECT\student-management-devops
semgrep --config=auto .

# ou pour la config CI officielle
semgrep --config=p/ci .
```

Si `semgrep` renvoie `CommandNotFound`, relancez PowerShell après l'étape `ensurepath` (ou ouvrez une nouvelle fenêtre).

## 5) Option Docker (pas de Python installé)

Si vous préférez ne rien installer localement, exécutez Semgrep via Docker (nécessite Docker Desktop) :

```powershell
docker run --rm -v ${PWD}:/src returntocorp/semgrep semgrep --config=auto /src
```

Remarque PowerShell : `${PWD}` mappe le dossier courant de PowerShell.

## 6) Dépannage rapide

- Erreur `python not found` : installez Python ou utilisez l'image Docker. Fermez/rouvrez PowerShell après les installs.
- `pipx` n'est pas sur PATH : exécutez `python -m pipx ensurepath`, puis redémarrez le terminal.
- Permissions : si l'installation pip échoue, exécutez la commande sans `--user` en tant qu'administrateur.

## 7) Commandes récapitulatives (à copier-coller)

```powershell
# 1) installer Python via winget
winget install --id Python.Python.3 -e --source winget

# 2) installer pipx + semgrep
python -m pip install --upgrade pip
python -m pip install --user pipx
python -m pipx ensurepath
# fermer/rouvrir PowerShell
pipx install semgrep
semgrep --version

# 3) lancer un scan
cd C:\Vagrant\PROJECT\student-management-devops
semgrep --config=auto .

# 4) alternative Docker (si Docker ok)
docker run --rm -v ${PWD}:/src returntocorp/semgrep semgrep --config=auto /src
```

---

Si vous voulez, je peux :
- ajouter un script PowerShell `scripts/install-semgrep.ps1` automatisant l'installation (winget/pipx),
- ou exécuter localement `semgrep --config=auto .` ici si vous installez Python et me dites quand c'est prêt.

Bonne séance !
