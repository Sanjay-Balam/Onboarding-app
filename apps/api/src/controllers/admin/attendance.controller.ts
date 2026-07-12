import { Controller, Get, Query, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { RolesGuard } from "../../auth/roles.guard";
import { Roles } from "../../common/decorators";
import { AttendanceService } from "../../services/attendance.service";

@Controller("admin/attendance")
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles("ADMIN")
export class AdminAttendanceController {
  constructor(private readonly attendance: AttendanceService) {}

  @Get()
  list(@Query("chefId") chefId?: string, @Query("date") date?: string) {
    return this.attendance.list(chefId, date);
  }
}
