import { Injectable } from "@nestjs/common";
import { GetObjectCommand, PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

// Supabase Storage over its S3-compatible endpoint. Private bucket; reads via
// short-lived presigned URLs issued by the backend (no public URLs).
@Injectable()
export class StorageService {
  private readonly s3 = new S3Client({
    forcePathStyle: true, // required for Supabase S3
    region: process.env.S3_REGION,
    endpoint: process.env.S3_ENDPOINT,
    credentials: {
      accessKeyId: process.env.S3_ACCESS_KEY_ID ?? "",
      secretAccessKey: process.env.S3_SECRET_ACCESS_KEY ?? "",
    },
  });
  private readonly bucket = process.env.S3_BUCKET ?? "kyc-documents";

  async upload(key: string, body: Buffer, contentType: string): Promise<void> {
    await this.s3.send(new PutObjectCommand({
      Bucket: this.bucket,
      Key: key,
      Body: body,
      ContentType: contentType,
    }));
  }

  // Time-limited download URL (default 5 min) for admins to view a KYC doc.
  signDownloadUrl(key: string, expiresIn = 300): Promise<string> {
    return getSignedUrl(this.s3, new GetObjectCommand({ Bucket: this.bucket, Key: key }), { expiresIn });
  }
}
