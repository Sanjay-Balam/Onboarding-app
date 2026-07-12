import { Body, Controller, Get, Param, Patch, Post, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { RolesGuard } from "../../auth/roles.guard";
import { CurrentUser, Roles } from "../../common/decorators";
import { ChefsService } from "../../services/chefs.service";
import { CreateChefDto, Toggle2faDto } from "../../common/dto";

@Controller("admin/chefs")
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles("ADMIN")
export class AdminChefsController {
  constructor(private readonly chefs: ChefsService) {}

  @Post()
  create(@Body() dto: CreateChefDto) {
    return this.chefs.create(dto);
  }

  @Get()
  list() {
    return this.chefs.list();
  }

  @Get(":id")
  get(@Param("id") id: string) {
    return this.chefs.get(id);
  }

  @Patch(":id/2fa")
  toggle2fa(@Param("id") id: string, @Body() dto: Toggle2faDto) {
    return this.chefs.setTwoFactor(id, dto.enabled);
  }

  @Patch(":id/approve")
  approve(@Param("id") id: string, @CurrentUser() user: { userId: string }) {
    return this.chefs.approve(id, user.userId);
  }

  @Patch(":id/reject")
  reject(@Param("id") id: string) {
    return this.chefs.reject(id);
  }
}
