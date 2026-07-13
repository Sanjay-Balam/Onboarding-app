import { ConflictException, Injectable, NotFoundException } from "@nestjs/common";
import { hash } from "bcrypt";
import { PrismaService } from "../database/prisma.service";
import { CreateChefDto } from "../common/dto";

@Injectable()
export class ChefsService {
  constructor(private prisma: PrismaService) {}

  // Admin creates a Chef with the entered email + password, assigns CHEF role, creates profile.
  async create({ name, email, phone, password, is2faEnabled }: CreateChefDto) {
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException("Email already in use");

    const chefRole = await this.prisma.roleDefinition.upsert({
      where: { name: "CHEF" },
      update: {},
      create: { name: "CHEF", description: "Staff" },
    });

    const user = await this.prisma.user.create({
      data: {
        email,
        name,
        phone,
        is2faEnabled: is2faEnabled ?? false,
        passwordHash: await hash(password, 10),
        roleAssignments: { create: { roleDefinitionId: chefRole.id } },
        chefProfile: { create: {} },
      },
      include: { chefProfile: true },
    });

    return {
      chefProfileId: user.chefProfile!.id,
      userId: user.id,
      name: user.name,
      email: user.email,
    };
  }

  list() {
    return this.prisma.chefProfile.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        user: { select: { id: true, email: true, name: true, phone: true, isActive: true, is2faEnabled: true } },
        _count: { select: { documents: true, attendance: true } },
      },
    });
  }

  async get(chefProfileId: string) {
    const chef = await this.prisma.chefProfile.findUnique({
      where: { id: chefProfileId },
      include: {
        user: { select: { id: true, email: true, name: true, phone: true, isActive: true, is2faEnabled: true } },
        documents: true,
      },
    });
    if (!chef) throw new NotFoundException("Chef not found");
    return chef;
  }

  async setTwoFactor(chefProfileId: string, enabled: boolean) {
    // Drives LOGIN 2FA — set it on the user (that's what auth checks).
    const chef = await this.get(chefProfileId);
    await this.prisma.user.update({ where: { id: chef.user.id }, data: { is2faEnabled: enabled } });
    return { id: chefProfileId, is2faEnabled: enabled };
  }

  async approve(chefProfileId: string, adminUserId: string) {
    await this.get(chefProfileId);
    return this.prisma.chefProfile.update({
      where: { id: chefProfileId },
      data: { onboardingStatus: "APPROVED", approvedAt: new Date(), approvedById: adminUserId },
    });
  }

  async reject(chefProfileId: string) {
    await this.get(chefProfileId);
    return this.prisma.chefProfile.update({
      where: { id: chefProfileId },
      data: { onboardingStatus: "REJECTED", approvedAt: null, approvedById: null },
    });
  }
}
