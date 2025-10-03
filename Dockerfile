FROM oven/bun:1.2.23-alpine AS base
WORKDIR /usr/src/app

FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json bun.lock /temp/dev/
RUN cd /temp/dev && bun install --frozen-lockfile

# install with --production (exclude devDependencies)
RUN mkdir -p /temp/prod
COPY package.json bun.lock /temp/prod/
RUN cd /temp/prod && bun install --frozen-lockfile --production

# copy node_modules from temp directory
# then copy all (non-ignored) project files into the image
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

# [optional] tests & build
ENV NODE_ENV=production
# RUN bun run test
RUN bun run build

# copy dev dependencies and source code into dev image
FROM base AS dev
COPY --from=install /temp/dev/node_modules node_modules
COPY --from=prerelease /usr/src/app .
RUN chown -R bun /usr/src/app

USER bun
EXPOSE 5173
CMD ["bun", "run", "dev"]

# copy production dependencies and source code into final image
FROM base AS release
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /usr/src/app/build .

USER bun
EXPOSE 80
ENV PORT=80
CMD ["bun", "run", "build/index.js"]