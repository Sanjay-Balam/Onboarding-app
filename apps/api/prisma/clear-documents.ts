import { readFileSync } from "fs";
import { parse } from "dotenv";
import { PrismaClient } from "../generated/prisma";
import { PrismaPg } from "@prisma/adapter-pg";

const env = parse(readFileSync(new URL("../.env.development", import.meta.url)));
const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: env.DATABASE_URL.split("?")[0], ssl: { rejectUnauthorized: false } }),
});

async function main() {
  const d = await prisma.document.deleteMany({});
  const p = await prisma.chefProfile.updateMany({ data: { onboardingStatus: "NOT_STARTED" } });
  console.log("Deleted documents:", d.count, "| reset profiles:", p.count);
}
main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
