import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ROLES_KEY } from "../common/decorators";
import { hasRole } from "../common/credentials";

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      ctx.getHandler(),
      ctx.getClass(),
    ]);
    const user = ctx.switchToHttp().getRequest().user;
    if (!hasRole(user?.roles, required ?? [])) {
      throw new ForbiddenException("Insufficient role");
    }
    return true;
  }
}
