import { BadRequestException, ForbiddenException, Injectable } from "@nestjs/common";
import { PrismaService } from "../database/prisma.service";
import { StorageService } from "../storage/storage.service";
import { DocumentType } from "../../generated/prisma";

const ALLOWED_MIME: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "application/pdf": "pdf",
};
const MAX_BYTES = 5 * 1024 * 1024; // 5 MB
const TYPES = new Set(Object.values(DocumentType));

@Injectable()
export class ChefDocumentsService {
  constructor(private prisma: PrismaService, private storage: StorageService) {}

  private async profileId(userId: string): Promise<string> {
    const p = await this.prisma.chefProfile.findUnique({ where: { userId } });
    if (!p) throw new ForbiddenException("Not a chef account");
    return p.id;
  }

  async upload(userId: string, type: string, file?: Express.Multer.File) {
    if (!file) throw new BadRequestException("No file provided");
    if (!TYPES.has(type as DocumentType)) throw new BadRequestException("Invalid document type");
    const ext = ALLOWED_MIME[file.mimetype];
    if (!ext) throw new BadRequestException("Only JPEG, PNG or PDF allowed");
    if (file.size > MAX_BYTES) throw new BadRequestException("File exceeds 5 MB");

    const chefProfileId = await this.profileId(userId);
    const storageKey = `kyc/${chefProfileId}/${type.toLowerCase()}.${ext}`;
    await this.storage.upload(storageKey, file.buffer, file.mimetype);

    // Re-uploading a slot replaces it (unique chefProfileId+type). Verification resets.
    const doc = await this.prisma.document.upsert({
      where: { chefProfileId_type: { chefProfileId, type: type as DocumentType } },
      update: { storageKey, mimeType: file.mimetype, sizeBytes: file.size, verified: false },
      create: { chefProfileId, type: type as DocumentType, storageKey, mimeType: file.mimetype, sizeBytes: file.size },
    });

    // All required docs present → PENDING_APPROVAL (admin can approve); else IN_PROGRESS.
    const required: DocumentType[] = ["AADHAAR_FRONT", "AADHAAR_BACK", "PAN"];
    const have = new Set(
      (await this.prisma.document.findMany({ where: { chefProfileId }, select: { type: true } })).map((d) => d.type),
    );
    const complete = required.every((t) => have.has(t));
    await this.prisma.chefProfile.update({
      where: { id: chefProfileId },
      data: { onboardingStatus: complete ? "PENDING_APPROVAL" : "IN_PROGRESS" },
    });
    return doc;
  }

  async summary(userId: string) {
    const profile = await this.prisma.chefProfile.findUnique({
      where: { userId },
      include: { documents: { orderBy: { uploadedAt: "desc" } } },
    });
    if (!profile) throw new ForbiddenException("Not a chef account");
    return { onboardingStatus: profile.onboardingStatus, documents: profile.documents };
  }
}
