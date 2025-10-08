FROM node:lts-slim AS base
WORKDIR /usr/src/app
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*
RUN corepack enable

FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json pnpm-*.yaml /temp/dev/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store cd /temp/dev && pnpm install --frozen-lockfile

# install with --production (exclude devDependencies)
RUN mkdir -p /temp/prod
COPY package.json pnpm-*.yaml /temp/prod/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store cd /temp/prod && pnpm install --frozen-lockfile --prod

# copy node_modules from temp directory
# then copy all (non-ignored) project files into the image
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

# [optional] tests & build
ENV NODE_ENV=production
# RUN pnpm run test
RUN pnpm run build

# copy dev dependencies and source code into dev image
FROM base AS dev
COPY --from=install /temp/dev/node_modules node_modules
COPY --from=prerelease /usr/src/app .
RUN chown -R node /usr/src/app

USER node
EXPOSE 5173
CMD ["pnpm", "run", "dev"]

# copy production dependencies and source code into final image
FROM base AS release
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /usr/src/app/build .

USER pnpm
EXPOSE 80
ENV PORT=80
CMD ["node", "build/index.js"]