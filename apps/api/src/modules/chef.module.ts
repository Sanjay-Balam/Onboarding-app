import { Module } from "@nestjs/common";
import { ChefAttendanceController } from "../controllers/chef/attendance.controller";
import { ChefDocumentsController } from "../controllers/chef/documents.controller";
import { ChefAttendanceService } from "../services/chef-attendance.service";
import { ChefDocumentsService } from "../services/chef-documents.service";

@Module({
  controllers: [ChefAttendanceController, ChefDocumentsController],
  providers: [ChefAttendanceService, ChefDocumentsService],
})
export class ChefModule {}
