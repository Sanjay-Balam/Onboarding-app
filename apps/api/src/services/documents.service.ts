import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../database/prisma.service";
import { StorageService } from "../storage/storage.service";

@Injectable()
export class DocumentsService {
  constructor(private prisma: PrismaService, private storage: StorageService) {}

  // Short-lived presigned URL for the admin to view a KYC file.
  async viewUrl(documentId: string) {
    const doc = await this.prisma.document.findUnique({ where: { id: documentId } });
    if (!doc) throw new NotFoundException("Document not found");
    return { url: await this.storage.signDownloadUrl(doc.storageKey) };
  }

  // KYC metadata only. File bytes + signed URLs deferred until a storage provider is chosen.
  listForChef(chefProfileId: string) {
    return this.prisma.document.findMany({
      where: { chefProfileId },
      orderBy: { uploadedAt: "desc" },
    });
  }

  async setVerified(documentId: string, verified: boolean) {
    const doc = await this.prisma.document.findUnique({ where: { id: documentId } });
    if (!doc) throw new NotFoundException("Document not found");
    return this.prisma.document.update({ where: { id: documentId }, data: { verified } });
  }
}
