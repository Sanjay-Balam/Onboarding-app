# Chef Onboarding — Turborepo

Monorepo: NestJS API + Prisma (Postgres) + Flutter app.

```
apps/
  api/       NestJS backend
  mobile/    Flutter app (standalone)
packages/
  database/  Prisma schema + shared client (@repo/database)
```

## Setup

```bash
pnpm install
cp .env.example .env        # edit DATABASE_URL
pnpm db:generate            # prisma client
pnpm db:migrate             # create tables
```

## Run

```bash
pnpm dev                    # turbo: runs API in watch mode
# Flutter (standalone, not in turbo):
cd apps/mobile && flutter run
```

## API

- `GET /chefs` · `GET /chefs/:id` · `POST /chefs` · `PATCH /chefs/:id` · `DELETE /chefs/:id`

## DB tools

```bash
pnpm db:studio              # prisma studio
pnpm db:migrate             # new migration
```
