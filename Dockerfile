FROM node:16-alpine AS builder
WORKDIR /app

RUN corepack enable
COPY pnpm-lock.yaml ./
RUN pnpm fetch --prod

ADD . ./
RUN pnpm install --prod --offline

FROM node:16-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/nextjs ./apps/nextjs

USER nextjs

EXPOSE 3000
ENV PORT 3000
WORKDIR /app/apps/nextjs

CMD ["node_modules/.bin/next", "start"]