import { Injectable } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { Request } from "express";
import { Strategy } from "passport-jwt";

export type JwtPayload = {
  sub: string;
  email: string;
  name: string | null;
  roles: string[];
};

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      // JWT comes from the httpOnly cookie, not the Authorization header.
      jwtFromRequest: (req: Request) => req.cookies?.access_token ?? null,
      secretOrKey: process.env.JWT_SECRET || "dev-only-change-me",
    });
  }

  // Return value is attached to request.user.
  async validate(payload: JwtPayload) {
    return {
      userId: payload.sub,
      email: payload.email,
      name: payload.name,
      roles: payload.roles,
    };
  }
}
