#!/bin/sh
set -e

echo "Activating feature 'yo'"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

cat > /usr/local/bin/yo \
<< EOF
#!/bin/sh
npm install --global --silent yo

# Add a yeoman user because Yeoman freaks out and runs setuid(501).
# This was because less technical people would run Yeoman as root and cause problems.
# Setting uid to 501 here since it's already a random number being thrown around.
# @see https://github.com/yeoman/yeoman.github.io/issues/282
# @see https://github.com/cthulhu666/docker-yeoman/blob/master/Dockerfile
adduser --disabled-password --quiet -u 501 yeoman && \
  echo "yeoman ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Yeoman needs the use of a home directory for caching and certain config storage.
export HOME=/home/yeoman

mkdir /home/yeoman && chown yeoman:yeoman /home/yeoman
mkdir /generated && chown yeoman:yeoman /generated

# Always run as the yeoman user
export USER=yeoman

EOF

chmod +x /usr/local/bin/yo


