import { IsString, IsNotEmpty, IsNumber } from 'class-validator';

export class CreateGroupDto {
  @IsString()
  @IsNotEmpty()
  public name: string;

  @IsNumber()
  @IsNotEmpty()
  public created_by_user_id: number;

  @IsString()
  @IsNotEmpty()
  identification_string: string;
}

export class DeleteGroupDto extends CreateGroupDto{
  @IsNumber()
  @IsNotEmpty()
  id: number;
}

export class UpdateGroupDto extends CreateGroupDto {
  @IsNotEmpty()
  @IsNumber()
  public id: number;
}
