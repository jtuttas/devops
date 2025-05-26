# ci/cd Example die ein Docker Image deployed und via terraform auf eine Cloudstackumgebung deployed

## Notwendige Umgebungsvariablen

### Für die Docker Image erstellung

- `DOCKER_REGISTRY`: Die URL des Docker-Registrys, in das das Image gepusht werden soll. *docker.io* für den Docker Hub.
- `DOCKER_USERNAME`: Der Benutzername für das Docker-Registry.
- `DOCKER_PASSWORD`: Das Passwort für das Docker-Registry.
- `DOCKER_IMAGE_NAME`: Der Name des Docker-Images, das erstellt werden soll. E.g. `tuttas/myapp`.

### Für die Cloudstack Umgebung

- `TF_VAR_api_url`: Die URL der CloudStack-API, e.g. https://cloudstack.mm-bbs.de/client/api
- `TF_VAR_api_key`: Der API-Schlüssel für die CloudStack-API.
- `TF_VAR_secret_key`: Der geheime Schlüssel für die CloudStack-API.

### Für den Azure Blob Storage

- `ARM_CLIENT_ID` : App id

- `ARM_CLIENT_SECRET` : password

- `ARM_SUBSCRIPTION_ID` : Subscription-ID

- `ARM_TENANT_ID` : tennant



## Einrichten des Azure Blob Storage

Die *tfstate* Datei muss außerhalb des Repositories gespeichert werden. Dazu wird ein Blob Storage auf Azure eingerichtet.

1. Anmelden in Azure

```bash
az login
```

2. Einrichten der Ressourcen

```bash
SET RESOURCE_GROUP=rg-terraform
SET STORAGE_ACCOUNT=tfstate%RANDOM%
SET CONTAINER_NAME=tfstate
SET LOCATION=westeurope

az group create --name %RESOURCE_GROUP% --location %LOCATION%

az storage account create --resource-group %RESOURCE_GROUP% --name %STORAGE_ACCOUNT% --sku Standard_LRS --encryption-services blob

az storage container create --name %CONTAINER_NAME% --account-name %STORAGE_ACCOUNT%
```

3. Schritt 3: Azure Service Principal erstellen

```bash
az ad sp create-for-rbac --name "gitlab-terraform" --role Contributor --scopes /subscriptions/%AZURE_SUBSCRIPTION_ID%

```

Ersetze %AZURE_SUBSCRIPTION_ID% durch deine eigene ID (bekommst du mit az account show)

Die Ausgabe enthält:

appId → ARM_CLIENT_ID
password → ARM_CLIENT_SECRET
tenant → ARM_TENANT_ID
Subscription-ID → ARM_SUBSCRIPTION_ID

📌 Notiere alles für GitLab CI/CD.

