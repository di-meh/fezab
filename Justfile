# Docker compose variable definition
DC := "docker compose"

# Build Docker images
build:
    {{DC}} build

# Start services defined in docker-compose.yml
[positional-arguments]
up *args='':
    {{DC}} up -d {{args}}

# Stop and remove all containers
[positional-arguments]
down *args='':
    {{DC}} down {{args}}

# Run Prisma migrations with a specific name
prisma-migrate name="":
    {{DC}} exec app pnpx prisma migrate dev --name "{{name}}"