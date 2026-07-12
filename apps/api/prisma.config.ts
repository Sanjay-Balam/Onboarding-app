import { config } from "dotenv";
import { defineConfig, env } from "prisma/config";

// Backend env (cwd is apps/api when Prisma runs).
config({ path: ".env.development" });

// Prisma 7: schema location, seed command and connection URL live here.
export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    seed: "tsx prisma/seed.ts",
  },
  datasource: {
    url: env("DATABASE_URL"),
  },
});
