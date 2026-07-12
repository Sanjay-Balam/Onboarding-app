import { config } from "dotenv";
// Backend env (cwd is apps/api for both dev and prod).
config({ path: ".env.development" });

import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import cookieParser from "cookie-parser";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(cookieParser());
  // Credentials on: browser must send/receive the auth + csrf cookies.
  app.enableCors({
    origin: (process.env.CORS_ORIGINS ?? "http://localhost:8080").split(","),
    credentials: true,
  });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`API on http://localhost:${port}`);
}
bootstrap();
