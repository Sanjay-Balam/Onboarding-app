import { Module } from "@nestjs/common";
import { ChefAttendanceController } from "../controllers/chef/attendance.controller";
import { ChefAttendanceService } from "../services/chef-attendance.service";

@Module({
  controllers: [ChefAttendanceController],
  providers: [ChefAttendanceService],
})
export class ChefModule {}
