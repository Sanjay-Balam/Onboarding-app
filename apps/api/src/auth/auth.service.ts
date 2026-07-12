import { BadRequestException, Injectable, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { compare } from "bcrypt";
import { randomBytes } from "crypto";
import { PrismaService } from "../database/prisma.service";
import { StorageService } from "../storage/storage.service";
import { LoginDto } from "../common/dto";

const AVATAR_MIME: Record<string, string> = { "image/jpeg": "jpg", "image/png": "png" };

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
    private storage: StorageService,
  ) {}

  // Upload/replace the user's profile picture (image only, ≤5MB).
  async setAvatar(userId: string, file?: Express.Multer.File) {
    if (!file) throw new BadRequestException("No file provided");
    const ext = AVATAR_MIME[file.mimetype];
    if (!ext) throw new BadRequestException("Only JPEG or PNG allowed");
    if (file.size > 5 * 1024 * 1024) throw new BadRequestException("Image exceeds 5 MB");
    const key = `avatars/${userId}.${ext}`;
    await this.storage.upload(key, file.buffer, file.mimetype);
    await this.prisma.user.update({ where: { id: userId }, data: { avatarKey: key } });
    return { avatarUrl: await this.storage.signDownloadUrl(key) };
  }

  // Full profile (DB-backed) for the profile screen.
  async profile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        roleAssignments: { include: { roleDefinition: true } },
        chefProfile: true,
      },
    });
    if (!user) throw new UnauthorizedException();
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      isActive: user.isActive,
      is2faEnabled: user.is2faEnabled,
      createdAt: user.createdAt,
      roles: user.roleAssignments.map((a) => a.roleDefinition.name),
      onboardingStatus: user.chefProfile?.onboardingStatus ?? null,
      avatarUrl: user.avatarKey ? await this.storage.signDownloadUrl(user.avatarKey) : null,
    };
  }

  async login({ email, password }: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { roleAssignments: { include: { roleDefinition: true } } },
    });
    if (!user || !user.isActive || !(await compare(password, user.passwordHash))) {
      throw new UnauthorizedException("Invalid credentials");
    }

    const roles = user.roleAssignments.map((a) => a.roleDefinition.name);
    const accessToken = await this.jwt.signAsync({
      sub: user.id,
      email: user.email,
      name: user.name,
      roles,
    });

    const csrfToken = randomBytes(24).toString("base64url");
    return {
      accessToken,
      csrfToken,
      requires2fa: user.is2faEnabled, // frontend shows 2FA page only when true
      user: { id: user.id, email: user.email, name: user.name, roles },
    };
  }
}
