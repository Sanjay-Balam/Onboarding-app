# Prisma (apps/api)

Prisma 7 + PostgreSQL. Schema-first data layer for the Chef Onboarding app.

## Layout

```
apps/api/
  prisma.config.ts     # Prisma 7 config: schema path, seed cmd, DATABASE_URL
  prisma/
    schema.prisma      # models
    seed.ts            # roles + demo admin/chef
    migrations/        # generated SQL migrations
  generated/prisma/    # generated client (git-ignored)
```

## Models

| Model                | Table                    | Purpose |
|----------------------|--------------------------|---------|
| `User`               | `users`                  | Login identity (email + password hash). No role column. |
| `RoleDefinition`     | `role_definitions`       | Roles (`ADMIN`, `CHEF`) as data, not an enum. |
| `UserRoleAssignment` | `user_role_assignments`  | M:N link users ↔ roles (composite PK). |
| `ChefProfile`        | `chef_profiles`          | Chef business data: 2FA toggle, onboarding status, approval. |
| `Document`           | `documents`              | KYC doc metadata (Aadhaar/PAN). File stays in a private bucket; only `storage_key` here. |
| `AttendanceLog`      | `attendance_logs`        | One check-in per chef per day. |
| `OtpToken`           | `otp_tokens`             | Hashed, short-lived, single-use 2FA OTPs. |

Conventions: UUID PKs (`gen_random_uuid()`), `snake_case` columns via `@map`, cascade deletes from `User`/`ChefProfile`.

## Commands (run in `apps/api`)

```bash
pnpm prisma generate          # build client into generated/prisma
pnpm prisma migrate dev       # create/apply a migration
pnpm prisma db seed           # run seed.ts
pnpm prisma studio            # browse data
```

`DATABASE_URL` is read from the repo `.env` via `prisma.config.ts`.
`PrismaClient` requires a driver adapter (`@prisma/adapter-pg`) — see `seed.ts`.
