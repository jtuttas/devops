# ci/cd Example die ein Docker Image deployed und via terraform auf eine Cloudstackumgebung deployed

Die Pipeline nutzt zwei Phasen um den Auftrag zu erfüllen:

1. In der ersten Phase wird ein Docker Image erzeugt, welches eine HTML Seite via nginx ausliefert. Dieses Docker Image wird gegen Ender der ersten Phase auf den **DockerHub** veröffentlicht.

2. In der zweiten Phase wird mittels **terraform** auf **cloudstack** eine Infrastruktur erzeugt. Diese besteht aus einem *Subnetz* und einer *Linux VM*. Die Ports für SSH und HTTP werden geöffnet und die Firewallregeln entsprechend angepasst. Über **cloud-init** wird auf dieser Linux VM *Docker* installiert. Docker holt sich dann das in Phase 1 erstelle *Docker Image* vom **Docker Hub** und führt dieses aus.

> Terraform legt für die Beschreibung der Infrastruktur eine *tfconfig* Datei an. Damit diese Informationen außerhalb der Pipeline gespeichert und beim nächsten Durchlauf von terraform erhalten bleiben. Werden diese Informationen auf einem **Azure Blob Storage** gespeichert.

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
- `TF_VAR_docker_image_name`: Der Name des abzuholenden Docker Images, e.g. 'tuttas/devops'.


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

