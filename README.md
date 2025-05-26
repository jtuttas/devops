# ci/cd Example die ein Docker Image deployed und via terraform auf eine Cloudstackumgebung deployed

## Notwendige Umgebungsvariablen

- `DOCKER_REGISTRY`: Die URL des Docker-Registrys, in das das Image gepusht werden soll. *docker.io* für den Docker Hub.
- `DOCKER_USERNAME`: Der Benutzername für das Docker-Registry.
- `DOCKER_PASSWORD`: Das Passwort für das Docker-Registry.
- `DOCKER_IMAGE_NAME`: Der Name des Docker-Images, das erstellt werden soll.

---

- `CLOUDSTACK_API_URL`: Die URL der CloudStack-API.
- `CLOUDSTACK_API_KEY`: Der API-Schlüssel für die CloudStack-API.
- `CLOUDSTACK_SECRET_KEY`: Der geheime Schlüssel für die CloudStack-API.    
