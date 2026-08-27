# Runbook: Jenkins disaster recovery

## Purpose
What to do if the Jenkins server is lost (crash, deletion, provider failure). The goal is
to get pipelines working again with minimal fuss. Because the pipeline is code in git, most
of the recovery is redeploy-and-reconfigure, not rebuild-from-memory.

## What is safe even if Jenkins dies
- The **Jenkinsfile** lives in the application repo (voyageai-booking-api). Not lost.
- The **shared library** lives in its own repo (jenkins-shared-lib). Not lost.
- The **application code and Docker images** live in GitHub and Docker Hub. Not lost.
- Only the **Jenkins server itself** and its **credentials** need rebuilding.

## Recovery steps

### 1. Stand up a new Jenkins server
- Provision a new server (4GB RAM minimum for Jenkins).
- Install Java 21 (Jenkins requires it), then Jenkins from the official repo.
- If the signing key fails to verify, fetch it from the keyserver by ID:
  `gpg --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68`
- Install Docker on the server and add the jenkins user to the docker group.
- Install Node.js (the pipeline runs npm).

### 2. Restore access
- Firewall: allow SSH and port 8080 from your IP, and 8080 from GitHub's webhook IP ranges.
- Regenerate the SSH deploy key for the jenkins user and add its public key to the app
  server's authorized_keys.

### 3. Re-add credentials (these are the only things not in git)
Recreate each credential in Jenkins with the same IDs the Jenkinsfile expects:
- `jenkins-deploy-key` , SSH private key for the app server (username: root)
- `app-server-ip` , secret text, the app server's IP
- `dockerhub-credentials` , Docker Hub username and access token
- `github-token` , GitHub username and personal access token

### 4. Recreate the jobs
- Register the shared library under Manage Jenkins > System > Global Pipeline Libraries,
  name `voyageai-lib`, pointing at the jenkins-shared-lib repo, default version main.
- Create the pipeline job (or multibranch job) pointing at the voyageai-booking-api repo,
  script path Jenkinsfile.

### 5. Re-establish the webhook
- In the GitHub repo, point the webhook at the new Jenkins server's
  `/github-webhook/` URL, and confirm a green delivery.

### 6. Verify
- Push a trivial commit and confirm the pipeline triggers, runs green, and deploys.

## Prevention for next time
- Enable Jenkins backups (the built-in backup, or snapshot /var/lib/jenkins).
- Keep this runbook and the credential list (IDs only, never the secret values) in git.
- Consider configuration-as-code (JCasC) so Jenkins settings are reproducible from a file.
