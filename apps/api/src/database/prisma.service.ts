import { Injectable, OnModuleInit, OnModuleDestroy } from "@nestjs/common";
import { PrismaClient } from "../../generated/prisma";
import { PrismaPg } from "@prisma/adapter-pg";

// Prisma 7: PrismaClient requires a driver adapter.
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor() {
    const url = process.env.DATABASE_URL ?? "";
    const isSupabase = url.includes("supabase.");
    super({
      adapter: new PrismaPg({
        connectionString: isSupabase ? url.split("?")[0] : url,
        // Supabase's CA isn't in node's trust store; skip strict verify.
        ssl: isSupabase ? { rejectUnauthorized: false } : undefined,
      }),
    });
  }
  async onModuleInit() {
    await this.$connect();
  }
  async onModuleDestroy() {
    await this.$disconnect();
  }
}
