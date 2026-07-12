import { Module } from "@nestjs/common";
import { PrismaModule } from "./database/prisma.module";
import { AuthModule } from "./auth/auth.module";
import { AdminModule } from "./modules/admin.module";
import { ChefModule } from "./modules/chef.module";
import { HealthController } from "./controllers/health.controller";

@Module({
  imports: [PrismaModule, AuthModule, AdminModule, ChefModule],
  controllers: [HealthController],
})
export class AppModule {}
