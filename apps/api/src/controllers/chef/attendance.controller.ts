import { Controller, Get, Post, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { RolesGuard } from "../../auth/roles.guard";
import { CsrfGuard } from "../../auth/csrf.guard";
import { CurrentUser, Roles } from "../../common/decorators";
import { ChefAttendanceService } from "../../services/chef-attendance.service";

@Controller("chef/attendance")
@UseGuards(JwtAuthGuard, RolesGuard, CsrfGuard)
@Roles("CHEF")
export class ChefAttendanceController {
  constructor(private readonly attendance: ChefAttendanceService) {}

  @Get()
  summary(@CurrentUser() user: { userId: string }) {
    return this.attendance.summary(user.userId);
  }

  @Post("check-in")
  checkIn(@CurrentUser() user: { userId: string }) {
    return this.attendance.checkIn(user.userId);
  }
}
