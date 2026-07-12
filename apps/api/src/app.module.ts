import { Module } from "@nestjs/common";
import { PrismaModule } from "./database/prisma.module";
import { AuthModule } from "./auth/auth.module";
import { AdminModule } from "./modules/admin.module";

@Module({
  imports: [PrismaModule, AuthModule, AdminModule],
})
export class AppModule {}
