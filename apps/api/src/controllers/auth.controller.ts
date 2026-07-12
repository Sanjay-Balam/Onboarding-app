import { Body, Controller, Post } from "@nestjs/common";
import { AuthService } from "../auth/auth.service";
import { LoginDto } from "../common/dto";

@Controller("auth")
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post("login")
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }
}
