import { Body, Controller, Get, Post, UploadedFile, UseGuards, UseInterceptors } from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { RolesGuard } from "../../auth/roles.guard";
import { CsrfGuard } from "../../auth/csrf.guard";
import { CurrentUser, Roles } from "../../common/decorators";
import { ChefDocumentsService } from "../../services/chef-documents.service";

@Controller("chef/documents")
@UseGuards(JwtAuthGuard, RolesGuard, CsrfGuard)
@Roles("CHEF")
export class ChefDocumentsController {
  constructor(private readonly docs: ChefDocumentsService) {}

  @Get()
  summary(@CurrentUser() user: { userId: string }) {
    return this.docs.summary(user.userId);
  }

  // multipart/form-data: fields { type }, file field "file".
  @Post()
  @UseInterceptors(FileInterceptor("file"))
  upload(
    @CurrentUser() user: { userId: string },
    @Body("type") type: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    return this.docs.upload(user.userId, type, file);
  }
}
