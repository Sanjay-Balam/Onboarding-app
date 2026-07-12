import "dotenv/config";
import { PrismaClient } from "../generated/prisma";
import { PrismaPg } from "@prisma/adapter-pg";

// Prisma 7: PrismaClient requires a driver adapter.
const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

async function main() {
  // Roles (RBAC lives in role_definitions, not on the user).
  const [admin, chef] = await Promise.all([
    prisma.roleDefinition.upsert({
      where: { name: "ADMIN" },
      update: {},
      create: { name: "ADMIN", description: "Business owner" },
    }),
    prisma.roleDefinition.upsert({
      where: { name: "CHEF" },
      update: {},
      create: { name: "CHEF", description: "Staff" },
    }),
  ]);

  // ponytail: placeholder hash — replace once the auth/hashing service exists.
  const passwordHash = "$2b$10$REPLACE_ME_WITH_A_REAL_BCRYPT_HASH................";

  const adminUser = await prisma.user.upsert({
    where: { email: "admin@chefonboarding.local" },
    update: {},
    create: {
      email: "admin@chefonboarding.local",
      passwordHash,
      roleAssignments: { create: { roleDefinitionId: admin.id } },
    },
  });

  await prisma.user.upsert({
    where: { email: "chef@chefonboarding.local" },
    update: {},
    create: {
      email: "chef@chefonboarding.local",
      passwordHash,
      phone: "+910000000000",
      roleAssignments: { create: { roleDefinitionId: chef.id, assignedBy: adminUser.id } },
      chefProfile: { create: {} },
    },
  });

  console.log("Seeded roles ADMIN/CHEF + admin & chef users.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
