import { IsString, IsEmail, Max, Min } from 'class-validator';

export class SignUpDto {
  @IsString()
  @Min(9)
  @Max(12)
  fullName: string;

  @IsString()
  @Min(9)
  @Max(12)
  username: string;

  @IsString()
  @Min(8)
  @Max(12)
  password: string;

  @IsEmail()
  email: string;
}
