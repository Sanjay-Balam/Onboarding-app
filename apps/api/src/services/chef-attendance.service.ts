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

  private async profileId(userId: string): Promise<string> {
    const profile = await this.prisma.chefProfile.findUnique({ where: { userId } });
    if (!profile) throw new ForbiddenException("Not a chef account");
    return profile.id;
  }

  async checkIn(userId: string) {
    const chefProfileId = await this.profileId(userId);
    const existing = await this.prisma.attendanceLog.findUnique({
      where: { chefProfileId_date: { chefProfileId, date: today() } },
    });
    if (existing) throw new ConflictException("Already checked in today");
    return this.prisma.attendanceLog.create({
      data: { chefProfileId, date: today() },
    });
  }

  async summary(userId: string) {
    const chefProfileId = await this.profileId(userId);
    const [todayLog, recent] = await Promise.all([
      this.prisma.attendanceLog.findUnique({
        where: { chefProfileId_date: { chefProfileId, date: today() } },
      }),
      this.prisma.attendanceLog.findMany({
        where: { chefProfileId },
        orderBy: { checkInAt: "desc" },
        take: 10,
      }),
    ]);
    return { checkedInToday: !!todayLog, today: todayLog, recent };
  }
}
