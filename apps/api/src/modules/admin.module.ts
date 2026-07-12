import { Module } from "@nestjs/common";
import { AdminChefsController } from "../controllers/admin/chefs.controller";
import { AdminAttendanceController } from "../controllers/admin/attendance.controller";
import { AdminDocumentsController } from "../controllers/admin/documents.controller";
import { ChefsService } from "../services/chefs.service";
import { AttendanceService } from "../services/attendance.service";
import { DocumentsService } from "../services/documents.service";

@Module({
  controllers: [AdminChefsController, AdminAttendanceController, AdminDocumentsController],
  providers: [ChefsService, AttendanceService, DocumentsService],
})
export class AdminModule {}
