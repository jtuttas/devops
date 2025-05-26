# ci/cd Example die ein Docker Image deployed und via terraform auf eine Cloudstackumgebung deployed

## Notwendige Umgebungsvariablen

- `DOCKER_REGISTRY`: Die URL des Docker-Registrys, in das das Image gepusht werden soll. *docker.io* für den Docker Hub.
- `DOCKER_USERNAME`: Der Benutzername für das Docker-Registry.
- `DOCKER_PASSWORD`: Das Passwort für das Docker-Registry.
- `DOCKER_IMAGE_NAME`: Der Name des Docker-Images, das erstellt werden soll. E.g. `tuttas/myapp`.

---

- `TF_VAR_api_url`: Die URL der CloudStack-API, e.g. https://cloudstack.mm-bbs.de/client/api
- `TF_VAR_api_key`: Der API-Schlüssel für die CloudStack-API.
- `TF_VAR_secret_key`: Der geheime Schlüssel für die CloudStack-API.
