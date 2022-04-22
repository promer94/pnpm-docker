FROM node:16-alpine AS deps

WORKDIR /app
COPY ./pnpm-lock.yaml ./pnpm-lock.yaml

RUN corepack enable
# https://pnpm.io/cli/fetch
RUN pnpm fetch --prod

FROM node:16-alpine AS builder
WORKDIR /app

COPY ./pnpm-lock.yaml ./pnpm-lock.yaml
COPY ./pnpm-workspace.yaml ./pnpm-workspace.yaml
COPY ./turbo.json ./turbo.json
COPY ./packages ./packages
COPY ./apps/nextjs ./apps/nextjs
COPY --from=deps /app/node_modules ./node_modules

RUN corepack enable
# https://pnpm.io/cli/install#--prod--p
RUN pnpm install --prod --offline



# 3. Production image, copy all the files and run next
FROM node:16-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder ./apps/nextjs ./apps/nextjs

USER nextjs

EXPOSE 3000

ENV PORT 3000
WORKDIR /app/apps/nextjs

CMD ["node_modules/.bin/next", "start"]