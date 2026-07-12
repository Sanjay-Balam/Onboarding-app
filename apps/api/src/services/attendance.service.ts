import { Injectable } from "@nestjs/common";
import { PrismaService } from "../database/prisma.service";

@Injectable()
export class AttendanceService {
  constructor(private prisma: PrismaService) {}

  // Admin attendance dashboard: check-in logs, newest first. Optional filters.
  list(chefProfileId?: string, date?: string) {
    return this.prisma.attendanceLog.findMany({
      where: {
        ...(chefProfileId ? { chefProfileId } : {}),
        ...(date ? { date: new Date(date) } : {}),
      },
      orderBy: { checkInAt: "desc" },
      include: { chef: { include: { user: { select: { name: true, email: true } } } } },
    });
  }
}
