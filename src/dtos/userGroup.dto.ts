import { IsNotEmpty, IsNumber } from 'class-validator';
import {CreateUserDto} from "@dtos/users.dto";

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

export class UpdateUserGroupDto extends CreateUserGroupDto{
  @IsNumber()
  @IsNotEmpty()
  id: number;
}
