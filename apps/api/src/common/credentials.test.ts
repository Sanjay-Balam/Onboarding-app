import assert from "assert";
import { genLoginEmail, genTempPassword, hasRole } from "./credentials";

// login emails are unique and well-formed
const emails = new Set(Array.from({ length: 1000 }, genLoginEmail));
assert.equal(emails.size, 1000, "login emails must be unique");
for (const e of emails) assert.match(e, /^chef\.[0-9a-f]{8}@onboarding\.local$/);

// temp passwords are 12 chars, url-safe, and vary
const pw = genTempPassword();
assert.equal(pw.length, 12);
assert.match(pw, /^[A-Za-z0-9_-]{12}$/);
assert.notEqual(genTempPassword(), genTempPassword());

// RBAC guard logic
assert.equal(hasRole(["ADMIN"], ["ADMIN"]), true);
assert.equal(hasRole(["CHEF"], ["ADMIN"]), false, "chef must not pass admin gate");
assert.equal(hasRole(undefined, ["ADMIN"]), false, "no roles must fail");
assert.equal(hasRole(["CHEF"], []), true, "empty requirement allows any");

console.log("credentials + RBAC checks passed");
