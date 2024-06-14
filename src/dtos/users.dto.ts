import { IsEmail, IsString, IsNotEmpty, MinLength, MaxLength, IS_LENGTH } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty()
  public deviceKey: string;

  public idNum: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(9)
  @MaxLength(32)
  public pinCode: string;
}

export class UpdateUserDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(9)
  @MaxLength(32)
  public pinCode: string;
}