import { randomBytes } from "crypto";

// Generated login email for a new Chef (User.email = login ID).
export function genLoginEmail(): string {
  return `chef.${randomBytes(4).toString("hex")}@onboarding.local`;
}

// 12-char url-safe temp password, returned to Admin once.
export function genTempPassword(): string {
  return randomBytes(9).toString("base64url").slice(0, 12);
}

// Pure RBAC check used by RolesGuard.
export function hasRole(userRoles: string[] | undefined, required: string[]): boolean {
  if (!required.length) return true;
  return !!userRoles && required.some((r) => userRoles.includes(r));
}
