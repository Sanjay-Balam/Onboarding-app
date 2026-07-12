import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from "@nestjs/common";
import { Request } from "express";

// Double-submit CSRF: mutating requests must echo the csrf_token cookie in the
// x-csrf-token header. Safe (GET/HEAD/OPTIONS) methods are exempt.
const SAFE = new Set(["GET", "HEAD", "OPTIONS"]);

@Injectable()
export class CsrfGuard implements CanActivate {
  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest<Request>();
    if (SAFE.has(req.method)) return true;

    const cookie = req.cookies?.csrf_token;
    const header = req.headers["x-csrf-token"];
    if (!cookie || !header || cookie !== header) {
      throw new ForbiddenException("Invalid CSRF token");
    }
    return true;
  }
}
