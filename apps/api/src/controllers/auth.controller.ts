import { Body, Controller, Get, Post, Res, UseGuards } from "@nestjs/common";
import { Response } from "express";
import { AuthService } from "../auth/auth.service";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { CurrentUser } from "../common/decorators";
import { LoginDto } from "../common/dto";

const isProd = process.env.NODE_ENV === "production";
const cookieBase = {
  sameSite: (isProd ? "none" : "lax") as "none" | "lax",
  secure: isProd,
  path: "/",
  maxAge: 24 * 60 * 60 * 1000, // 1 day
};

@Controller("auth")
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post("login")
  async login(@Body() dto: LoginDto, @Res({ passthrough: true }) res: Response) {
    const { accessToken, csrfToken, requires2fa, user } = await this.auth.login(dto);
    // JWT in an httpOnly cookie (JS can't read it → XSS-safe).
    res.cookie("access_token", accessToken, { ...cookieBase, httpOnly: true });
    // CSRF token readable by the client for the double-submit header.
    res.cookie("csrf_token", csrfToken, { ...cookieBase, httpOnly: false });
    return { requires2fa, csrfToken, user };
  }

  // Restore session on app reload: reads the httpOnly JWT cookie, returns the user.
  @Get("me")
  @UseGuards(JwtAuthGuard)
  me(@CurrentUser() u: { userId: string; email: string; name: string | null; roles: string[] }) {
    return { user: { id: u.userId, email: u.email, name: u.name, roles: u.roles } };
  }

  @Post("logout")
  logout(@Res({ passthrough: true }) res: Response) {
    res.clearCookie("access_token", { path: "/" });
    res.clearCookie("csrf_token", { path: "/" });
    return { ok: true };
  }
}
