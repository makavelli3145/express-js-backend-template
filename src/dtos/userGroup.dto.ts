import { IsNotEmpty, IsNumber, IsString, Length } from 'class-validator';
import { CreateUserDto } from '@dtos/users.dto';

export class CreateUserGroupDto {
  @IsNumber()
  @IsNotEmpty()
  public user_id: number;
  @IsNumber()
  @IsNotEmpty()
  public group_id: number;
  @IsNumber()
  @IsNotEmpty()
  public roles_permissions_id: number;
}

export class UpdateUserGroupDto extends CreateUserGroupDto {
  @IsNumber()
  @IsNotEmpty()
  id: number;
}

export class JoinUserGroupDto {
  @IsNumber()
  @IsNotEmpty()
  user_id: number;

  @IsString()
  @Length(11, 11)
  identification_string: string;
}
export class DeleteUserGroupDto extends CreateUserGroupDto {
  @IsNumber()
  @IsNotEmpty()
  id: number;
}
