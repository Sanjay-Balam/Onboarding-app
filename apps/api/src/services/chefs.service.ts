import { Injectable, NotFoundException } from "@nestjs/common";
import { hash } from "bcrypt";
import { PrismaService } from "../database/prisma.service";
import { genLoginEmail, genTempPassword } from "../common/credentials";
import { CreateChefDto } from "../common/dto";

@Injectable()
export class ChefsService {
  constructor(private prisma: PrismaService) {}

  // Admin creates a Chef: generates login email + temp password, assigns CHEF role,
  // creates the chef profile. Plaintext password is returned ONCE.
  async create({ name, phone }: CreateChefDto) {
    const chefRole = await this.prisma.roleDefinition.upsert({
      where: { name: "CHEF" },
      update: {},
      create: { name: "CHEF", description: "Staff" },
    });

    const loginEmail = genLoginEmail();
    const tempPassword = genTempPassword();

    const user = await this.prisma.user.create({
      data: {
        email: loginEmail,
        name,
        phone,
        passwordHash: await hash(tempPassword, 10),
        roleAssignments: { create: { roleDefinitionId: chefRole.id } },
        chefProfile: { create: {} },
      },
      include: { chefProfile: true },
    });

    return {
      chefProfileId: user.chefProfile!.id,
      userId: user.id,
      name: user.name,
      phone: user.phone,
      loginEmail,
      tempPassword, // shown once — Admin must relay to Chef
    };
  }

  list() {
    return this.prisma.chefProfile.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        user: { select: { id: true, email: true, name: true, phone: true, isActive: true } },
        _count: { select: { documents: true, attendance: true } },
      },
    });
  }

  async get(chefProfileId: string) {
    const chef = await this.prisma.chefProfile.findUnique({
      where: { id: chefProfileId },
      include: {
        user: { select: { id: true, email: true, name: true, phone: true, isActive: true } },
        documents: true,
      },
    });
    if (!chef) throw new NotFoundException("Chef not found");
    return chef;
  }

  async setTwoFactor(chefProfileId: string, enabled: boolean) {
    await this.get(chefProfileId);
    return this.prisma.chefProfile.update({
      where: { id: chefProfileId },
      data: { is2faEnabled: enabled },
    });
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
