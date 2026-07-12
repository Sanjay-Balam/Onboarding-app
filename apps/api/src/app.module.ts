import { Module } from "@nestjs/common";
import { PrismaModule } from "./database/prisma.module";
import { AuthModule } from "./auth/auth.module";
import { AdminModule } from "./modules/admin.module";
import { HealthController } from "./controllers/health.controller";

@Module({
  imports: [PrismaModule, AuthModule, AdminModule],
  controllers: [HealthController],
})
export class AppModule {}
