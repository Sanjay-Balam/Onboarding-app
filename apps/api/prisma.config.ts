import { config } from "dotenv";
import { defineConfig, env } from "prisma/config";

// Backend env by NODE_ENV (cwd is apps/api when Prisma runs).
config({ path: process.env.NODE_ENV === "production" ? ".env.production" : ".env.development" });

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
