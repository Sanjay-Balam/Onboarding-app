import { ConflictException, ForbiddenException, Injectable } from "@nestjs/common";
import { PrismaService } from "../database/prisma.service";

// Server-decided "today" — the chef can never check in for a past/future date
// because the date is set here, not supplied by the client.
function today(): Date {
  const n = new Date();
  // UTC midnight of the local calendar day → @db.Date stores the intended day
  // (avoids the local-midnight→prev-UTC-day off-by-one).
  return new Date(Date.UTC(n.getFullYear(), n.getMonth(), n.getDate()));
}

@Injectable()
export class ChefAttendanceService {
  constructor(private prisma: PrismaService) {}

  private async profile(userId: string) {
    const profile = await this.prisma.chefProfile.findUnique({ where: { userId } });
    if (!profile) throw new ForbiddenException("Not a chef account");
    return profile;
  }

  async checkIn(userId: string) {
    const profile = await this.profile(userId);
    // Only APPROVED chefs may mark attendance.
    if (profile.onboardingStatus !== "APPROVED") {
      throw new ForbiddenException("Complete the verification process first");
    }
    const existing = await this.prisma.attendanceLog.findUnique({
      where: { chefProfileId_date: { chefProfileId: profile.id, date: today() } },
    });
    if (existing) throw new ConflictException("Already checked in today");
    return this.prisma.attendanceLog.create({
      data: { chefProfileId: profile.id, date: today() },
    });
  }

  async summary(userId: string) {
    const profile = await this.profile(userId);
    const [todayLog, recent] = await Promise.all([
      this.prisma.attendanceLog.findUnique({
        where: { chefProfileId_date: { chefProfileId: profile.id, date: today() } },
      }),
      this.prisma.attendanceLog.findMany({
        where: { chefProfileId: profile.id },
        orderBy: { checkInAt: "desc" },
        take: 10,
      }),
    ]);
    return {
      onboardingStatus: profile.onboardingStatus,
      canCheckIn: profile.onboardingStatus === "APPROVED",
      checkedInToday: !!todayLog,
      today: todayLog,
      recent,
    };
  }
}
