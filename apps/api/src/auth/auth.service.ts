import { Injectable, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { compare } from "bcrypt";
import { PrismaService } from "../database/prisma.service";
import { LoginDto } from "../common/dto";

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

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
    return {
      accessToken,
      user: { id: user.id, email: user.email, name: user.name, roles },
    };
  }
}
