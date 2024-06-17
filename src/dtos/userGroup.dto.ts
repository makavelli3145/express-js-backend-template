import { IsNotEmpty, IsNumber } from 'class-validator';

export class CreateUserGroupDto {
  @IsNumber()
  @IsNotEmpty()
  public user_id: number;
  @IsNumber()
  @IsNotEmpty()
  public group_id: number;
  @IsNumber()
  @IsNotEmpty()
  public user_group_permissions: number;
}
