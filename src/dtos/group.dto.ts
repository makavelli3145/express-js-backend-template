import { IsString, IsNotEmpty, IsNumber } from 'class-validator';

export class CreateGroupDto {
  @IsString()
  @IsNotEmpty()
  public name: string;

  @IsNumber()
  @IsNotEmpty()
  public created_by_user_id: number;
}
