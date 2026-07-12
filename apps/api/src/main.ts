import { config } from "dotenv";
// Backend env (cwd is apps/api for both dev and prod).
config({ path: ".env.development" });

import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`API on http://localhost:${port}`);
}
bootstrap();
