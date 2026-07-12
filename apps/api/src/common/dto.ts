import { IsBoolean, IsEmail, IsOptional, IsString, MinLength } from "class-validator";

export class LoginDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(1)
  password!: string;
}

export class CreateChefDto {
  @IsString()
  @MinLength(1)
  name!: string;

  @IsString()
  @MinLength(6)
  phone!: string;
}

export class Toggle2faDto {
  @IsBoolean()
  enabled!: boolean;
}

export class VerifyDocumentDto {
  @IsBoolean()
  verified!: boolean;
}

export class RejectChefDto {
  @IsOptional()
  @IsString()
  reason?: string;
}
