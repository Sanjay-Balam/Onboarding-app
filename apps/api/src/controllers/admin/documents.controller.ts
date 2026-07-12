import { Body, Controller, Get, Param, Patch, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "../../auth/jwt-auth.guard";
import { RolesGuard } from "../../auth/roles.guard";
import { CsrfGuard } from "../../auth/csrf.guard";
import { Roles } from "../../common/decorators";
import { DocumentsService } from "../../services/documents.service";
import { VerifyDocumentDto } from "../../common/dto";

@Controller("admin")
@UseGuards(JwtAuthGuard, RolesGuard, CsrfGuard)
@Roles("ADMIN")
export class AdminDocumentsController {
  constructor(private readonly documents: DocumentsService) {}

  @Get("chefs/:id/documents")
  listForChef(@Param("id") chefProfileId: string) {
    return this.documents.listForChef(chefProfileId);
  }

  @Patch("documents/:docId/verify")
  verify(@Param("docId") docId: string, @Body() dto: VerifyDocumentDto) {
    return this.documents.setVerified(docId, dto.verified);
  }
}
