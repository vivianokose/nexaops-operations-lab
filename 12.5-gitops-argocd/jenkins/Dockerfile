# Jenkins for Module 12.5, running in Docker inside WSL.
# It builds images and commits tags to git. It has NO cluster access.
FROM jenkins/jenkins:lts-jdk21

USER root

# Docker CLI + buildx, copied out of Docker's official CLI image
# (a multi-stage trick from Module 7: take only the files you need).
COPY --from=docker:27-cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker:27-cli /usr/local/libexec/docker/cli-plugins/docker-buildx \
     /usr/local/libexec/docker/cli-plugins/docker-buildx

# Kustomize, pinned, for "kustomize edit set image" in the GitOps stage.
ARG KUSTOMIZE_VERSION=v5.4.3
RUN curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin kustomize \
 && kustomize version

USER jenkins

# Plugins baked into the image, so the setup wizard can skip downloading them.
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
