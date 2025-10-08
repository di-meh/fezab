# Définition de la variable pour docker compose
DC := "docker compose"

build:
    {{DC}} build
up:
    {{DC}} up
down:
    {{DC}} down
prisma-migrate name="":
    {{DC}} exec app pnpx prisma migrate dev --name "{{name}}"